CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    descripcion TEXT,
    disponible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO productos (nombre, precio, descripcion) VALUES
    ('Producto 1', 10.0, 'Ejemplo 1'),
    ('Producto 2', 20.0, 'Ejemplo 2');

CREATE PUBLICATION ecommerce_pub FOR TABLE productos;
SELECT pg_create_logical_replication_slot('ecommerce_slot', 'pgoutput');