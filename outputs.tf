# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




#########################
## Group With Users
#########################

output "groups_and_users" {
  description = "The returned resource attributes for the Group with Users."
  value = {
    groups = { for group in oci_identity_group.groups : group.name => {
      name           = group.name,
      compartment_id = group.compartment_id,
      defined_tags   = group.defined_tags,
      description    = group.description,
      freeform_tags  = group.freeform_tags,
      id             = group.id, state = group.state,
      time_created   = group.time_created
      }
    },
    users = { for user in oci_identity_user.users : user.name => {
      name           = user.name,
      capabilities   = user.capabilities,
      compartment_id = user.compartment_id,
      defined_tags   = user.defined_tags,
      description    = user.description,
      email          = user.email,
      freeform_tags  = user.freeform_tags,
      id             = user.id,
      state          = user.state,
      groups         = [for group_membership in oci_identity_user_group_membership.users_groups_membership : { "group_id" = group_membership.group_id, "group_name" = [for group in data.oci_identity_groups.groups.groups : group.name if group.id == group_membership.group_id][0] } if group_membership.user_id == user.id]
      }
    }
  }
}


