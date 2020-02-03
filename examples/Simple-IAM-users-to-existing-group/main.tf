# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


module "oci_iam_users_groups" {

  source = "../../"

  providers = {
    oci.oci_home = "oci.home"
  }

  groups_users_config = var.groups_users_config

}

