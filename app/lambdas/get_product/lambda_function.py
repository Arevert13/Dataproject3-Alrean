import json
import os
import psycopg2
import boto3


def lambda_handler(event, context):
    """Retrieve all products from the database"""
    try:
        db_host = os.environ.get('DB_HOST')
        db_name = os.environ.get('DB_NAME')
        db_user = os.environ.get('DB_USER')
        if not all([db_host, db_name, db_user]):
            return {
                'statusCode': 500,
                'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Configuración de base de datos incompleta'})
            }

        if ':' in db_host:
            db_host = db_host.split(':')[0]

        try:
            rds = boto3.client('rds')
            token = rds.generate_db_auth_token(DBHostname=db_host, Port=5432, DBUsername=db_user)
            conn = psycopg2.connect(host=db_host, port=5432, database=db_name, user=db_user, password=token, sslmode='require')
        except Exception as e:
            print(f"Error conectando con IAM auth: {e}")
            db_password = os.environ.get('DB_PASSWORD')
            if not db_password:
                raise
            conn = psycopg2.connect(host=db_host, port=5432, database=db_name, user=db_user, password=db_password, sslmode='require')

        cursor = conn.cursor()
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

        cursor.execute("SELECT id, name, price, description, available, created_at FROM products ORDER BY id;")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        products = []
        for row in rows:
            products.append({
                'id': row[0],
                'name': row[1],
                'price': float(row[2]),
                'description': row[3],
                'available': row[4],
                'created_at': row[5].isoformat() if row[5] else None
            })

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'products': products})
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': 'Error interno del servidor', 'message': str(e)})
        }