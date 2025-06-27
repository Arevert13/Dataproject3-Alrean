resource "google_bigquery_dataset" "ecommerce_analytics" {
  dataset_id  = "ecommerce_analytics"
  location    = var.region
  project     = var.project_id
  description = "Dataset para replicación RDS y análisis en Looker"

  labels = {
    proyecto = var.project_name
  }
}

resource "google_datastream_connection_profile" "rds_source" {
  connection_profile_id = "rds-source"
  location              = var.region
  project               = var.project_id
  display_name          = "AWS RDS PostgreSQL Source"

  postgresql_profile {
    hostname = var.rds_host
    port     = 5432
    username = var.datastream_user
    password = var.datastream_password
    database = var.db_name
  }
}

resource "google_datastream_connection_profile" "bq_sink" {
  connection_profile_id = "bq-sink"
  location              = var.region
  project               = var.project_id
  display_name          = "BigQuery Sink"

  bigquery_profile {}
}

resource "google_datastream_stream" "rds_to_bq" {
  stream_id    = "rds-to-bq"
  location     = var.region
  project      = var.project_id
  display_name = "Replicación RDS a BigQuery"

  source_config {
    source_connection_profile = google_datastream_connection_profile.rds_source.id

    postgresql_source_config {
      include_objects {
        postgresql_schemas {
          schema = "public"
          postgresql_tables {
            table = "products"
          }
        }
      }
      publication                   = var.publication
      replication_slot              = var.replication_slot
      max_concurrent_backfill_tasks = 4
    }
  }

destination_config {
  destination_connection_profile = google_datastream_connection_profile.bq_sink.id
  bigquery_destination_config {
    single_target_dataset {
      dataset_id = "projects/${var.project_id}/datasets/${google_bigquery_dataset.ecommerce_analytics.dataset_id}"
    }
  }
}



  backfill_all {}

  depends_on = [
    google_datastream_connection_profile.rds_source,
    google_datastream_connection_profile.bq_sink
  ]
}

resource "google_bigquery_table" "public_products" {
  dataset_id = google_bigquery_dataset.ecommerce_analytics.dataset_id
  table_id   = "public_products"
  project    = var.project_id

  schema = jsonencode([
    { name = "id", type = "STRING", mode = "REQUIRED" },
    { name = "name", type = "STRING", mode = "REQUIRED" },
    { name = "price", type = "FLOAT", mode = "REQUIRED" },
    { name = "description", type = "STRING", mode = "NULLABLE" },
    { name = "available", type = "BOOLEAN", mode = "REQUIRED" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" }
  ])

  deletion_protection = false
}
resource "google_bigquery_table" "products_analytics" {
  dataset_id = google_bigquery_dataset.ecommerce_analytics.dataset_id
  table_id   = "products_analytics"
  project    = var.project_id

  deletion_protection = false

  view {
    query = <<EOT
SELECT 
  id,
  name,
  price,
  description,
  available,
  created_at,
  CASE 
    WHEN available THEN 'Disponible'
    ELSE 'Agotado'
  END as estado,
  CASE
    WHEN price < 20 THEN 'Barato'
    WHEN price < 50 THEN 'Medio'
    ELSE 'Caro'
  END as categoria_precio
FROM `${var.project_id}.${google_bigquery_dataset.ecommerce_analytics.dataset_id}.public_products`
EOT

    use_legacy_sql = false
  }
}
