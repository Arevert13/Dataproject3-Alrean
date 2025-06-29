# Dataproject3-Alrean
# Data Project 3 - E-commerce Híbrido

Este repositorio contiene un ejemplo didáctico de portal de compras basado en una arquitectura híbrida entre **AWS** y **GCP**. El objetivo es ilustrar cómo se pueden combinar servicios de ambos proveedores para construir una aplicación moderna, escalable y fácilmente analizable.

La solución implementa funciones **AWS Lambda** para manejar productos, una base de datos **PostgreSQL** en RDS y un frontend **Flask** que se despliega en Cloud Run. La información de productos se replica de forma continua a **BigQuery** para permitir consultas analíticas en tiempo real.

## Arquitectura

- **AWS**
  - Amazon RDS PostgreSQL almacena la información de productos.
  - Tres funciones **Lambda** (`get_product`, `add_product` y `buy_product`) exponen operaciones de lectura y escritura.
  - **API Gateway** publica estas funciones como endpoints HTTP.
- **GCP**
  - **Cloud Run** ejecuta el frontend escrito en Flask que consume el API Gateway.
  - **BigQuery** recibe una replicación en tiempo real de la tabla de productos mediante Datastream para fines analíticos.
- **Terraform** orquesta toda la infraestructura en ambos proveedores.

## Estructura del repositorio

- `app/flask/` &ndash; Código del frontend Flask y su `Dockerfile`.
- `app/lambdas/` &ndash; Código fuente de las funciones Lambda.
- `terraform/` &ndash; Módulos e implementación de infraestructura.
- `package_lambdas.sh` &ndash; Script que empaqueta cada Lambda en archivos ZIP listos para desplegar.

## Prerrequisitos

Antes de desplegar es necesario contar con:

- Python 3.10 o superior.
- [Terraform](https://www.terraform.io/) instalado.
- CLI de AWS y GCP configurados con credenciales y proyectos adecuados.
- Una cuenta en AWS con permisos para Lambda, API Gateway y RDS.
- Un proyecto de GCP habilitado para Cloud Run y BigQuery.

## Despliegue rápido

1. Clona este repositorio y empaqueta las funciones Lambda:
   ```bash
   git clone <este_repo>
   cd Dataproject3-Alrean
   ./package_lambdas.sh
   ```
2. Configura las variables en `terraform.tfvars` o mediante variables de entorno.
3. Inicializa y aplica la infraestructura con Terraform:
   ```bash
   terraform init
   terraform apply
   ```
4. Una vez completado el despliegue, encontrarás la URL del API Gateway y del servicio en Cloud Run en los mensajes de salida.

## Uso local

Para realizar pruebas en tu máquina puedes ejecutar el frontend de forma local:
```bash
cd app/flask
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
FLASK_DEBUG=True API_GATEWAY_URL=<url_del_gateway> python app.py
```
Reemplaza `<url_del_gateway>` por el endpoint que muestra Terraform. La app quedará disponible en `http://localhost:8080`.