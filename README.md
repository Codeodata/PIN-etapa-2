# 📌 Introducción Test Terraform 

Este proyecto automatiza la implementación de una infraestructura de servidor web en AWS utilizando Terraform. Incluye un proceso de inicialización para la gestión del estado de Terraform y la implementación principal de la infraestructura para un servidor web Apache básico.

# ⚙️ Guía de Configuración

Manualmente crear el backend (se puede automatizar, pero prefiero mantenerlo así):

#### * Un bucket de S3 para almacenar el estado de Terraform.
    bucket-terraform-lab

#### * Una tabla de DynamoDB para el bloqueo del estado. 
    La tabla debe llamarse terraformstatelock
    y debe tener el campo LockID en Clave de partición

# 🔹 Implementación de la Infraestructura

### La infraestructura se implementa automáticamente mediante GitHub Actions.

✅ Inicializa Terraform

✅ Valida la configuración

✅ Aplica los cambios

# Recursos creados por Terraform cuando hay cambios en la carpeta infra:

# Resumen de Recursos y su Función

## Provider AWS
Se configura el **proveedor AWS** para la región `us-east-1`. Esto indica a Terraform que se conecte y ejecute las configuraciones en dicha región de AWS.

## VPC
Se crea una **VPC** (Virtual Private Cloud) con el bloque CIDR `10.0.0.0/16`.  
- **DNS:** Se habilita el soporte de DNS y los nombres de host DNS, lo que facilita la resolución de nombres en la red.  
- **Etiqueta:** Se asigna la etiqueta `Name = "terraform-vpc"` para identificarla fácilmente.

## Internet Gateway (IGW)
Se crea un **Internet Gateway** y se asocia a la VPC creada.  
- **Uso:** Permite que las instancias dentro de la VPC tengan acceso a Internet y reciban tráfico desde él.

## Tabla de Rutas Principal (Consulta de Datos)
Se consulta la **tabla de rutas principal** de la VPC.  
- **Criterios:** Se identifica como la tabla que tiene `association.main = true` y cuyo `vpc-id` corresponde a la VPC creada.

## Tabla de Rutas por Defecto
Se configura la **tabla de rutas predeterminada** usando el ID obtenido de la consulta anterior para:
- **Ruta:** Agregar una ruta que envía todo el tráfico (`0.0.0.0/0`) a través del Internet Gateway.
- **Etiqueta:** Se asigna la etiqueta `Name = "Terraform-RouteTable"`.

## Zonas de Disponibilidad (AZs)
Se obtienen todas las **zonas de disponibilidad** disponibles en la región.  
- **Uso:** Esto permite distribuir los recursos en diferentes zonas, mejorando la tolerancia a fallos y la disponibilidad.

## Subnet
Se crea una **subred** en la primera zona de disponibilidad (utilizando la función `element` sobre los nombres de las AZs obtenidas).  
- **CIDR:** La subred utiliza el bloque CIDR `10.0.1.0/24` y se asocia a la VPC creada.

## Security Group
Se crea un **Security Group** asociado a la VPC, denominado `"sg"` con la descripción `"Allow TCP/80 & TCP/22"`.  
- **Reglas de ingreso (ingress):**  
  - Permite tráfico SSH (TCP puerto 22) desde cualquier origen.  
  - Permite tráfico HTTP (TCP puerto 80) desde cualquier origen.
- **Regla de egreso (egress):**  
  - Permite todo el tráfico saliente.

## Output
Se define un **output** llamado `"Webserver-Public-IP"` que devuelve la IP pública de una instancia denominada `aws_instance.webserver`.  
- **Nota:** Este output requiere que exista un recurso `aws_instance.webserver` definido en otro lugar para tener un valor asignado.

---

# Implementación Manual

🔹 Si se quiere una implementación manual, sigue estos pasos desde la carpeta `infrastructure`:

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```
(FIN) 

# Verificación de Recursos

# 🔹 Verificación del Backend de Estado

### Verificar el bucket de S3
✅ aws s3 ls | grep bucket-terraform-lab

### Verificar la tabla de DynamoDB
✅ aws dynamodb list-tables | grep terraformstatelock

# 🔹  Verificación de la Infraestructura

### Verificar la VPC
✅ aws ec2 describe-vpcs --filters "Name=tag:Name,Values=terraform-vpc"

### Verificar la instancia EC2
✅ aws ec2 describe-instances --filters "Name=tag:Name,Values=webserver" "Name=instance-state-name,Values=running"

### Probar el servidor web
✅ curl http://$(terraform output -raw Webserver-Public-IP)
