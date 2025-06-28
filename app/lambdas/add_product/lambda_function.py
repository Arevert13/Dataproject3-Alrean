import json
import os
import boto3
import psycopg2

def lambda_handler(event, context):
    try:
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event

        name = body.get('name')
        price = body.get('price')
        description = body.get('description', '')
        if not name or not price:
            return response(400, {'error': 'name y price son campos requeridos'})

        try:
            price = float(price)
            if price <= 0:
                return response(400, {'error': 'El precio debe ser mayor que 0'})
        except (ValueError, TypeError):
            return response(400, {'error': 'Precio inválido'})

        # RDS Connection
        conn = connect_to_db()
        cursor = conn.cursor()

        # ✅ Ejecuta el schema.sql (solo crea la tabla si no existe)
        try:
            with open(os.path.join(os.path.dirname(__file__), 'schema.sql'), 'r') as f:
                schema_sql = f.read()
                cursor.execute(schema_sql)
                conn.commit()
        except Exception as e:
            print(f"Error ejecutando schema.sql: {e}")

        # ✅ Inserta el nuevo producto
        insert_query = """
            INSERT INTO productos (nombre, stock)
            VALUES (%s, %s)
            RETURNING id, nombre, stock;
        """
        cursor.execute(insert_query, (name, 10))
        new_product = cursor.fetchone()
        conn.commit()

        cursor.close()
        conn.close()

        product_data = {
            'id': new_product[0],
            'nombre': new_product[1],
            'stock': new_product[2]
        }

        return response(201, {
            'message': 'Producto añadido exitosamente',
            'product': product_data
        })

    except Exception as e:
        print(f"Error: {e}")
        return response(500, {'error': 'Error interno del servidor', 'message': str(e)})


def connect_to_db():
    db_host = os.environ.get('DB_HOST')
    db_name = os.environ.get('DB_NAME')
    db_user = os.environ.get('DB_USER')

    if not all([db_host, db_name, db_user]):
        raise Exception('Configuración de base de datos incompleta')

    if ':' in db_host:
        db_host = db_host.split(':')[0]

    try:
        rds = boto3.client('rds')
        token = rds.generate_db_auth_token(
            DBHostname=db_host,
            Port=5432,
            DBUsername=db_user
        )
        conn = psycopg2.connect(
            host=db_host,
            port=5432,
            database=db_name,
            user=db_user,
            password=token,
            sslmode='require'
        )
    except Exception as e:
        print(f"Fallo con IAM auth: {e}")
        db_password = os.environ.get('DB_PASSWORD')
        if not db_password:
            raise
        conn = psycopg2.connect(
            host=db_host,
            port=5432,
            database=db_name,
            user=db_user,
            password=db_password,
            sslmode='require'
        )
    return conn


def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }
