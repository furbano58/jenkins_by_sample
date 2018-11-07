# Jenkins | Ejercicio Final

---------------------------------------------------------

En este ejercicio llevaremos a cabo un ejemplo real de **pipelines**.

Crearemos un **pipeline** que usará **jenkins**, **docker** y **maven**.

Dispondremos de un **Jenkins server** que mediante **docker** ejecutará las distintas fases del desarrollo.

* En el **Build** generaremos el **.jar** de nuestra aplicación y una imagen **docker** que contendrá esa aplicación **.jar**.
* En el **Test** ejecutaremos **UnitTest** usando **docker** en **jenkins**.
* En el **Push** crearemos un **Registry** con autenticación y sin autenticación para subir la imagen ya testeada.
* Finalmente desplegaremos el **.jar** la imagen de **producción**.

[Volver al Inicio](#jenkins--ejercicio-final)



## INSTALACIÓN BÁSICA INICIAL

---------------------------------------------------------

Para ello crearemos nuestra carpeta **jenkins_home** dónde se alojara jenkins usando `mkdir jenkins_home` para posteriormente asignarle permisos mediante `chown 1000 -R jenkins_home` como usuario root (`sudo su`).

```bash
demo@VirtualBox:~/Demo_Docker$ mkdir jenkins_home

demo@VirtualBox:~/Demo_Docker$ sudo su
[sudo] password for demo:
root@hector-VirtualBox:/home/demo/jenkins-by-sample# chown 1000 -R jenkins_home
```

Una vez creada la carpeta, lanzaremos el servicio de jenkins con la configuración de [docker-compose.yml](./docker-compose.yml).

```bash
demo@VirtualBox:~/Demo_Docker$ docker-compose up -d
Starting jenkins ... done

demo@VirtualBox:~/Demo_Docker$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                             PORTS                                              NAMES
f8614b0c9819        jenkins/docker      "/sbin/tini -- /usr/…"   27 seconds ago      Up 18seconds                      0.0.0.0:8080->8080/tcp, 50000/tcp                  jenkins
b8dce074668a        gitlab/gitlab-ce    "/assets/wrapper"        27 seconds ago      Up 17seconds (health: starting)   0.0.0.0:80->80/tcp, 22/tcp, 0.0.0.0:443->443/tcp   git-server
a6c4f881aaf1        remote-host         "/bin/sh -c '/usr/sb…"   27 seconds ago      Up 19seconds                                                                         remote-host
f57c91114d49        ansible-web         "/bin/sh -c /start.sh"   27 seconds ago      Up 19seconds                      443/tcp, 0.0.0.0:8888->80/tcp                      web
be12302b6c42        mysql:5.7           "docker-entrypoint.s…"   27 seconds ago      Up 21seconds                      3306/tcp, 33060/tcp 
```

> **NOTA**: Ya que **GitLab-Server** consume muchos recursos lo pararemos mientras trabajamos mediante el comando de consola `docker stop git-server`, ejecutamos `docker ps` para confirmar que se paró el contenedor.

[Volver al Inicio](#jenkins--ejercicio-final)



## INSTALAR DOCKER DENTRO DEL CONTENEDOR DE JENKINS

---------------------------------------------------------

En los ejemplos anteriores si accediesemos al contenedor de **jenkins**, `docker exec -ti jenkins bash` y ejecutasemos un comando de **docker**, `docker ps` vereríamos que no está instalado. 

**¿Para qué queremos Docker dentro de Jenkins?** Utilizaremos **docker** para agilizar el trabajo, y automatizar los procesos.

Para ello hemos utilizado el **Dockerfile** que se ubica dentro de la carpeta de *pipeline** en el cual se realizará una instalación de **docker** bajo **debian** más la instalación de **docker-compose** y la inclusión del usuario **docker** en el grupo de **jenkins**.

_[pipeline/Dockerfile](./pipeline/Dockerfile)_
```dockerfile
FROM jenkins/jenkins

USER root

# Instala ansible
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py

RUN pip install -U ansible

# Instala Docker

RUN apt-get update && \
apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable" && \
apt-get update && \
apt-get -y install docker-ce

# COmpose

RUN curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

RUN usermod -aG docker jenkins

USER jenkins
```

Ahora accedemos al contenedor de **jenkins**, `docker exec -ti jenkins bash` y al ejecutar `docker ps` vemos los contenedores activos. **LOS MISMOS CONTENEDORES QUE TENEMOS FUERA ACTIVOS**

> **NOTA**: si tuvieramos problemas de permisos al ejecutar **docker** dentro del contenedor de **jenkins** deberíamos entrar dentro de **jenkins** como **root** `docker exec -ti -u root jenkins bash` para ejecutar `chown jenkins /var/run/docker.sock`. Ahora podríamos ejecutar `docker ps` dentro del contenedor de **jenkins** con el usuario estándar **jenkins**.

[Volver al Inicio](#jenkins--ejercicio-final)



## DEFINIR LOS STAGES DEL PIPELINE DE JENKINS

---------------------------------------------------------

Para verlo accederemos a [pipeline/Jenkinsfile](pipeline/Jenkinsfile).

_[pipeline/Jenkinsfile](pipeline/Jenkinsfile)_
```js
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''
			        echo build
                    '''   
            }
        }                        
    }
    stages {
        stage('Test') {
            steps {
                sh '''
			        echo test
                    '''   
            }
        }                        
    }  
    stages {
        stage('Push') {
            steps {
                sh '''
			        echo push
                    '''   
            }
        }                        
    }   
    stages {
        stage('Deploy') {
            steps {
                sh '''
			        echo deploy
                    '''   
            }
        }                        
    }       
}
```

[Volver al Inicio](#jenkins--ejercicio-final)