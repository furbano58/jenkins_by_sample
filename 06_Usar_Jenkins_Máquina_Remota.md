---------------------------------------------------------

### Usar Jenkins en Una Máquina Remota Vía SSH

---------------------------------------------------------

#### Generamos Contenedor Docker Para la Máquina Virtual.

Para probar esta tecnología crearemos inicialmente una máquina remota, para ello usaremos un contendor de **docker** que contendrá un servicio **SSH** a través de **centos**.

Para ello crearemos una carpeta dónde alojaremos nuestro contenedor `mkdir centos7`, para acceder `cd centos7` y posteriormente crear nuestro [Dockerfile](./Dockerfile).

```bash
demo@VirtualBox:~/Demo_Docker$ mkdir centos7
demo@VirtualBox:~/Demo_Docker$ cd centos7
demo@VirtualBox:~/Demo_Docker/centos7$
```

Incluiremos un sistema operativo de **centos:latest**.

_[Dockerfile](./Dockerfile)_
```bash
FROM centos
```

E incluiremos la instalación de **openSSH-server**.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
++ RUN yum -y install openssh-server
```

A continuación ejecutaremos los comandos necesarios para la creación de un usuario `remote_user`con un password de acceso `1234`.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

++ RUN useradd remote_user && \
++  echo "1234" | passwd remote_user  --stdin
```

Creamos el directorio del usuario `remote_user` con su `.ssh`, que será una carpeta oculta, sobre la que otorgaremos permisos 700 para que usuario `remote_user` pueda trabajar sobre ella.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

RUN useradd remote_user && \
--  echo "1234" | passwd remote_user  --stdin
++  echo "1234" | passwd remote_user  --stdin && \
++  mkdir /home/remote_user/.ssh && \
++  chmod 700 /home/remote_user/.ssh
```

Creamos **llaves ssh** para la comunicación con el contenedor.

> Nota: Es importante generar las llaves **ssh** usando el comando `ssh-keygen -f remote-key`.

```bash
demo@VirtualBox:~/Demo_Docker/centos7$ ssh-keygen -f remote-key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in remote-key.
Your public key has been saved in remote-key.pub.
The key fingerprint is:
SHA256:32PUs/dzKaQ4feXDMEf85+g7OY/9D5Dr8juRegEqs9g 
demo@VirtualBox
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|                 |
|              .  |
|          .  o o |
|        S. .+.+ .|
|      o .. o+* =o|
|     o +  +.BoX++|
|    . E  oo=o+=@+|
|          .+=+==%|
+----[SHA256]-----+
```

Se habrán generado dos nuevos archivos [remote-key](./remote-key) y [remote-key.pub](./remote-key.pub), los cuales copiaremos dentro del contenedor con el comando `COPY remote-key.pub /home/remote_user/.ssh/authorized_keys`.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "1234" | passwd remote_user  --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

++  COPY remote-key.pub /home/remote_user/.ssh/authorized_keys
```

Otorgamos permisos al usuario `remote_user` todo el contenido de la carpeta `remote_user`.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "1234" | passwd remote_user  --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

++ RUN chown remote_user:remote_user   -R /home/remote_user && \
++  chmod 600 /home/remote_user/.ssh/authorized_keys
```

Ejecutamos `/usr/sbin/sshd-keygen` cuando se genere el archivo para iniciar el servicio **ssh**.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "1234" | passwd remote_user  --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

RUN chown remote_user:remote_user   -R /home/remote_user && \
    chmod 600 /home/remote_user/.ssh/authorized_keys

++ RUN /usr/sbin/sshd-keygen > /dev/null 2>&1    
```

Finalmente nuestro **CMD** levantará el servicio.

_[Dockerfile](./Dockerfile)_
```diff
FROM centos
 
RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "1234" | passwd remote_user  --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

RUN chown remote_user:remote_user   -R /home/remote_user && \
    chmod 600 /home/remote_user/.ssh/authorized_keys

RUN /usr/sbin/sshd-keygen > /dev/null 2>&1 

++ CMD /usr/sbin/sshd -D
```

Finalmente tendremos el siguiente [Dockerfile](./Dockerfile).

_[Dockerfile](./Dockerfile)_
```diff
FROM centos

RUN yum -y install openssh-server

RUN useradd remote_user && \
    echo "1234" | passwd remote_user  --stdin && \
    mkdir /home/remote_user/.ssh && \
    chmod 700 /home/remote_user/.ssh

COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

RUN chown remote_user:remote_user   -R /home/remote_user && \
    chmod 600 /home/remote_user/.ssh/authorized_keys

RUN /usr/sbin/sshd-keygen > /dev/null 2>&1

CMD /usr/sbin/sshd -D
```

#### Modificamos nuestro Docker-Compose para utilizar la máquina virtual

Inicialmente disponíamos de la siguiente configuración para nuestro **docker-compose**

_[Dockerfile](./Dockerfile)_
```dockerfile
version: '3'
services:
    jenkins:
        container_name: jenkins 
        image: jenkins/jenkins 
        ports: 
            - "8080:8080" 
        volumes:
            - "/home/hector/jenkins-by-sample/01_Jenkins_Local/jenkins_home:/var/jenkins_home"
        networks:
            - net
networks:
    net:
```