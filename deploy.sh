#!/bin/bash

set -e
set -o pipefail  

echo "Iniciando a implantação dos serviços no Kubernetes..."

# Verifica se o cluster está ativo
echo "Verificando se o cluster Kubernetes está rodando"
if ! kubectl cluster-info > /dev/null 2>&1; then
  echo "O cluster Kubernetes não está ativo. Inicie o cluster kind."
  exit 1
fi

# Etapa 1: Configuração do cluster Kind
echo "Configurando o cluster Kind"
if [ -f "kind/kind-config.yaml" ]; then
  kind create cluster --config kind/kind-config.yaml
else
  echo "Arquivo de configuração do Kind não encontrado."
fi

# Etapa 2: Implantar ingress-controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/kind/deploy.yaml
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

#Etapa 6: setando true para ingress
kubectl label node kind-control-plane ingress-ready=true
# Exibe o status dos recursos implantados
kubectl get pods --all-namespaces

echo "Todos os serviços foram implantados com sucesso!"