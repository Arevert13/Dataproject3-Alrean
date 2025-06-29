-- crea tabla y datos
CREATE TABLE IF NOT EXISTS productos (
  id     SERIAL PRIMARY KEY,
  nombre TEXT   NOT NULL,
  stock  INTEGER NOT NULL DEFAULT 0
);
INSERT INTO productos (nombre, stock) VALUES
  ('Cien años de soledad',      10),
  ('Don Quijote de la Mancha',   5),
  ('Ficciones',                  8)
ON CONFLICT DO NOTHING;

-- crea publication si no existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'my_publication') THEN
    CREATE PUBLICATION my_publication FOR ALL TABLES;
  END IF;
END
$$;

-- crea replication slot si no existe
SELECT slot_name
FROM pg_replication_slots
WHERE slot_name = 'my_slot'
UNION ALL
SELECT (pg_create_logical_replication_slot('my_slot','pgoutput')).slot_name
WHERE NOT EXISTS (
  SELECT 1 FROM pg_replication_slots WHERE slot_name = 'my_slot'
);
