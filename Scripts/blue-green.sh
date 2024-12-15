#!/bin/bash
echo "---------Empezando Despliegue Blue-Green---------"

# Paso 1: Actualiza la imagen para incluir la nueva versión
echo "---------Actualizando el Despliegue a la Version 2---------"
cd "/mnt/c/Users/Victor/Documents/GitHub/Practica_Kubernetes/app"
minikube image build -t app:v2 .

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  labels:
    app: app-green
spec:
  replicas: 0  # Inicialmente desactivada
  selector:
    matchLabels:
      app: app-green
  template:
    metadata:
      labels:
        app: app-green
    spec:
      containers:
      - name: app
        image: app:v2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        livenessProbe:  # Verifica si el contenedor está vivo
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
        readinessProbe:  # Verifica si el contenedor está listo para recibir tráfico
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
        env:
        - name: PORT
          value: "3000"
        - name: POSTGRES_USER
          value: "user"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: service-secrets
              key: POSTGRES_PASSWORD
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: POSTGRES_DB
          value: "database"
        - name: POSTGRES_PORT
          value: "5432"
        - name: REDIS_PORT
          value: "6379"
        - name: REDIS_HOST
          value: "redis-service"
        - name: NODE_ENV
          value: "production"
        - name: APP_VERSION
          value: "green"
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        volumeMounts:
          - name: static-files-volume
            mountPath: /usr/share/app/static
      volumes:
        - name: static-files-volume
          configMap:
            name: static-files
EOF

sleep 10

# Paso 2: Escalar la versión verde
kubectl scale deployment app-green --replicas=3

echo "---------Esperando Instancias Green...---------"

sleep 30

# Verificar que ambas versiones están activas
kubectl get pods

sleep 5

# Paso 3: Cambiar el tráfico a la versión verde
kubectl patch service app-service -p '{"spec":{"selector":{"app":"app-green"}}}'

sleep 5

# Paso 4: Validar la nueva versión
echo "---------Testeando la Nueva Versión---------"
CANARY_RESPONSE=$(curl -s http://127.0.0.1:42133/version | grep -o '"green"')

if [ "$CANARY_RESPONSE" == '"green"' ]; then
  echo "---------La Nueva Versión Pasó el Test!---------"
  # Paso 5: Escalar la versión azul a 0
  kubectl scale deployment app --replicas=0
  sleep 2
  echo "---------Despliegue Blue-Green Exitoso!---------"
else
  echo "---------Despliegue Blue-Green Fallido! Volviendo a la Version Antigua---------"
  kubectl scale deployment app --replicas=3
  kubectl patch service app-service -p '{"spec":{"selector":{"app":"app"}}}'
  kubectl scale deployment app-green --replicas=0
fi
