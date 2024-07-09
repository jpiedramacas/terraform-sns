1. Hacerlo manual
  a. En la consola de AWS, en IAM el role LabRole debemos asociar dos politicas (AmazonSNSFullAccess y AWSLambda_FullAccess)
  b. Cuando se crea el EC2 del servidor web debemos •	Añadir Rol a la EC2
	Vamos a la consola de la EC2, vamos a acciones -> seguridad -> Añadir Rol
  Elegimos el Rol “LabRole”
  c. Cuando se crea SNS y nos suelta su ARN debemos colocarlo al Submit.php  $snsTopicArn debemos sustituirlo, y tambien el la lambda_function.py debemos cambiar la URL
ef lambda_handler(event, context):
    url = "https://hooks.slack.com/services/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"
Esta parte debemos cambiarlo manualmente

3. Tree
   Explicacion de que hace cada archivo de configuracion

4. Explicacion de como se comunica o como funciona la conexion entre ellos 
   
