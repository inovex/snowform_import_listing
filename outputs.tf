output "shared_databases" {
  description = "Map of imported shared databases with their configurations"
  value       = snowflake_shared_database.this
}

output "database_names" {
  description = "List of imported database names"
  value       = [for db in snowflake_shared_database.this : db.name]
}

output "granted_privileges" {
  description = "Map of privilege grants to account roles"
  value       = snowflake_grant_privileges_to_account_role.database_access
}
