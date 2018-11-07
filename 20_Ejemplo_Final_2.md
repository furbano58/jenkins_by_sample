# Jenkins | Ejercicio Final

---------------------------------------------------------

[Volver al Inicio](#jenkins--ejercicio-final)



## BUILD

---------------------------------------------------------

[Volver al Inicio](#jenkins--ejercicio-final)



### CONSTRUIR UN JAR CON DOCKER

---------------------------------------------------------

Para este ejemplo usaremos la aplicación de java descargada del repositorio inicial que usamos anteriormente y que ubicaremos dentro de [pipeline/java-app/](pipeline/java-app/).

> **NOTA**: Al tratarse de un repositorio será necesario para esta demostración eliminar la carpeta interna que trae de **git**, **.git/**.

Ahora crearemos dentro de [pipeline](./pipeline/) una carpeta llamada **build** que será dónde trabajaremos, `mkdir jenkins/build -p`.

Para generar el **.jar** a partir de **docker** ejecutaremos la línea `docker run --rm -v /root/.m2:/root/.m2 -v $PWD/java-app:/app -w /app maven:3-alpine mvn -B -DskipTest clean package` (dentro de la carpeta [pipeline] de nestra máquina).

> **NOTA**: La primera parte del comando genera el contenedor que nos creará el **contenedor**, `docker run --rm -v /root/.m2:/root/.m2 -v $PWD/java-app:/app -w /app maven:3-alpine`
* el atributo `-v` definirá los volúmenes que emplearemos.
* al disponer de un atributo `-rm` el contenedor se destruirá nada más salirnos de él.
* el atributo `-w /app` nos entra directamente en esa carpeta del contenedor (directorio de trabajo).
* Finalmente sobre escribimos el **CMD** del contenedor mediante `mvn -B -DskipTest clean package`, el cual generará el **.jar**.

```bash
demo@VirtualBox:~/Demo_Docker/Pipeline$ docker run --rm -v /root/.m2:/root/.m2 -v $PWD/java-app:/app -w /app maven:3-alpine mvn -B -DskipTest clean package
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
// ...
[INFO]
[INFO] --- maven-jar-plugin:3.0.2:jar (default-jar) @ my-app ---
[INFO] Building jar: /app/target/my-app-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 16.715 s
[INFO] Finished at: 2018-11-07T16:43:20Z
[INFO] Final Memory: 18M/104M
[INFO] ------------------------------------------------------------------------
```

[Volver al Inicio](#jenkins--ejercicio-final)




### CREAR UN SCRIPT PARA AUTOMATIZAR LA CREACIÓN DE JAR CON DOCKER

---------------------------------------------------------

Para ello crearemos un **script** que automatizará el proceso de compilación del **.jar**, este lo tenemos ubicado dentro de [pipeline/jenkins/build/mvn.sh](pipeline/jenkins/build/mvn.sh), al cual habrá que otrogar permisos de ejecución `chmod +x jenkins/build/mvn.sh` (como **root**, `sudo su`).

_[pipeline/build/mvn.sh](pipeline/build/mvn.sh)_
```bash
#!/bin/bash

echo "****************"
echo "* Building jar!*"
echo "****************"

PROJ=/home/demo/Demo_Docker/jenkins/pipeline
docker run --rm -v /root/.m2:/root/.m2 -v $PROJ/java-app:/app -w /app maven:3-alpine "$@"
```
> **NOTA**: La variable **PROJ** hace referencia a la ubicación del proyecto dentro de **pipeline** para verla debemos acceder como **root** (`sudo su`)
> **NOTA**: Con el comando `"@"` indicamos que podemos pasar los comandos al **Script** (`mvn -B -DskipTest clean package`).

Así, para ejecutar el script utilizaremos el comando `./jenkins/build/mvn.sh mvn -B -DskipTest clean package`.

```bash
demo@VirtualBox:~/Demo_Docker $ cd pipeline

demo@VirtualBox:~/Demo_Docker/pipeline$ ./jenkins/build/mvn.sh mvn -B -DskipTest clean package
****************
* Building jar!*
****************
[INFO] Scanning for projects...
[INFO]
[INFO] -----------------------
// ...
```

Para asegurarnos que todo está correcto eliminaremos el archivo compilado ubicado en [pipeline/java-app/target/my-app-1.0-SNAPSHOT.jar](./pipeline/java-app/target/my-app-1.0-SNAPSHOT.jar), ejecutamos nuevamente el script `./jenkins/build/mvn.sh mvn -B -DskipTest clean package` y volverá aparecer el archivo.

[Volver al Inicio](#jenkins--ejercicio-final)




### CREAR UN DOCKERFILE QUE CONSTRUYA LA IMAGEN CON EL JAR

---------------------------------------------------------

Para ello usaremos un Dockerfile ubicado en [pipeline/jenkins/build/Dockerfile-Java](pipeline/jenkins/build/Dockerfile-Java) con el siguiente contenido:

_[pipeline/jenkins/build/Dockerfile-Java](pipeline/jenkins/build/Dockerfile-Java)_
```Dockerfile
FROM openjdk:8-jre-alpine

RUN mkdir /app

COPY *.jar  /app/app.jar

CMD java -jar /app/app.jar
```

Este **DockerFile** se creará a partir de una imagen de **java** oficial de **docker** llamada **openjdk:8-jre-alpine** que compilará el **.jar**, dentro del contenedor se creará una carpeta **/app** en el directorio y copiará todos los archivos **.jar** de la carpeta dónde se encuentra dentro del contenedor en la carpeta **app** generada anteriormente como **app.jar**. Finalmente ejecutará dicho **.jar**.

Para cosntruir la imagen ejecutaremos el comando `docker build -f Dockerfile-Java -t test .` (desde la carpeta [pipeline/jenkins/build](pipeline/jenkins/build)), este comando utilizará la imagen **dockerfile** definida dentro del archivo [pipeline/jenkins/build/Dockerfile-Java](pipeline/jenkins/build/Dockerfile-Java), y le colocará el nombre **test**.

```bash
demo@VirtualBox:~/Demo_Docker/$ cd pipeline/jenkins/build
demo@VirtualBox:~/Demo_Docker/pipeline/jenkins/build$ docker build -f Dockerfile-Java -t test .
Sending build context to Docker daemon  8.704kB
Step 1/4 : FROM openjdk:8-jre-alpine
8-jre-alpine: Pulling from library/openjdk
4fe2ade4980c: Pull complete
6fc58a8d4ae4: Pull complete
819f4a45746c: Pull complete
Digest: sha256:e8a689c4b2913f07e401e5e9325d66cecc33d30738aadf1dbe3db5af70997742
Status: Downloaded newer image for openjdk:8-jre-alpine
 ---> 2e01f547f003
Step 2/4 : RUN mkdir /app
 ---> Running in 8714dd3fd35d
Removing intermediate container 8714dd3fd35d
 ---> 765de1e352cb
Step 3/4 : COPY *.jar  /app/app.jar
 ---> e3f20e46534b
Step 4/4 : CMD java -jar /app/app.jar
 ---> Running in b44eb2428264
Removing intermediate container b44eb2428264
 ---> 88c47c29e572
Successfully built 88c47c29e572
Successfully tagged test:latest
```


Una vez construida podremos visualizarla con el comando `docker images | grep test`.

```bash
demo@VirtualBox:~/Demo_Docker/$ dockerimages | grep test
test                latest              88c47c29e572        3 minutes ago       83MB
// ...
```

Ahora si accedemos al interior de la imagen podremos ver que efectivamente dentro tiene el archivo generado.

```bash
demo@VirtualBox:~/Demo_Docker/$ docker run --rm -ti test sh
/ # ls /app
app.jar
```

> **NOTA**: El sistema operativo de la imagen es **Alpine** el cual no tiene **bash**, sino **sh**.


[Volver al Inicio](#jenkins--ejercicio-final)




### CREAR UN DOCKER-COMPOSE QUE CONSTRUYA NUESTRA IMAGEN

---------------------------------------------------------

Para ello crearemos el Docker compose dentro de la carpeta [pipeline/jenkins/build]/pipeline/jenkins/build) con el siguiente contenido.

_[pipeline/jenkins/build/docker-compose-build.yml](pipeline/jenkins/build/docker-compose-build.yml)_
```bash
version: '3'
services:
  app:
    image: "app:$BUILD_TAG"
    build:
      context: .
      dockerfile: Dockerfile-Java
```

Este **docker-compose** llamará al **dockerfile** anterior y contiene una imagen con tags diferentes, el cual variará con una variable de entrada **$BUILD_TAG**.

Si ejecutasemos **docker-compose**, `docker-compose -f docker-compose-build.yml build`, el servicio no se crearía ya que necesita de la variable descrita anteriormente.

```bash
demo@VirtualBox:~/Demo_Docker/pipeline/jenkins/build$ docker-compose -f docker-compose-build.yml build

WARNING: The BUILD_TAG variable is not set. Defaulting to a blank string.
Building app
ERROR: invalid reference format
```

Para probar que funciona crearemos una variable temporal mediante el comando `export BUILD_TAG=12` y ahora si podremos crear el servicio.

```bash
demo@VirtualBox:~/Demo_Docker/pipeline/jenkins/build$ export BUILD_TAG=12

demo@VirtualBox:~/Demo_Docker/pipeline/jenkins/build$ docker-compose -f docker-compose-build.yml build

Building app
Step 1/4 : FROM openjdk:8-jre-alpine
 ---> 2e01f547f003
Step 2/4 : RUN mkdir /app
 ---> Using cache
 ---> 765de1e352cb
Step 3/4 : COPY *.jar  /app/app.jar
 ---> f57725f3cc88
Step 4/4 : CMD java -jar /app/app.jar
 ---> Running in 4a60e255c2c9
Removing intermediate container 4a60e255c2c9
 ---> 9890707569da
Successfully built 9890707569da
Successfully tagged app:12
```

> **NOTA**: Ya hemos podido generar la imagen, cuando utilicemos **jenkins** este será el que le aporte el valor a dicha variable.

Si ejecutamos el comando `docker images | grep 12` podremos ver que efectivamente tenemos nuestra imagen montada correctamente.

**SI CAMBIASEMOS EL TAG** veríamos que efectivamente se generó.

**ASÍ HEMOS AUTOMATIZADO LA CONSTRUCCIÓN DE LA IMAGEN**

[Volver al Inicio](#jenkins--ejercicio-final)




### CREAR UN SCRIPT PARA AUTOMATIZAR LA CREACIÓN DE LA IMAGEN CON COMPOSE

---------------------------------------------------------

Para ello crearemos un **script** dentro del archiv [pipeline/jenkins/build/buidl.sh](pipeline/jenkins/build/buidl.sh).

> **NOTA**: Siempre será necesario copiar el **.jar** dentro del contenedor para que pueda ejecutarse (`java-app/target/*.jar` dentro del contenedor en `jenkins/build/`).

_[pipeline/jenkins/build/build.sh](pipeline/jenkins/build/build.sh)_
```bash
#!/bin/bash

# Copia el jar

cp -f java-app/target/*.jar jenkins/build/  

echo "######################"
echo "*** Building image ***"
echo "######################"

cd jenkins/build/ && docker-compose -f docker-compose-build.yml build --no-cache
```

> **NOTA**: el `--no-cache` del comando se asegurará de no estar usando la cache durante la compilación.

Para probar el comando utilizado crearemos nuevamente una **variable de entorno**, `export BUILD_TAG=12`, y ejecutaremos el comando `cd jenkins/build/ && docker-compose -f docker-compose-build.yml build --no-cache` desde el directorio [pipeline](pipeline).

```bash
demo@VirtualBox:~/Demo_Docker/pipeline$ export BUILD_TAG=12

demo@VirtualBox:~/Demo_Docker/pipeline$ cd jenkins/build/ && docker-compose -f docker-compose-build.yml build --no-cache

Building app
Step 1/4 : FROM openjdk:8-jre-alpine
 ---> 2e01f547f003
Step 2/4 : RUN mkdir /app
 ---> Running in e9b6cbd2a876
Removing intermediate container e9b6cbd2a876
 ---> 36a350f5d297
Step 3/4 : COPY *.jar  /app/app.jar
 ---> 4feb2366c3b6
Step 4/4 : CMD java -jar /app/app.jar
 ---> Running in a85a2f4abfab
Removing intermediate container a85a2f4abfab
 ---> 190a9ca89a60
Successfully built 190a9ca89a60
Successfully tagged app:12
```

En el siguiente paso llamaremos al script para ver si verdaderamente funciona como debe usando el comando, `./jenkins/build/build.sh`. Si tuvieramos algún problema de permisos simplemente utilizaríamos previamente el comando `chmod +x ./jenkins/build/build.sh`.

```bash
demo@VirtualBox:~/Demo_Docker/pipeline$ ./jenkins/build/build.sh
bash: ./jenkins/build/build.sh: Permission denied

demo@VirtualBox:~/Demo_Docker/pipeline$ chmod +x ./jenkins/build/build.sh

demo@VirtualBox:~/Demo_Docker/pipeline$ ./jenkins/build/build.sh
######################
*** Building image ***
######################
```

**AHORA TENEMOS NUESTRO SCRIPT QUE CONSTRUYE AUTOMÁTICAMENTE EL JAR**

[Volver al Inicio](#jenkins--ejercicio-final)




### AGREGAR SCRIPT A JENKINS

---------------------------------------------------------

Aquí aprenderemos como agregar todo lo anterior a **Jenkinsfile**.

Resumiendo, hemos creado dos scripts, [pipeline/jenkins/build/mvn.sh](pipeline/jenkins/build/mvn.sh) genera un **.jar**, mientras que el segundo **script** [pipeline/jenkins/build/build.sh](pipeline/jenkins/build/build.sh) coge el **.jar** creado anteriormente y lo convierte en una imagen.

_[pipeline/Jenkinsfile](pipeline/Jenkinsfile)_
```js
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''
                    ./jenkins/build/mvn.sh mvn -B -DskipTests clean package
			        ./jenkins/build/build.sh
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