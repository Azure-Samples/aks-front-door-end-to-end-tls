# Install kubectl
az aks install-cli --only-show-errors

# Get AKS credentials
az aks get-credentials \
  --admin \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --subscription $subscriptionId \
  --only-show-errors

# Check if the cluster is private or not
private=$(az aks show --name $clusterName \
  --resource-group $resourceGroupName \
  --subscription $subscriptionId \
  --query apiServerAccessProfile.enablePrivateCluster \
  --output tsv)

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get_helm.sh -s
chmod 700 get_helm.sh
./get_helm.sh &>/dev/null

# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io

# Update Helm repos
helm repo update

# Install Prometheus
if [[ "$installPrometheusAndGrafana" == "true" ]]; then
  echo "Installing Prometheus and Grafana..."
  helm install prometheus prometheus-community/kube-prometheus-stack \
    --create-namespace \
    --namespace prometheus \
    --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
fi

# Install NGINX ingress controller using the internal load balancer
if [[ "$nginxIngressControllerType" == "Unmanaged" || "$installNginxIngressController" == "true" ]]; then
  if [[ "$nginxIngressControllerType" == "Unmanaged" ]]; then
    echo "Installing unmanaged NGINX ingress controller on the internal load balancer..."
    helm install nginx-ingress ingress-nginx/ingress-nginx \
      --create-namespace \
      --namespace ingress-basic \
      --set controller.replicaCount=3 \
      --set controller.nodeSelector."kubernetes\.io/os"=linux \
      --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
      --set controller.metrics.enabled=true \
      --set controller.metrics.serviceMonitor.enabled=true \
      --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus" \
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=true
    else
      echo "Installing unmanaged NGINX ingress controller on the public load balancer..."
      helm install nginx-ingress ingress-nginx/ingress-nginx \
      --create-namespace \
      --namespace ingress-basic \
      --set controller.replicaCount=3 \
      --set controller.nodeSelector."kubernetes\.io/os"=linux \
      --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
      --set controller.metrics.enabled=true \
      --set controller.metrics.serviceMonitor.enabled=true \
      --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus" \
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
    fi
fi

# Create values.yaml file for cert-manager
echo "Creating values.yaml file for cert-manager..."
cat <<EOF >values.yaml
podLabels:
  azure.workload.identity/use: "true"
serviceAccount:
  labels:
    azure.workload.identity/use: "true"
EOF

# Install certificate manager
if [[ "$installCertManager" == "true" ]]; then
  echo "Installing cert-manager..."
  helm install cert-manager jetstack/cert-manager \
    --create-namespace \
    --namespace cert-manager \
    --set crds.enabled=true \
    --set nodeSelector."kubernetes\.io/os"=linux \
    --values values.yaml

  # Create this cluster issuer only when the unmanaged NGINX ingress controller is installed and configured to use the AKS public load balancer
  if [[ -n "$email" && ("$nginxIngressControllerType" == "Managed" || "$installNginxIngressController" == "true") ]]; then
    echo "Creating the letsencrypt-nginx cluster issuer for the unmanaged NGINX ingress controller..."
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-nginx
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $email
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx
          podTemplate:
            spec:
              nodeSelector:
                "kubernetes.io/os": linux
EOF
  fi

  # Create this cluster issuer only when the managed NGINX ingress controller is installed and configured to use the AKS public load balancer
  if [[ -n "$email" && "$webAppRoutingEnabled" == "true" ]]; then
    echo "Creating the letsencrypt-webapprouting cluster issuer for the managed NGINX ingress controller..."
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-webapprouting
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $email
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: webapprouting.kubernetes.azure.com
          podTemplate:
            spec:
              nodeSelector:
                "kubernetes.io/os": linux
EOF
  fi

  # Create cluster issuer
  if [[ -n "$email" && -n "$dnsZoneResourceGroupName" && -n "$subscriptionId" && -n "$dnsZoneName" && -n "$certManagerClientId" ]]; then
    echo "Creating the letsencrypt-dns cluster issuer..."
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
  namespace: kube-system
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $email
    privateKeySecretRef:
      name: letsencrypt-dns
    solvers:
    - dns01:
        azureDNS:
          resourceGroupName: $dnsZoneResourceGroupName
          subscriptionID: $subscriptionId
          hostedZoneName: $dnsZoneName
          environment: AzurePublicCloud
          managedIdentity:
            clientID: $certManagerClientId
EOF
  fi
fi

# Configure the managed NGINX ingress controller to use an internal Azure load balancer
if [[ "$nginxIngressControllerType" == "Managed" ]]; then
  echo "Creating a managed NGINX ingress controller configured to use an internal Azure load balancer..."
  cat <<EOF | kubectl apply -f -
apiVersion: approuting.kubernetes.azure.com/v1alpha1
kind: NginxIngressController
metadata:
  name: nginx-internal
spec:
  controllerNamePrefix: nginx-internal
  ingressClassName: nginx-internal
  loadBalancerAnnotations: 
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
EOF
fi

# Create a namespace for the application
echo "Creating the [$namespace] namespace..."
kubectl create namespace $namespace

# Create the Secret Provider Class object
echo "Creating the [$secretProviderClassName] secret provider lass object in the [$namespace] namespace..."
cat <<EOF | kubectl apply -n $namespace -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: $secretProviderClassName
spec:
  provider: azure
  secretObjects:
    - secretName: $secretName
      type: kubernetes.io/tls
      data: 
        - objectName: $keyVaultCertificateName
          key: tls.key
        - objectName: $keyVaultCertificateName
          key: tls.crt
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: $csiDriverClientId
    keyvaultName: $keyVaultName
    objects: |
      array:
        - |
          objectName: $keyVaultCertificateName
          objectType: secret
    tenantId: $tenantId
EOF

# Create deployment and service in the namespace
echo "Creating the sample deployment and service in the [$namespace] namespace..."
cat <<EOF | kubectl apply -n $namespace -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: httpbin
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: httpbin
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: httpbin
        image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        securityContext:
          allowPrivilegeEscalation: false
        resources:
          requests:
            memory: "64Mi"
            cpu: "125m"
          limits:
            memory: "128Mi"
            cpu: "250m"
        ports:
        - containerPort: 80
        env:
        - name: PORT
          value: "80"
        volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
        - name: secrets-store-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "$secretProviderClassName"
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: ClusterIP
  selector:
    app: httpbin
EOF

# Determine the ingressClassName
if [[ "$nginxIngressControllerType" == "Managed" ]]; then
  ingressClassName="nginx-internal"
else
  ingressClassName="nginx"
fi

# Create an ingress resource for the application
echo "Creating an ingress in the [$namespace] namespace configured to use the [$ingressClassName] ingress class..."
cat <<EOF | kubectl apply -n $namespace -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: httpbin
  annotations:
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "360"
    nginx.ingress.kubernetes.io/proxy-next-upstream-timeout: "360"
    external-dns.alpha.kubernetes.io/ingress-hostname-source: "annotation-only" # This entry tell ExternalDNS to only use the hostname defined in the annotation, hence not to create any DNS records for this ingress
spec:
  ingressClassName: $ingressClassName
  tls:
  - hosts:
    - $hostname
    secretName: $secretName
  rules:
  - host: $hostname
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: httpbin
            port:
              number: 80
EOF

# Create output as JSON file
echo '{}' |
  jq --arg x 'prometheus' '.prometheus=$x' |
  jq --arg x 'cert-manager' '.certManager=$x' |
  jq --arg x 'ingress-basic' '.nginxIngressController=$x' >$AZ_SCRIPTS_OUTPUT_PATH
