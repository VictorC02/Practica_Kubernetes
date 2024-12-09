orden comandos

minikube start

minikube image build -t app:latest .

kubectl create namespace app

kubectl create namespace database

kubectl create namespace monitoring

kubectl create namespace cache


kubectl apply -f app-deployment.yaml -f app-service.yaml -f postgres-deployment.yaml -f postgres-service.yaml -f redis-deployment.yaml -f redis-service.yaml -f postgres-pv.yaml -f postgres-pvc.yaml -f db-secrets.yaml

kubectl create configmap static-files --from-file=./static-files

minikube service app-service

minikube service postgres-service

minikube service redis-service