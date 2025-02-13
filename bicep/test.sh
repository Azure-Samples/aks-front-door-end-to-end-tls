#!/bin/bash

# Variables
url="https://httpbin.babosbird.com"

# Call REST API
echo "Calling REST API..."
curl -I -s "$url"

# Simulate SQL injection
echo "Simulating SQL injection..."
curl -I -s "${url}?users=ExampleSQLInjection%27%20--"

# Simulate XSS
echo "Simulating XSS..."
curl -I -s "${url}?users=ExampleXSS%3Cscript%3Ealert%28%27XSS%27%29%3C%2Fscript%3E"

# A custom rule blocks any request with the word blockme in the querystring.
echo "Simulating query string manipulation with the 'blockme' word in the query string..."
curl -I -s "${url}?task=blockme"