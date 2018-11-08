# Jenkins | Ejercicio Final

---------------------------------------------------------

[Volver al Inicio](#jenkins--ejercicio-final)


## ACTUALIZAMOS EL PIPELINE CON EL NUEVO SCRIPT

---------------------------------------------------------

A partir de este punto sería interesante crear una máquina virtual que nos permita trabajar simulando el proceso remoto.

_[Dockerfile](Dockerfile)_
```dockerfile

```

Para construir la imagen ejecutaremos el comando, `docker build -t eg_sshd .`.

```bash
demo@VirtualBox:~/Demo_Docker/eg_ssh$ docker build -t eg_sshd .
```

Para arrancar el **contenedor** usaremos el comando `docker run -d -P --name test_sshd eg_sshd`, y cambiaremos el puerto del contenedor creado mediante el comando `docker port test_sshd 22`.

```bash
demo@VirtualBox:~/Demo_Docker/eg_ssh$ docker run -d -P --name test_sshd eg_sshd
8c70280148513e699e25770206cb09385403d161475c34871783a95d0b088762

demo@VirtualBox:~/Demo_Docker/eg_ssh$ docker port test_sshd 22
0.0.0.0:32768
```

Finalmente podremos acceder a nuestra máquina remota conociendo la ip de acceso del contenedor a través del comando `docker inspect test_sshd` (mediante `"Gateway": "172.17.0.1"`) más la respuesta del comando anterior que muestra el puerto generado, quedando el comando de acceso **ssh** así `ssh root@172.17.0.1 -p 32768` (El password de acceso es : **screencast**).

```bash
demo@VirtualBox:~/Demo_Docker/eg_ssh$ docker inspect test_sshd
               "bridge": {
// ...
                    "EndpointID":"a4b00e11a22b97dfef64031bf931b587a123ed56de73629ca04305617c026e1b",
                    "Gateway": "172.17.0.1",
// ...
]

demo@VirtualBox:~/Demo_Docker/eg_ssh$ ssh root@172.17.0.1 -p 32768

The authenticity of host '[172.17.0.1]:32768 ([172.17.0.1]:32768)' can't be established.
ECDSA key fingerprint is SHA256:AQenZg1GQyckY97zhqK9ipa54w6UoNOmOhTd9/WtbTc.
Are you sure you want to continue connecting (yes/no)? yes

# The password is ``screencast``.

root@f38c87f2a42d:/#
``` 

[Volver al Inicio](#jenkins--ejercicio-final)

* [https://github.com/stefanprodan/jenkins](https://github.com/stefanprodan/jenkins)