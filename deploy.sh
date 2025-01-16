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
  echo "O cluster Kubernetes não está ativo. Iniciando o cluster kind."
  kind create cluster
fi

# Etapa 1: Configuração do cluster Kind
echo "Configurando o cluster Kind"
if [ -f "$KIND_DIR/kind-config.yaml" ]; then
  kind create cluster --config "$KIND_DIR/kind-config.yaml"
else
  echo "Arquivo de configuração do Kind não encontrado."
fi

# Etapa 2: Implantar ingress-controller
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
echo "Aguardando ingress-controller ser iniciado completamente."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Etapa 3: Implantar nginx
echo "Implantando o nginx"
cd manifests/app
kubectl apply -f deployment.yml -f ingress.yml -f service.yml
cd ..

#Etapa 4: Implantar db
echo "Implantando db"
cd db
kubectl apply -f deployment.yml -f secret.yml -f pvc.yml -f service.yml
cd ..

# Etapa 5: Configuração hpa
echo "Configurando HPA"
cd ../hpa
kubectl apply -f hpa.yml

# Exibe o status dos recursos implantados
kubectl get pods --all-namespaces

echo "Todos os serviços foram implantados com sucesso!"