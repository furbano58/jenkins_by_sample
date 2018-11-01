---------------------------------------------------------

### Job Sobre AWS

---------------------------------------------------------

> **NOTA**: Antes de comenzar revisar que servicios estan conectados `docker ps` y en caso de existir contenedores abiertos cerrarlos, `docker rm -fv <conatiner-name>`

En este jobs tomaremos un backup de nuestra base de datos para subirlo a **S3**.

Para ello cogeremos el ejemplo anterior e incluiremos un nuevo servicio de base de datos:

[docker-compose.yml](./docker-compose.yml)
```diff
version: '3'
services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins
    ports:
      - "8080:8080"
    volumes:
      - $PWD/jenkins_home:/var/jenkins_home
    networks:
      - net
  remote_host:
    container_name: remote-host
    image: remote-host
    build:
      context: centos7
    volumes:
      - $PWD/aws-s3.sh:/tmp/script.sh
    networks:
      - net
++ db_host:
++   container_name: db
++   image: mysql:5.7
++   environment:
++     - "MYSQL_ROOT_PASSWORD=1234"
++   volumes:
++     - $PWD/db_data:/var/lib/mysql
++   networks:
++     - net
networks:
  net:
```

Para ejecutar el servicio volveremos a necesitar crear nuestra carpeta de para **jenkins** (**jenkins_home**) `mkdir jenkins_home` y le añadimos los permisos necesarios `chown 1000 -R jenkins_home`. Más la carpeta que alojará el contenedor de la base de datos **db_data** `mkdir db_data` y le añadimos los permisos necesarios `chown 1000 -R db_data`.

```bash
demo@VirtualBox:~/Demo_Docker$ mkdir jenkins_home
demo@VirtualBox:~/Demo_Docker$ mkdir db_data

demo@VirtualBox:~/Demo_Docker$ sudo su
[sudo] password for demo:

root@VirtualBox:~/Demo_Docker$ chown 1000 -R jenkins_home
root@VirtualBox:~/Demo_Docker$ chown 1000 -R db_data
```

Ya podríamos ejecutar el comando `docker-compose up -d`.

Ahora comprobaremos que los contenedores estan activos `docker ps` y que podremos observar el estado de la base de datos mediante `docker logs -f db`.

```bash
demo@VirtualBox:~/Demo_Docker$ docker ps
CONTAINER ID IMAGE       COMMAND  CREATED STATUS  PORTS     NAMES
5c50cb7aada0 remote-host "/bin…"  8 min…  Up 8 …            remote-host
09ce75629029 mysql:5.7   "dock…"  8 min…  Up 8 …  3306/tc…  db
dceff31c557f jenkins/j…  "/sbi…"  8 min…  Up 8 …  0.0.0.0…  jenkins

demo@VirtualBox:~/Demo_Docker$ docker logs -f db
2018-11-01T12:07:29.636511Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
// ...
2018-11-01T12:07:30.293411Z 0 [Note] mysqld: ready for connections.
Version: '5.7.24'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
```

Si accedemos al contenedor de la base de datos **db**, `docker exec -ti db bash` y ejecutamos `mysql -u root -p` (password: `1234`) podremos acceder a la base de datos que se ha creado.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti db bash
root@09ce75629029:/# mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
// ...
```

#### Instalar MySQL Cliente y AWS CLI

Para conectarnos a la **Base de Datos** tendremos que incluir el **cliente de MySQL**, mientras que para conectarnos a **s3** necesitaremos **AWS CLI**. Lo incluiremos dentro de [Dockerfile](./Dockerfile).

Source : 
* [https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)
* [https://docs.aws.amazon.com/cli/latest/userguide/installing.html](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/](https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/)

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

++ RUN yum -y install mysql

++ RUN yum -y install epel-release && \
++     yum -y install python-pip && \
++     pip install --upgrade pip && \
++     pip install awscli

CMD /usr/sbin/sshd -D
```

Una vez modificado utilizaremos el comando `docker-compose build` para reconstruir el servicio.

> **NOTA**: en nuestro caso como no se generó todavía usaremos `docker-compose up -d`.

> **NOTA**: Al haber iniciado una nueva instalación deberemos obtener el password de administrador con el comando de consola `docker exec -ti jenkins bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"`.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti jenkins bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
c3aab8f70884458aa8d12f89d6ddfacb
```

Y accederemos al contenido de la llave para incluirlo dentro de la credencial.

> **NOTA**: Instalar plugin **SSH**, crear la credencial mediante la llave, y **configurar jenkins** para usar el host remoto.
> Para ello es necesario copiar la llave generada dentro del contenedor mediante `docker cp remote-key jenkins:/tmp`, para posteriormente borrarla (Dentro de la carpeta de centos7).

```bash
demo@VirtualBox:~/Demo_Docker$ docker cp remote-key jenkins:/tmp
```