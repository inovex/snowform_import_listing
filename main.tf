terraform {
  required_providers {
    snowflake = {
      source                = "snowflakedb/snowflake"
      version               = ">= 2.1.0, < 3.0.0"
      configuration_aliases = [snowflake.sysadmin]
    }
  }
}

# Import shared databases from external Snowflake providers
resource "snowflake_shared_database" "this" {
  for_each = { for share in var.snowflake_shares : share.database_name => share }

  provider   = snowflake.sysadmin
  name       = each.value.database_name
  from_share = each.value.share_name

  lifecycle {
    # Prevent accidental deletion of imported databases
    prevent_destroy = false
  }
}

# Grant IMPORTED PRIVILEGES on shared databases to account roles
resource "snowflake_grant_privileges_to_account_role" "database_access" {
  for_each = local.database_role_grants

  provider          = snowflake.sysadmin
  privileges        = ["IMPORTED PRIVILEGES"]
  account_role_name = each.value.role_name

  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.database_name
  }

  depends_on = [snowflake_shared_database.this]
}
