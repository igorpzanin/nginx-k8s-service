#!/bin/bash

set -e  
set -o pipefail  

echo "Iniciando a remoção dos serviços no Kubernetes..."

# deletar ingress-controller
kubectl delete -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# deletar nginx
echo "Deletando o nginx"
cd manifests/app
kubectl delete -f deployment.yml -f ingress.yml -f service.yml
cd ..

#deletar db
echo "Deletando db"
cd db
kubectl delete -f deployment.yml -f secret.yml -f pvc.yml -f service.yml
cd ..

# Etapa 5: deletar hpa
echo "Deletando HPA"
cd ../hpa
kubectl delete -f hpa.yml
