# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




locals {

  #################
  # Group and users
  #################
  # default values

  default_group = {
    compartment_id = null
    description    = "OCI Identity Group created with the OCI Core IAM Users Groups Module"
    name           = "OCI-TF-Group"
    defined_tags   = {}
    freeform_tags  = { "Department" = "Security" }
  }

  #################
  # Users
  #################
  # default values

  default_user = {
    compartment_id = null
    description    = "OCI Identity User created with the OCI Core IAM Users Groups Module"
    name           = "OCI-TF-User"
    email          = null
    defined_tags   = {}
    freeform_tags  = { "Department" = "Security" }
  }
  keys_users = var.groups_users_config != null ? (var.groups_users_config.users != null ? keys(var.groups_users_config.users) : keys({})) : keys({})
  membership = var.groups_users_config != null ? distinct(flatten(var.groups_users_config.users != null ? [for user_name in local.keys_users : [for group_name in(var.groups_users_config.users[user_name].groups != null ? var.groups_users_config.users[user_name].groups : []) : [{ "user_name" = user_name, "group_name" = group_name }]]] : [])) : []
}

data "oci_identity_groups" "groups" {
  #Required
  provider       = "oci.oci_home"
  compartment_id = var.groups_users_config != null ? var.groups_users_config.default_compartment_id != null ? var.groups_users_config.default_compartment_id : local.default_group.compartment_id : "null"

  depends_on = [oci_identity_group.groups]
}

resource "oci_identity_group" "groups" {

  provider = "oci.oci_home"
  for_each = var.groups_users_config != null ? (var.groups_users_config.groups != null ? var.groups_users_config.groups : {}) : {}

  #Required
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : (var.groups_users_config.default_compartment_id != null ? var.groups_users_config.default_compartment_id : local.default_group.compartment_id)
  description    = each.value.description != null ? each.value.description : local.default_group.description
  name           = each.key

  #Optional
  defined_tags  = each.value.defined_tags != null ? each.value.defined_tags : (var.groups_users_config.default_defined_tags != null ? var.groups_users_config.default_defined_tags : local.default_group.defined_tags)
  freeform_tags = each.value.freeform_tags != null ? each.value.freeform_tags : (var.groups_users_config.default_freeform_tags != null ? var.groups_users_config.default_freeform_tags : local.default_group.freeform_tags)
}

resource "oci_identity_user" "users" {

  provider = "oci.oci_home"
  for_each = var.groups_users_config != null ? (var.groups_users_config.users != null ? var.groups_users_config.users : {}) : {}

  #Required
  compartment_id = each.value.compartment_id != null ? each.value.compartment_id : (var.groups_users_config.default_compartment_id != null ? var.groups_users_config.default_compartment_id : local.default_user.compartment_id)
  description    = each.value.description != null ? each.value.description : local.default_user.description
  name           = each.key

  #Optional
  defined_tags  = each.value.defined_tags != null ? each.value.defined_tags : (var.groups_users_config.default_defined_tags != null ? var.groups_users_config.default_defined_tags : local.default_user.defined_tags)
  email         = each.value.email != null ? each.value.email : local.default_user.email
  freeform_tags = each.value.freeform_tags != null ? each.value.freeform_tags : (var.groups_users_config.default_freeform_tags != null ? var.groups_users_config.default_freeform_tags : local.default_user.freeform_tags)

  depends_on = [oci_identity_group.groups]
}

resource "oci_identity_user_group_membership" "users_groups_membership" {
  count    = var.groups_users_config != null ? (local.membership != null ? length(local.membership) : 0) : 0
  provider = "oci.oci_home"
  #Required
  group_id = contains([for group in data.oci_identity_groups.groups.groups : group.name], local.membership[count.index].group_name) == true ? [for group in data.oci_identity_groups.groups.groups : group.id if group.name == local.membership[count.index].group_name][0] : [for group in oci_identity_group.groups : group.id if group.name == local.membership[count.index].group_name][0]
  user_id  = [for user in oci_identity_user.users : user.id if user.name == local.membership[count.index].user_name][0]

  depends_on = [oci_identity_group.groups, oci_identity_user.users]
}