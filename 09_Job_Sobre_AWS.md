---------------------------------------------------------

### Job Sobre AWS

---------------------------------------------------------

#### Notas imporantes ejemplo

> **NOTA IMPORTANTE**: Ejecutaremos `docker-compose build`cada vez que modifiquemos la configuración para reconstruir nuestro servicio.

> **NOTA**: Antes de comenzar revisar que servicios estan conectados `docker ps` y en caso de existir contenedores abiertos cerrarlos, `docker rm -fv <conatiner-name>`

En este jobs tomaremos un backup de nuestra base de datos para subirlo a **S3**.

#### Inicio ejemplo

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

> **NOTA IMPORTANTE**: Ejecutaremos `docker-compose build`cada vez que modifiquemos la configuración para reconstruir nuestro servicio.

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

> **NOTA IMPORTANTE**: Ejecutaremos `docker-compose build`cada vez que modifiquemos la configuración para reconstruir nuestro servicio.

> **NOTA**: en nuestro caso como no se generó todavía usaremos `docker-compose up -d`.

---------------------------------------------

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

---------------------------------------------

#### Crear Base de Datos MySQL

Accedemos a la terminal del contenedor del host remoto **remote-host**, `docker exec -ti remote-host bash`, para ejecutar un ping `ping db_host`.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti remote-host bash
[root@5e24a44906ea /]# ping db_host
PING db_host (192.168.128.2) 56(84) bytes of data.
64 bytes from db.03_jenkins_aws_net (192.168.128.2): icmp_seq=1 ttl=64 time=0.094 ms
64 bytes from db.03_jenkins_aws_net (192.168.128.2): icmp_seq=2 ttl=64 time=0.048 ms
```

Desde aquí accederemos al host de la base de datos `mysql -u root -h db_host -p` con el usuario root e introducidos el password (`1234`).

```bash
[root@5e24a44906ea /]# mysql -u root -h db_host -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.24 MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]>
```

Mostramos las bases de datos existentes, `show databases;` 

```bash
MySQL [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.01 sec)

MySQL [(none)]>
```

Y creamos una nueva base de datos, `create database testdb;` y cambiamos de usuario `use testdb`.

```bash
MySQL [(none)]> create database testdb;
Query OK, 1 row affected (0.00 sec)

MySQL [(none)]> use testdb
Database changed
```

Añadimos la tabla **info**, con varias columnas, `create table info (name varchar (20), lastname varchar(20), age int(2));`.

```bash
MySQL [testdb]> create table info (name varchar (20), lastname varchar(20), age int(2));
Query OK, 0 rows affected (0.02 sec)
```

Para ahora mostrar la tabla creada `show table;`

```bash
MySQL [testdb]> show tables;
+------------------+
| Tables_in_testdb |
+------------------+
| info             |
+------------------+
1 row in set (0.00 sec)
```

Y su contenido `desc info`.

```bash
MySQL [testdb]> desc info;
+----------+-------------+------+-----+---------+-------+
| Field    | Type        | Null | Key | Default | Extra |
+----------+-------------+------+-----+---------+-------+
| name     | varchar(20) | YES  |     | NULL    |       |
| lastname | varchar(20) | YES  |     | NULL    |       |
| age      | int(2)      | YES  |     | NULL    |       |
+----------+-------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

MySQL [testdb]>
``` 

Creamos una entrada en esa tabla, `insert into info values ('ricardo', 'gonzalez', 21);`, y la mostramos `select * from info;`.

```bash
MySQL [testdb]> select * from info;
Empty set (0.00 sec)

MySQL [testdb]> insert into info values ('ricardo', 'gonzalez', 21);
Query OK, 1 row affected (0.00 sec)

MySQL [testdb]> select * from info;
+---------+----------+------+
| name    | lastname | age  |
+---------+----------+------+
| ricardo | gonzalez |   21 |
+---------+----------+------+
1 row in set (0.01 sec)

MySQL [testdb]>
```

#### Crear Bucket S3 Amazon

