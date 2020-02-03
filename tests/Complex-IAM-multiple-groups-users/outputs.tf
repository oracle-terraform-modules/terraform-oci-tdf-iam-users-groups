# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




#########################
## Group With Users
#########################

output "groups_and_users_config" {
  description = "Groups and Users:"
  value = {
    groups_and_users    = module.oci_iam_users_groups.groups_and_users,
    tenancy_home_region = [for i in data.oci_identity_region_subscriptions.this.region_subscriptions : i.region_name if i.is_home_region == true][0]
  }
}

output "groups" {
  description = "Groups"
  value = {
    groups              = module.oci_iam_users_groups.groups_and_users.groups,
    tenancy_home_region = [for i in data.oci_identity_region_subscriptions.this.region_subscriptions : i.region_name if i.is_home_region == true][0]
  }
}
output "users" {
  description = "Users"
  value = {
    users = { for user in module.oci_iam_users_groups.groups_and_users.users : user.name => {
      name           = user.name,
      capabilities   = user.capabilities,
      compartment_id = user.compartment_id,
      defined_tags   = user.defined_tags,
      description    = user.description,
      email          = user.email,
      freeform_tags  = user.freeform_tags,
      id             = user.id,
      state          = user.state,
      groups         = { for group in user.groups : "group_name" => group.group_name... }
      }
    },
    tenancy_home_region = [for i in data.oci_identity_region_subscriptions.this.region_subscriptions : i.region_name if i.is_home_region == true][0]
  }
}