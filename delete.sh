#!/bin/bash

set -e  # Encerra o script se qualquer comando falhar
set -o pipefail  # Garante que falhas em pipelines sejam tratadas como erro

echo "Iniciando a implantação dos serviços no Kubernetes..."

# Diretórios dos manifests
MANIFESTS_DIR="manifests"
HPA_DIR="hpa"

# Verifica se o cluster está ativo
echo "Verificando se o cluster Kubernetes está rodando"
if ! kubectl cluster-info > /dev/null 2>&1; then
  echo "O cluster Kubernetes não está ativo. Por favor, inicie o Kind ou configure o acesso."
  exit 1
fi


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
