variable "account_roles" {
  type        = list(string)
  description = "List of Snowflake account roles that will be granted IMPORTED PRIVILEGES on the shared databases"
  default = [
    "EXAMPLE_ROLE_1",
  ]

  validation {
    condition     = length(var.account_roles) > 0
    error_message = "At least one account role must be specified."
  }
}

variable "snowflake_shares" {
  type = list(object({
    database_name = string
    share_name    = string
  }))
  description = <<-EOT
    List of Snowflake shares to import as databases.
    - database_name: The name for the imported database in your account
    - share_name: The full share identifier in format: PROVIDER_ORG.PROVIDER_ACCOUNT.SHARE_NAME
  EOT
  default = [
    { database_name = "IMPORTED_DB_NAME", share_name = "YOUR_ORG.SOME_ACCOUNT.SHARE_NAME" },
  ]

  validation {
    condition     = length(var.snowflake_shares) > 0
    error_message = "At least one share must be specified."
  }

  validation {
    condition = alltrue([
      for share in var.snowflake_shares : can(regex("^[A-Z0-9_]+$", share.database_name))
    ])
    error_message = "Database names must contain only uppercase letters, numbers, and underscores."
  }
}

locals {
  # Create a flat list with all combinations of shares and roles for granting privileges
  database_role_combinations = flatten([
    for share in var.snowflake_shares : [
      for role in var.account_roles : {
        share_name    = share.share_name
        database_name = share.database_name
        role_name     = role
      }
    ]
  ])

  # Convert the list to a map for use in for_each loops
  database_role_grants = {
    for combination in local.database_role_combinations :
    "${combination.database_name}_${combination.role_name}" => combination
  }
}
