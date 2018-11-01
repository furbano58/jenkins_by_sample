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
            - "$PWD/jenkins_home:/var/jenkins_home"
        networks:
            - net
networks:
    net:
```

Ahora incluiremos la configuración necesaria para que este servicio use el contenedor **ssh** que creamos anteriormente.

_[Dockerfile](./Dockerfile)_
```diff
version: '3'
services:
    jenkins:
        container_name: jenkins 
        image: jenkins/jenkins 
        ports: 
            - "8080:8080" 
        volumes:
            - "$PWD/jenkins_home:/var/jenkins_home"
        networks:
            - net
++  remote_host:
++      container_name: remote-host
++      image: remote-host
++      build:
++          context: centos7
++      networks:
++          - net            
networks:
    net:
```

> **NOTA**: No olvidar haber creado anteriormente la carpeta **jenkins_home**, `mkdir jenkins_home`, dónde alojaremos nuestro contenedor de jenkins, y haberle otorgado permisos de ejecución `sudo chwon 1000 -R jenkins_home`.

```bash
demo@VirtualBox:~/Demo_Docker$ mkdir jenkins_home
demo@VirtualBox:~/Demo_Docker$ sudo su
[sudo] password for demo:
root@VirtualBox:~/Demo_Docker$ chown 1000 -R jenkins_home
root@VirtualBox:~/Demo_Docker$ exit
```

Finalmente lanzaremos el servicio mediante el comando de **docker-compose** `docker-compose up -d`.

```bash
demo@VirtualBox:~/Demo_Docker$ docker-compose up -d
Starting jenkins     ... done
Creating remote-host ... done
```

Si ejecutamos el comando `docker ps` podremos ver los dos contenedores que se están ejecutando:

* **remote-host** como nuestra servidor ssh.
* **jenkins** como nuestro servicio de **jenkins**.

```bash
demo@VirtualBox:~/Demo_Docker$ docker ps
CONTAINER ID IMAGE           COMMAND   CREATED   STATUS    PORTS.   NAMES
865645b9cf44 remote-host     "/bin..." About ..  Up Abou..          remote-host
594617c9c032 jenkins/jenkins "/sbi..." 6 mi...   Up Abou.. 0.0...   jenkins
```

* **¿Cómo validamos que Jenkins pueda conectarse al servidor generado mediante docker?**

Para ello usaremos el comando `docker exec -ti jenkins bash -c "ping remote_host"`

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti jenkins bash -c "ping remote_host"
PING remote_host (172.19.0.3) 56(84) bytes of data.
64 bytes from remote-host.02_jenkins_server_ssh_net (172.19.0.3): icmp_seq=1 ttl=64 time=0.117 ms
64 bytes from remote-host.02_jenkins_server_ssh_net (172.19.0.3): icmp_seq=2 ttl=64 time=0.074 ms
64 bytes from remote-host.02_jenkins_server_ssh_net (172.19.0.3): icmp_seq=3 ttl=64 time=0.057 ms
64 bytes from remote-host.02_jenkins_server_ssh_net (172.19.0.3): icmp_seq=4 ttl=64 time=0.055 ms
^C
--- remote_host ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3066ms
rtt min/avg/max/mdev = 0.055/0.075/0.117/0.027 ms

demo@VirtualBox:~/Demo_Docker$
```

Si nos conectamos desde **jenkins** mediante **ssh**, `ssh remote_user@remote_host`, veremos el siguiente resultado.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti jenkins bashjenkins@594617c9c032:/$ ssh remote_user@remote_host
The authenticity of host 'remote_host (172.19.0.3)' can't be established.
ECDSA key fingerprint is SHA256:F5R+9HPGON+uv1TTDl+jmnEgkxe/m2WpYnqFhvpIWV0.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'remote_host,172.19.0.3' (ECDSA) to the list of known hosts.
remote_user@remote_host's password:
[remote_user@865645b9cf44 ~]$
```

> **NOTA**: **remote_user** es el usuario definido anteriormente y **remote_host** el host de acceso.

Para salir del contenedor usaremos los siguientes comandos, `exit` para salir del usuario y `exit` para salir del contenedor.

```bash
[remote_user@865645b9cf44 ~]$ exit
logout
Connection to remote_host closed.

jenkins@594617c9c032:/$ exit
exit

demo@VirtualBox:~/Demo_Docker$
```

* **¿Cómo podríamos conectarnos usando las llaves generadas?**

Pra ello es necesario copiar la llave generada dentro del contenedor mediante `docker cp remote-key jenkins:/tmp`, para posteriormente borrarla (Dentro de la carpeta de centos7).

```bash
demo@VirtualBox:~/Demo_Docker$ docker cp remote-key jenkins:/tmp
```

Accedemos al contenedor `docker exec -ti jenkins bash`, para comprobar que se encuentra la llave dentro de la carpeta **tmp**.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti jenkins bash
jenkins@594617c9c032:/$ cd tmp
jenkins@594617c9c032:/tmp$ ls
hsperfdata_jenkins                                    jna--1712433994
hsperfdata_root                                       remote-key
jetty-0.0.0.0-8080-war-_-any-2061485573331116894.dir  winstone6803440211979766254.jar
```

Y ejecutamos el comando anterior para conectarse vía **ssh** incluyendo dicha llave, `ssh -i remote-key remote_user@remote_host`.

```bash
jenkins@594617c9c032:/tmp$ ssh -i remote-key remote_user@remote_host
Last login: Thu Nov  1 10:37:56 2018 from jenkins.02_jenkins_server_ssh_net
[remote_user@865645b9cf44 ~]$
```

Ya estaremos conectados a nuestro servidor.

**CON Jenkins HAREMOS LO MISMO**