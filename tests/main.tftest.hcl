
variables {
  snowflake_shares = [
    { database_name = "IMPORTED_TEST_SHARE_1", share_name = "mock_path_to_test_share_1" },
    { database_name = "IMPORTED_TEST_SHARE_2", share_name = "mock_path_to_test_share_2" }
  ]
  account_roles = ["TEST_ROLE_1", "TEST_ROLE_2"]
}

mock_provider "snowflake" {
  alias = "mockprovider"
}

run "test_create_import_shares" {

  command = plan
  providers = {
    snowflake.sysadmin = snowflake.mockprovider
  }
  assert {
    condition     = snowflake_shared_database.this["IMPORTED_TEST_SHARE_1"].name == "IMPORTED_TEST_SHARE_1"
    error_message = "The database name is not as expected"
  }
  assert {
    condition     = snowflake_shared_database.this["IMPORTED_TEST_SHARE_2"].from_share == "mock_path_to_test_share_2"
    error_message = "The share name is not as expected"
  }
  assert {
    condition     = length(snowflake_shared_database.this) == 2
    error_message = "Number of imported shares is not as expected"
  }
}

run "test_role_grants_import_shares" {

  command = plan
  providers = {
    snowflake.sysadmin = snowflake.mockprovider
  }
  assert {
    condition     = snowflake_grant_privileges_to_account_role.database_access["IMPORTED_TEST_SHARE_1_TEST_ROLE_1"].on_account_object[0].object_name == "IMPORTED_TEST_SHARE_1"
    error_message = "The role is not assigned properly"
  }

  assert {
    condition     = snowflake_grant_privileges_to_account_role.database_access["IMPORTED_TEST_SHARE_1_TEST_ROLE_1"].privileges == toset(["IMPORTED PRIVILEGES"])
    error_message = "The proper privilege is not assigned"
  }
  assert {
    condition     = snowflake_grant_privileges_to_account_role.database_access["IMPORTED_TEST_SHARE_1_TEST_ROLE_2"].account_role_name == "TEST_ROLE_2"
    error_message = "The proper role is used"
  }

  assert {
    condition     = snowflake_grant_privileges_to_account_role.database_access["IMPORTED_TEST_SHARE_1_TEST_ROLE_2"].privileges == toset(["IMPORTED PRIVILEGES"])
    error_message = "Incorrect privileges given to role"
  }

  assert {
    condition     = snowflake_grant_privileges_to_account_role.database_access["IMPORTED_TEST_SHARE_1_TEST_ROLE_2"].on_account_object[0].object_type == "DATABASE"
    error_message = "Privileges given on incorrect account object"
  }
  assert {
    condition     = length(snowflake_grant_privileges_to_account_role.database_access) == 4
    error_message = "Number of granted privileges is not as expected"
  }
}
