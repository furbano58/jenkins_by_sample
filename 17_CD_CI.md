La idea del CI (**Continuous Integration**) / CD (**Continuous Delivery** / CD (**Continuous Deployment**) se basa en la automatización de parte del desarrollo en una aplicación entendiendo como desarrollo, su construcción, testeo, subida al repositorio de artefacts, descarga por parte del resto de desarrolladores del proyecto, y subida al servidor final.

## CONTINUOUS INTEGRATION o  INTEGRACIÓN CONTINUA

**¿Qué es Continuous Integration?** Es el primer **Stage** o primer paso, en el que nuestro código va a estar viviendo.

Imaginemos que avanzamos en nuestro código, y realizamos un nuevo commit, el cuál debería desembocar en test unitarios que finalmente nos aseguren el correcto funcionamiento de nuestro **Artefact**.

**¿Qué es el artifact?** Es el resultado de la compilación del código.

**¿Cuando pasamos al siguiente Stage** Si una vez hicimos el commit, compilado el mismo y evaluado mediante el testing el correcto funcionamiento pasaríamos al **Continuous Delivery**. 

> **NOTA**: En caso de durante dicho proceso se detestase un error, se gatillearía **Jenkins** para notificar el problema.


## CONTINUOUS DELIVERY o ENTREGA CONTINUA

Consiste en un espacio intermedio, dónde se despliegan los artefacts en un entorno intermedio que nos permita hacer test más avanzados.

> **NOTA**: En caso de que ocurriera un error en este entorno el **stage** moriría y debería notificarse.


## CONTINUOUS DEPLOYMENT o DESPLIEGUE CONTINUA

Como última paso se desplegaría el proyecto en **Producción** para su uso aportando feedback finl sobre nuevos cambios y poder así reiniciar el proyecto con nuevas funcioanlidades.

