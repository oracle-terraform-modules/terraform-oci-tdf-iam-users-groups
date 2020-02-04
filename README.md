# Oracle Cloud Infrastructure (OCI) Terraform IAM Users and Groups Module

## Introduction

This module assist in provisioning OCI Users and Groups and adding Users to existing groups.
  

## Solution

This module assist in provisioning OCI Users and Groups and adding Users to existing groups.

The module covers the following use cases:

* Creating one group and adding zero, one or multiple users to the groups.
* Creating multiple groups and adding zero, one or multiple users to each of the groups.
* Creating multiple users and adding them to a group provided as a parameter.
* Creating multiple groups with no users.

Multiple combinations between the use cases above are possible/supported.

## Prerequisites
This module does not create any dependencies or prerequisites. 

Create the following before using this module: 
  * Required IAM construct to allow for the creation of resources

## Getting Started

Several fully-functional examples have been provided in the `examples` directory.  

The scenarios covered in the examples section are:
* Creating one group and adding zero, one or multiple users to the groups.
* Creating multiple groups and adding zero, one or multiple users to each of the groups.
* Creating multiple users and adding them to a group provided as a parameter.
* Creating multiple groups with no users.
* Creating multiple groups and creating multiple users under those groups. Users can be allocated to more then one group - existing or non-existing group.

Any combination of the above scenarios is supported by this module.

## Accessing the Solution

This is a core service module that is foundational to many other resources in OCI, so there is really nothing to directly access.  

## Module inputs

### Providers

This module supports a custom provider. With a custom provider, IAM resources must be deployed in your home tenancy, which might be different from the region that will contain other deployments. 

You'll be managing those providers in the tf automation projects where you reference this module.

***example***

```
provider "oci" {
  tenancy_ocid     = "${var.tenancy_id}"
  user_ocid        = "${var.user_id}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

provider "oci" {
  alias            = "home"
  tenancy_ocid     = "${var.tenancy_id}"
  user_ocid        = "${var.user_id}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = [for i in data.oci_identity_region_subscriptions.this.region_subscriptions : i.region_name if i.is_home_region == true][0]
}

data "oci_identity_region_subscriptions" "this" {
  tenancy_id = var.tenancy_id
}
```

The following IAM attributes are available in the the `terraform.tfvars` file:

```
### PRIMARY TENANCY DETAILS

# Get this from the bottom of the OCI screen (after logging in, after Tenancy ID: heading)
primary_tenancy_id="<tenancy OCID"
# Get this from OCI > Identity > Users (for your user account)
primary_user_id="<user OCID>"

# the fingerprint can be gathered from your user account (OCI > Identity > Users > click your username > API Keys fingerprint (select it, copy it and paste it below))
primary_fingerprint="<PEM key fingerprint>"
# this is the full path on your local system to the private key used for the API key pair
primary_private_key_path="<path to the private key that matches the fingerprint above>"

# region (us-phoenix-1, ca-toronto-1, etc)
primary_region="<your region>"

### DR TENANCY DETAILS

# Get this from the bottom of the OCI screen (after logging in, after Tenancy ID: heading)
dr_tenancy_id="<tenancy OCID"
# Get this from OCI > Identity > Users (for your user account)
dr_user_id="<user OCID>"

# the fingerprint can be gathered from your user account (OCI > Identity > Users > click your username > API Keys fingerprint (select it, copy it and paste it below))
dr_fingerprint="<PEM key fingerprint>"
# this is the full path on your local system to the private key used for the API key pair
dr_private_key_path="<path to the private key that matches the fingerprint above>"

# region (us-phoenix-1, ca-toronto-1, etc)
dr_region="<your region>"
```


### Groups_users_config

Input variable where the user provides the groups and users to be created, and users to be added to different existing groups.

```
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

```

**`oci_identity_group.groups`**

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| provider | string | yes | "oci.oci_home"| string containing the name of the provider as defined by the automation that consumes this module | See the examples section in order to understand how to set the provider|
| count | number | yes | 0 | the number of resources to be created | the number of resources to be created |
| name | string | yes | "OCI-TF-Group" | string of the display name | Resource name |
| compartment\_id | string | yes | none | string of the compartment OCID | This is the OCID of the compartment |
| description | string | no | N/A (no default) | The provided description |
| define\_tags | map(string) | no | N/A (no default) | The defined tags.
| freeform\_tags| map(string) | no | N/A (no default) | The freeform\_tags.


**`oci_identity_user.users`**
  

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| provider | string | yes | "oci.oci_home"| string containing the name of the provider as defined by the automation that consumes this module | See the examples section in order to understand how to set the provider| 
| count | number | yes | 0 | the number of resources to be created | the number of resources to be created |
| name | string | yes | "OCI-TF-User" | string of the display name | Resource name |
| compartment\_id | string | yes | none | string of the compartment OCID | This is the OCID of the compartment |
| description | string | no | N/A (no default) | The provided description |
| define\_tags | map(string) | no | N/A (no default) | The defined tags.
| freeform\_tags| map(string) | no | N/A (no default) | The freeform\_tags.
| email | string | no | N/A (no default) | The provided email |


**`oci_identity_user_group_membership.users_groups_membership`**
  

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| provider | string | yes | "oci.oci_home"| string containing the name of the provider as defined by the automation that consumes this module | See the examples section in order to understand how to set the provider | 
| count | number | yes | 0 | the number of resources to be created | the number of resources to be created |
| group\_id | string | yes | none | OCID of the group created above | OCID of the group created above|
| user\_id | string | yes | none | OCID of the user created above | OCID of the user created above |

***Example***

The following example will create 3 groups, 5 users and adds users to different/multiple groups(pre-existing groups or the groups created above)

```
# Groups and Users

groups_users_config = {
  default_compartment_id = "<default_compartment_id>"
  default_defined_tags   = {}
  default_freeform_tags  = {}
  groups = {
    group_1 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test Group 1"
    }
    group_2 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test Group 2"
    }
    group_3 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test Group 3"
    }
  }
  users = {
    test_user_1 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test user 1"
      email          = "test_user_1@gmail.com"
      groups         = ["group_1"]
    }
    test_user_2 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test user 2"
      email          = "test_user_2@yahoo.com"
      groups         = ["group_1", "group_2"]
    }
    test_user_3 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test user 3"
      email          = "test_user_3@yahoo.com"
      groups         = ["group_2", "existing_group", "group_2"]
    }
    test_user_4 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test user 4"
      email          = "test_user_4@yahoo.com"
      groups         = []
    }
    test_user_5 = {
      compartment_id = "<specific_compartment_ocid>"
      defined_tags   = "<specific_defined_tags>"
      freeform_tags  = "<specific_freeform_tags>"
      description    = "Test user 5"
      email          = "test_user_5@yahoo.com"
      groups         = null
    }
  }
}

```


## Outputs

This module is returning 1 hierarchical object:
* `groups_and_users_config`:  Displays the groups and users created. Under the users displays the groups a list of users belong to. 


## Notes/Issues


## URLs

For Oracle Cloud Infrastructure IAM users/groups documentation, see
  * https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingusers.htm
  * https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managinggroups.htm


## Versions

This module has been developed and tested by running terraform on Oracle Linux Server release 7.7 

```
user-linux$ terraform --version
Terraform v0.12.19
+ provider.oci v3.58.0

```

## Contributing

This project is open source. Oracle appreciates any contributions that are made by the open source community.

## License

Copyright (c) 2020, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

See [LICENSE](LICENSE) for more details.
