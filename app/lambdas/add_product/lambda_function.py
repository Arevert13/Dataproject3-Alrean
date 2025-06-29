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
        available = body.get('available', True)

        if not name or price is None:
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

        # ✅ Crea la tabla si no existe (opcional)
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            description TEXT,
            available BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)
        conn.commit()

        # ✅ Inserta el nuevo producto
        insert_query = """
            INSERT INTO products (name, price, description, available)
            VALUES (%s, %s, %s, %s)
            RETURNING id, name, price, description, available, created_at;

        """
        cursor.execute(insert_query, (name, price, description, available))
        new_product = cursor.fetchone()
        conn.commit()

        cursor.close()
        conn.close()

        product_data = {
            'id': new_product[0],
            'name': new_product[1],
            'price': float(new_product[2]),
            'description': new_product[3],
            'available': new_product[4],
            'created_at': new_product[5].isoformat() if new_product[5] else None
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
