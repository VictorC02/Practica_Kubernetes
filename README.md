<h2 align="center">Despliegue App con Kubernetes</h3>

---

<p align="center"> En este proyecto se despliega una aplicación web, que recoje los datos de una base en Postgresql y los muestra por pantalla, además de tambien recojer los datos que hay guardados en un cache de Redis y mostrarlos. El despliegue también incluye un sistema de monitorización hecho con Grafana y Prometheus, también se incluye un load balancer hecho con Ingress y un sistema de archivos compartidos, como puedan ser logos o imagenes poco pesadas.

Todo este despliegue esta hecho con Kubernetes y con Scripts de automatización. Además tambien se incluyen unas simulaciones de los tipos de despliegue de infraestructura canary y blue-green, además de una pipeline de GitHub Actions.
    
</p>

## 📝 Índice

- [Getting Started](#getting_started)
- [Running Tests](#tests)
- [Built Using](#built_using)
- [Author](#author)

## 🏁 Preparación <a name = "getting_started"></a>

Para tener un entorno de trabajo adecuado para poder desplegar la infraestructura correctamente, hay que seguir las siguientes intrucciones.

### Prerequisitos

Es necesario tener instalado Visual Studio Code, Docker, kubectl y Minikube.

1. Instalar las dependencias de Ubuntu en WSL

```
sudo apt update
sudo apt install -y curl apt-transport-https ca-certificates conntrack
```
2. Instalar Docker
```
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```
3. Instalar kubectl (Herramienta de línea de comandos para Kubernetes)
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
4. Instalar Minikube
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube
```


### Despliegue del Entorno de Trabajo

* Descargar o clonar el repositorio de Github
* Abrir una terminal en WSL de Visual Studio Code
* Ejecutar el Script init.sh para inicializar todos los servicios.
```
cd Scripts/

./init.sh
```

Ahora los servicios se están levantando, para saber si estan todos levantados y poder seguir podemos usar el siguiente comando:
```
kubectl get pods
```
Para acceder a la app y poder ver los datos mostrados por la app hay que acceder a la dirección del load balancer, para ello hay que introducir el siguiente comando:

```
minikube service ingress-nginx-controller -n ingress-nginx
```

Accediendo a la primera dirección que devuelve el comando podremos acceder a la app. En la app podemos ver en que instancia de la app estamos, si vamos recargando la página veremos como la instancia va cambiando.

Para acceder a cualquier otro servicio, como la monitorización, debemos acceder a través de la dirección que nos devuelva el siguiente comando:

```
minikube service <nombre_del_servicio-service>
```

Nota: Cada vez que se acceda a un servicio usando minikube service, hay que dejar esa ventana del terminal abierta.

## 🔧 Ejecución de los Tests <a name = "tests"></a>


### Monitorización Activa de la Aplicación

Para comprobar que hay monitorización activa, simplemente tenemos que acceder a la dirección donde se encuentra Grafana o Prometheus. 

Para acceder a las direcciones de ambos servicios hay que ejecutar el siguiente comando:
```
minikube service grafana_o_prometheus-service
```

La ingesta de logs en Grafana y Prometheus todavia no está implementada, aunque se puede acceder a ambos portales.
### Resiliencia y Alta Disponibilidad

Para comprobar que los servicios tienen alta disponibilidad y resiliencia ante caidas podemos ejecutar los sigueintes comandos:
1. Ver los pods que hay activos
```
kubectl get pods
```
![Ver Pods](/images/f1.PNG)

2. Eliminar un pod 
```
kubectl delete pods <nombre_del_pod>
```
![Ver Pods](/images/f2.PNG)

3. Volver a mirar los pods que hay activos

![Ver Pods](/images/f3.PNG)

Como se puede comprobar en la anterior imagen, el pod que se ha intentado eliminar se elimina pero otro en su lugar se inicia, es por eso que el pod postgres ha cambiado su nombre.

También se puede ver como la app se ha reiniciado, esto es porque tiene dependencia de la base de datos y si esta se cae, la app también se cae y hasta que no se reinicie la app no volverá a funcionar.

### Correcto Funcionamiento del Despliegue Canary y Blue-Green

Para poder ejecutar Canary hay que ejecutar el siguiente comando:

```
cd Scripts/

./canary.sh
```

Pero antes de ejecutarlo hay que modificar la linea de código mostrada en la siguiente imagen, con la dirección que nos ha devuelto el comando para acceder al load balancer.

![canary](/images/f4.PNG)

Una vez ejecutado el canary.sh se empezará la simulación del despliegue canary. Dentro del propio Script hay un test que prueba que la app funciona correctamente, en caso de no pasarlo se mostrará el siguiente mensaje por consola:

![Canary Fallido](/images/f5.PNG)

Y en caso de pasarlo se continuará con el despliegue de la nueva versión en las instancias que faltan.

![Canary Exitoso](/images/f6.PNG)

Para comprobar la funcionalidad del despliegue blue-green hay que hacer exactamente lo mismo que para el despliegue canary.

## ⛏️ Hecho Con... <a name = "built_using"></a>

- [PostgresSQL](https://www.postgresql.or) - Database
- [Express](https://expressjs.com/) - Server Framework
- [Redis](https://redis.io/) - Cache Database
- [NodeJs](https://nodejs.org/en/) - Server Environment
- [Docker](https://www.docker.com/) - Containers
- [Kubernetes](https://kubernetes.io/es/) - Container Manager
- [Prometheus](https://prometheus.io/) - Metrics Visualizer
- [Grafana](https://grafana.com/) - Logs Visualizer


## ✍️ Autor <a name = "authors"></a>

- [@VictorC02](https://github.com/VictorC02) 
