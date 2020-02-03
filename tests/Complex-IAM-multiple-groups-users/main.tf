# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




locals {
  groups_users_config = {
    default_compartment_id = var.compartment_id
    default_defined_tags   = {}
    default_freeform_tags  = null
    groups = {
      group_1 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = null
        description    = "Test Group 1"
      }
      group_2 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = null
        description    = "Test Group 2"
      }
      group_3 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = null
        description    = "Test Group 3"
      }
    }
    users = {
      test_user_1 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = {}
        description    = "Test user 1"
        email          = "test_user_1@gmail.com"
        groups         = ["group_1"]
      }
      test_user_2 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = null
        description    = "Test user 2"
        email          = "test_user_2@yahoo.com"
        groups         = ["group_1", "group_2"]
      }
      test_user_3 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = {}
        description    = "Test user 3"
        email          = "test_user_3@yahoo.com"
        groups         = ["group_2"]
      }
      test_user_4 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = {}
        description    = "Test user 4"
        email          = "test_user_4@yahoo.com"
        groups         = []
      }
      test_user_5 = {
        compartment_id = null
        defined_tags   = {}
        freeform_tags  = {}
        description    = "Test user 5"
        email          = "test_user_5@yahoo.com"
        groups         = null
      }
    }
  }
}
module "oci_iam_users_groups" {

  source = "../../"

  providers = {
    oci.oci_home = "oci.home"
  }

  groups_users_config = local.groups_users_config

}

