data "external" "system_architecture" {
  program = ["${path.module}/scripts/get-system-architecture.sh"]
}

locals {
  create_table_sql_files = fileset(path.module, "statements/create-tables/*.sql")
  create_model_sql_files = fileset(path.module, "statements/create-models/*.sql")
  insert_data_sql_files  = fileset(path.module, "statements/insert/*.sql")
  system_architecture    = data.external.system_architecture.result.architecture == "arm64" ? "arm64" : "x86_64"
}