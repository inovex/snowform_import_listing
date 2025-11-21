# Snowflake Shared Database Import Module

A Terraform module for importing Snowflake shares as databases and granting access privileges to account roles.

## Overview

This module simplifies the process of:
- Importing external Snowflake shares as databases in your account
- Automatically granting `IMPORTED PRIVILEGES` to specified account roles
- Managing multiple shares and role grants through a single configuration

## Prerequisites

- Terraform >= 1.0
- Snowflake provider >= 2.1.0, < 3.0.0
- Access to Snowflake with appropriate privileges (SYSADMIN role)
- Approved access to the shares you want to import

## Usage

### Basic Example

```hcl
module "snowflake_shared_databases" {
  source  = "gitlab.dm-drogeriemarkt.com/tech-erp/snowflake-import-listing/local"
  version = "0.0.13"

  providers = {
    snowflake.sysadmin      = snowflake.sysadmin
  }

  snowflake_shares = [
    {
      database_name = "IMPORTED_DB_NAME"
      share_name    = "YOUR_ORG.SOME_ACCOUNT.SHARE_NAME"
    },
  ]

  account_roles = [
    "ANALYST_ROLE",
    "DATA_ENGINEER_ROLE",
  ]
}
```

### Multiple Shares Example

```hcl
module "snowflake_shared_databases" {
  source  = "gitlab.dm-drogeriemarkt.com/tech-erp/snowflake-import-listing/local"
  version = "0.0.13"

  providers = {
    snowflake.sysadmin      = snowflake.sysadmin
  }

  snowflake_shares = [
    {
      database_name = "CUSTOMER_DATA_SHARE"
      share_name    = "PROVIDER_ORG.PROVIDER_ACCOUNT.CUSTOMER_SHARE"
    },
    {
      database_name = "PRODUCT_DATA_SHARE"
      share_name    = "PROVIDER_ORG.PROVIDER_ACCOUNT.PRODUCT_SHARE"
    },
  ]

  account_roles = [
    "ANALYST_ROLE",
    "DATA_ENGINEER_ROLE",
    "BI_DEVELOPER_ROLE",
  ]
}
```

## How to Import New Listings/Shares

### Step 1: Request Access to a Share

1. Navigate to **Data Products** > **Private Sharing** in the Snowflake Web UI
2. Search for the relevant listing
3. Click the **Request** button to request access

### Step 2: Monitor Request Status

1. Go to **Data Products** > **Private Sharing** > **Requests** > **Outbound**
2. Monitor the status of your request
3. Wait for the status to change to **Approved**

### Step 3: Find the Share Name

Once approved, execute the following SQL query in a Snowflake worksheet:

```sql
SHOW SHARES;
```

The full share name is constructed by concatenating the `owner_account` and `name` columns:

```
<owner_account>.<name>
```

For example: `ACME_ORG.XY12345.SALES_DATA_SHARE`

### Step 4: Add to Module Configuration

Add the share to your module configuration:

```hcl
snowflake_shares = [
  {
    database_name = "SALES_DATA"  # Your desired database name
    share_name    = "ACME_ORG.XY12345.SALES_DATA_SHARE"  # From SHOW SHARES
  },
]
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| snowflake_shares | List of Snowflake shares to import as databases | `list(object({ database_name = string, share_name = string }))` | Example values provided | yes |
| account_roles | List of Snowflake account roles that will be granted IMPORTED PRIVILEGES | `list(string)` | `["EXAMPLE_ROLE_1"]` | yes |

## Outputs

| Name | Description |
|------|-------------|
| shared_databases | Map of imported shared databases with their configurations |
| database_names | List of imported database names |
| granted_privileges | Map of privilege grants to account roles |

## How It Works

1. **Database Import**: For each share in `snowflake_shares`, the module creates a `snowflake_shared_database` resource
2. **Privilege Grants**: The module creates a cartesian product of all shares and roles, then grants `IMPORTED PRIVILEGES` on each database to each role
3. **Access Control**: Roles specified in `account_roles` can immediately query the imported databases

## Validation Rules

- At least one share must be specified
- At least one account role must be specified
- Database names must contain only uppercase letters, numbers, and underscores

## Notes

- The module uses the `snowflake.sysadmin` provider for all operations
- `IMPORTED PRIVILEGES` is the standard privilege for accessing shared databases
- Changes to shares or roles will automatically update the privilege grants
- Database names should follow Snowflake naming conventions (uppercase with underscores)

## License

See LICENSE file for details.
