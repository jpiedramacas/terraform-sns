

## 1. Configuración Manual

### a. Asociar Políticas al Rol `LabRole` en IAM

1. **Inicie sesión en la consola de AWS**:
   - Acceda a la consola de administración de AWS

2. **Navegue a IAM (Identity and Access Management)**:
   - En la barra de búsqueda, escriba `IAM` y seleccione IAM para acceder a su consola.

3. **Seleccione Roles**:
   - En el panel de navegación izquierdo, haga clic en `Roles`.

4. **Busque y seleccione el rol `LabRole`**:
   - En la lista de roles, busque `LabRole` y haga clic en él para abrir los detalles del rol.

5. **Adjunte las políticas necesarias**:
   - En la pestaña `Permissions`, haga clic en el botón `Attach policies`.
   - Use la barra de búsqueda para encontrar `AmazonSNSFullAccess`.
   - Marque la casilla junto a `AmazonSNSFullAccess` y repita el proceso para `AWSLambda_FullAccess`.
   - Haga clic en el botón `Attach policy` para adjuntar las políticas seleccionadas al rol.

### b. Añadir Rol a la Instancia EC2

1. **Inicie sesión en la consola de AWS**:
   - Acceda a la consola de administración de AWS

2. **Navegue a la consola EC2**:
   - En la barra de búsqueda, escriba `EC2` y seleccione EC2 para acceder a su consola.

3. **Seleccione su instancia EC2**:
   - En el panel de navegación izquierdo, haga clic en `Instances` y seleccione la instancia que desea modificar.

4. **Modificar el rol de la instancia**:
   - Con la instancia seleccionada, haga clic en el botón `Actions`, luego en `Security`, y finalmente en `Modify IAM role`.
   - En el menú desplegable `IAM role`, seleccione `LabRole`.
   - Haga clic en el botón `Update IAM role` para aplicar el cambio.

### c. Configurar ARN en `submit.php` y URL en `lambda_function.py`

1. **Actualizar `submit.php` con el ARN del tópico SNS**:
   - Abra `submit.php` en su editor de texto preferido.
   - Encuentre la línea donde se define `$snsTopicArn` y reemplácela con el ARN de su tópico SNS:
     ```php
     $snsTopicArn = 'arn:aws:sns:us-west-2:123456789012:MyTopic';
     ```

2. **Actualizar `lambda_function.py` con la URL del webhook de Slack**:
   - Abra `lambda_function.py` en su editor de texto preferido.
   - Encuentre la línea donde se define la URL y reemplácela con la URL de su webhook de Slack:
     ```python
     def lambda_handler(event, context):
         url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
     ```

## 3. Estructura de Archivos

### Descripción de Archivos

```plaintext
├── index.html
├── info.php
├── install.sh
├── lambda_function.py
├── lambda_function.zip
├── main.tf
├── ssh.pem
└── submit.php
```

- **index.html**: La página principal del servidor web. Contiene la interfaz de usuario donde se presentan formularios y otra información al usuario final.

- **info.php**: Un script PHP que muestra información del servidor, como detalles de configuración y variables del entorno.

- **install.sh**: Un script de shell que automatiza la instalación y configuración del entorno del servidor web, incluyendo la instalación de Apache, PHP y otras dependencias necesarias.

- **lambda_function.py**: El código Python que define la función Lambda. Este script maneja los eventos enviados por SNS y envía notificaciones a un canal de Slack a través de un webhook.

- **lambda_function.zip**: Un archivo comprimido que contiene `lambda_function.py` y otras dependencias necesarias para desplegar la función Lambda en AWS.

- **main.tf**: Un archivo de configuración de Terraform que define la infraestructura como código. Incluye la definición de recursos como instancias EC2, roles de IAM, políticas, y otros recursos necesarios.

- **ssh.pem**: Un archivo de llave privada para acceso SSH a la instancia EC2. Este archivo debe mantenerse seguro y solo ser accesible para el administrador.

- **submit.php**: Un script PHP que maneja la lógica de envío de datos del formulario y publica mensajes en el tópico SNS utilizando el ARN configurado.

## 4. Comunicación y Conexiones

### Flujo de Conexión

1. **Usuario Interactúa con `index.html`**:
    - El usuario accede a la página `index.html`, que proporciona una interfaz para enviar datos mediante un formulario.

2. **Formulario en `submit.php`**:
    - Cuando el usuario envía el formulario, los datos se envían a `submit.php` mediante una solicitud HTTP POST.
    - `submit.php` procesa los datos y publica un mensaje en el tópico SNS usando el ARN configurado.

3. **Notificación SNS**:
    - SNS recibe el mensaje publicado por `submit.php` y lo distribuye a todos los suscriptores del tópico, en este caso, la función Lambda.

4. **Función Lambda**:
    - La función Lambda, definida en `lambda_function.py`, es invocada por SNS cuando recibe un nuevo mensaje.
    - La función Lambda procesa el evento y envía una notificación a Slack usando la URL del webhook configurado.

5. **Integración con Slack**:
    - La función Lambda envía la notificación a Slack, donde se muestra en el canal configurado.

### Resumen de la Comunicación

- **Servidor web (EC2)**: Maneja la interfaz de usuario (`index.html`) y la lógica del servidor (`submit.php`).
- **SNS**: Actúa como intermediario para enviar notificaciones desde el servidor web a la función Lambda.
- **Lambda**: Procesa los eventos de SNS y envía notificaciones a Slack.

Este flujo asegura que cualquier interacción del usuario en el servidor web resulte en notificaciones en tiempo real en un canal de Slack, facilitando la monitorización y respuesta rápida a los eventos.

