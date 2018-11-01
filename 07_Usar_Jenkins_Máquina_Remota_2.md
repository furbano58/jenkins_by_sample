---------------------------------------------------------

### Usar Jenkins en Una Máquina Remota Vía SSH | Parte 2

---------------------------------------------------------

Ahora tendremos que configurar **jenkins** para que utilice dicha llave de autentificación.

Para ello con el contenedor ejecutándose, accederemos a [http://localhost:8080/](http://localhost:8080/).

> **NOTA**: Al haber iniciado una nueva instalación deberemos obtener el password de administrador con el comando de consola `docker exec -ti jenkins bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"`.

```bash
demo@VirtualBox:~/Demo_Docker$ docker exec -ti jenkins bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
c3aab8f70884458aa8d12f89d6ddfacb
```

Una vez dentro de **jenkins** accederemos a **Administrar jenkins** > **Administrar plugins** y seleccionaremos la opción de 

![./img/00036.png](./img/0036.png)