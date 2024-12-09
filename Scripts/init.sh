#!/bin/bash

set -x

cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes"
minikube start

cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes/app"
minikube image build -t app:latest .

minikube addons enable ingress

cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes/kubernetes/database"
kubectl create configmap init-script --from-file=init.sql

cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes/kubernetes"
kubectl create configmap static-files --from-file=./static-files


kubectl apply -f cache/ -f database/ -f service-secrets.yaml -f monitorizacion/ 

sleep 5

kubectl apply -f app/ 

sleep 10

kubectl apply -f balanceador/
