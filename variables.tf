# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


# define users and groups

variable "groups_users_config" {
  type = object({
    default_compartment_id = string,
    default_defined_tags   = map(string),
    default_freeform_tags  = map(string),
    groups = map(object({
      compartment_id = string,
      defined_tags   = map(string),
      freeform_tags  = map(string),
      description    = string
    })),
    users = map(object({
      compartment_id = string,
      defined_tags   = map(string),
      freeform_tags  = map(string),
      description    = string,
      email          = string,
      groups         = list(string)
    }))
  })
  description = "Parameters to provision users and groups"
}