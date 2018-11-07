# Jenkins | Ejercicio Final

---------------------------------------------------------

[Volver al Inicio](#jenkins--ejercicio-final)



## TEST

---------------------------------------------------------

[Volver al Inicio](#jenkins--ejercicio-final)



### REALIZAR TEST DESDE MAVEN

---------------------------------------------------------

Para construir el Test ejecutaremos el comando `docker run --rm -v /root/.m2:/root/.m2 -v /home/demo/Demo_Docker/jenkins/pipeline/java-app:/app -w /app maven:3-alpine mvn test`  (dentro de la carpeta [pipeline] de nestra máquina).

> **NOTA**: La primera parte del comando genera el contenedor que nos creará el **contenedor**, `docker run --rm -v /root/.m2:/root/.m2 -v /home/demo/Demo_Docker/jenkins/pipeline/java-app:/app -w /app maven:3-alpine`
* utilizaremos una imagen de **maven**, `maven:3-alpine`.
* el atributo `-v` definirá los volúmenes que emplearemos.
* al disponer de un atributo `-rm` el contenedor se destruirá nada más salirnos de él.
* el atributo `-w /app` nos entra directamente en esa carpeta del contenedor (directorio de trabajo).
* Finalmente sobre escribimos el **CMD** del contenedor mediante `mvn test`, el cual generará el **.jar**.

```bash

demo@VirtualBox:~/Demo_Docker/Pipeline$ docker run --rm -v /root/.m2:/root/.m2 -v /home/demo/Demo_Docker/jenkins/pipeline/java-app:/app -w /app maven:3-alpine mvn test

[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building my-app 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
// ...
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.mycompany.app.AppTest
Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.442 sec

Results :

Tests run: 2, Failures: 0, Errors: 0, Skipped: 0

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 9.939 s
[INFO] Finished at: 2018-11-07T17:51:55Z
[INFO] Final Memory: 11M/104M
[INFO] ------------------------------------------------------------------------

demo@VirtualBox:~/Demo_Docker/Pipeline$
```

Los test generados se guardaran dentro de [pipeline/java-app/target/surefire-reports/](pipeline/java-app/target/surefire-reports/).

**ACABAMOS DE CONSTRUIR LAS PRUEBAS UNITARIAS DE NUESTRO CÓDIGO**

[Volver al Inicio](#jenkins--ejercicio-final)



### CREAR SCRIPT QUE AUTOMATICE EL SCRIPT

---------------------------------------------------------

Para ello crearemos un **Script** dentro de [pipeline/jenkins/test/test.sh](pipeline/jenkins/test/test.sh) con el siguiente contenido.

_[pipeline/jenkins/test/test.sh](pipeline/jenkins/test/test.sh)_
```bash
#!/bin/bash

echo "################"
echo "*** Testing  ***"
echo "################"

docker run --rm -v /root/.m2:/root/.m2 -v /home/ricardo/jenkins/jenkins_home/workspace/pipeline-docker-maven/java-app:/app -w /app maven:3-alpine "$@"
```

Igual que con el **BUILD** dejaremos la entrada del **comando** libre como una **variable**

> **NOTA**: Es importante otorgar permisos de ejecución al **Script**, `chmod +x jenkins/test/test.sh` desde la carpeta [pipeline](pipeline).

```bash
demo@VirtualBox:~/Demo_Docker/Pipeline$ chmod +x jenkins/test/test.sh

demo@VirtualBox:~/Demo_Docker/Pipeline$ ./jenkins/test/test.sh mvn test

################
*** Testing  ***
################
// ...
```

**YA TENEMOS AUTOMATIZADO EL PROCESO DE GENERAR LOS REPORTES DE LAS PRUEBAS UNITARIAS**

[Volver al Inicio](#jenkins--ejercicio-final)



### ACTUALIZAMOS EL PIPELINE CON EL NUEVO SCRIPT

---------------------------------------------------------

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
                    ./jenkins/test/test.sh mvn test' 
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
