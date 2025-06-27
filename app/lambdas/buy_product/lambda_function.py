import json
import os
import boto3
import psycopg2

def lambda_handler(event, context):
    try:
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event

        product_id = body.get('id')
        if not product_id:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'id es requerido'})
            }

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
        cursor.execute("UPDATE products SET available = false WHERE id = %s RETURNING id, name, price, description, available, created_at;", (product_id,))
        updated = cursor.fetchone()
        conn.commit()

        cursor.close()
        conn.close()

        if not updated:
            return {
                'statusCode': 404,
                'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Producto no encontrado'})
            }

        product_data = {
            'id': updated[0],
            'name': updated[1],
            'price': float(updated[2]),
            'description': updated[3],
            'available': updated[4],
            'created_at': updated[5].isoformat() if updated[5] else None
        }

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'Producto comprado', 'product': product_data})
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': 'Error interno del servidor', 'message': str(e)})
        }