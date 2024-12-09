#!/bin/bash

set -x

cd "/mnt/c/Users/Victor/Desktop/Redes Avanzadas/Practica_Kubernetes"
minikube start

cd "/mnt/c/Users/Victor/Desktop/Redes Avanzadas/Practica_Kubernetes/app"
minikube image build -t app:latest .


# kubectl create namespace app

# kubectl create namespace database

# kubectl create namespace monitoring

# kubectl create namespace cache


cd "/mnt/c/Users/Victor/Desktop/Redes Avanzadas/Practica_Kubernetes/kubernetes"
kubectl create configmap static-files --from-file=./static-files

kubectl apply -f app/ -f cache/ -f database/ -f monitorizacion/ -f service-secrets.yaml
