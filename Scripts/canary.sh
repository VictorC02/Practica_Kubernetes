#!/bin/bash
echo "---------Empezando Despliegue Canary---------"

# Paso 1: Actualiza la imagen para incluir la nueva versión
echo "---------Actualizando el Despliegue a la Version 2---------"
cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes/app"
minikube image build -t app:v2 .
kubectl set image deployment/app app=app:v2
kubectl set env deployment/app APP_VERSION=v2
sleep 10

# Paso 2: Escala gradualmente la nueva versión
echo "---------Escalando la Instancia de la App---------"
kubectl scale deployment app --replicas=1
sleep 30  # Permite que la nueva réplica entre en servicio

# Paso 3: Validar la nueva versión
echo "---------Testeando la Nueva Versión---------"
CANARY_RESPONSE=$(curl -s http://127.0.0.1:44737/version | grep -o '"v2"')

if [ "$CANARY_RESPONSE" == '"v2"' ]; then
  echo "---------La Nueva Versión Pasó el Test! Escalando...---------"
  kubectl scale deployment app --replicas=3
  echo "---------Despliegue Canary Exitoso!---------"
else
  echo "---------Despliegue Canary Fallido! Volviendo a la Version Antigua---------"
  kubectl rollout undo deployment/app
fi
