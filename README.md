# Oracle Cloud Infrastructure (OCI) Terraform IAM Users and Groups Module

## Introduction


This module assist in provisioning OCI Users and Groups and adding Users to existing groups.
  

## Solution

This module assist in provisioning OCI Users and Groups and adding Users to existing groups.

The module covers the following usecases:

* Creating one group and adding zero, one or multiple users to the groups.
* Creating multiple groups and adding zero, one or multiple users to each of the groups.
* Creating multiple users and adding them to a group provided as a parameter.
* Creating multiple groups with no users.

Multiple combinations between the usescases above are possible/supported.

### Prerequisites
This module does not create any dependencies or prerequisites (these must be created prior to using this module):

* Mandatory(needs to exist before creating the IAM resources)
  * Required IAM construct to allow for the creation of resources

### Module inputs

#### `providers`

* This module supports custom provider. This is provided as when creating IAM resources you need to do this against the tenancy home region which might be different then the region used by the rest of your automation project.

You'll be managing those providers in the tf automation projects where you reference this module.

Example:

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

* Bellow you can find the IAM attributes provided in the the `terraform.tfvars` file:

```
### TENANCY DETAILS

# Get this from the bottom of the OCI screen (after logging in, after Tenancy ID: heading)
tenancy_id="<tenancy OCID"
# Get this from OCI > Identity > Users (for your user account)
user_id="<user OCID>"

# the fingerprint can be gathered from your user account (OCI > Identity > Users > click your username > API Keys fingerprint (select it, copy it and paste it below))
fingerprint="<PEM key fingerprint>"
# this is the full path on your local system to the private key used for the API key pair
private_key_path="<path to the private key that matches the fingerprint above>"

# region (us-phoenix-1, ca-toronto-1, etc)
region="<your home region>"

```


#### `groups_users_config`

* input variable where the user provides the groups to be created, those groups users to be created, and users to be added to different existing groups.

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

  * The automation creates the following resources with the following attributes:
    * `oci_identity_group.groups`:

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| provider | string | yes | "oci.oci_home"| string containing the name of the provider as defined by the automation that consumes this module | See the examples section in order to understand how to set the provider|
| count | number | yes | 0 | the number of resources to be created | the number of resources to be created |
| name | string | yes | "OCI-TF-Group" | string of the display name | Resource name |
| compartment\_id | string | yes | none | string of the compartment OCID | This is the OCID of the compartment |
| description | string | no | N/A (no default) | The provided description |
| define\_tags | map(string) | no | N/A (no default) | The defined tags.
| freeform\_tags| map(string) | no | N/A (no default) | The freeform\_tags.

 * `oci_identity_user.users`:
  

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


  * `oci_identity_user_group_membership.users_groups_membership`:
  

| Attribute | Data Type | Required | Default Value | Valid Values | Description |
|---|---|---|---|---|---|
| provider | string | yes | "oci.oci_home"| string containing the name of the provider as defined by the automation that consumes this module | See the examples section in order to understand how to set the provider | 
| count | number | yes | 0 | the number of resources to be created | the number of resources to be created |
| group\_id | string | yes | none | OCID of the group created above | OCID of the group created above|
| user\_id | string | yes | none | OCID of the user created above | OCID of the user created above |

Example:

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
The above example will create :
            * 3 groups
            * 5 users
            * * Adding the users to different/multiple groups(pre-existing groups or the groups created above)

### Outputs

This module is returning 1 hierarchical object:
* `groups_and_users_config` - displays the created groups, created users. Under the users we're also displaying the groups those users have been added to. 

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

## Summary

This serves as a foundational component in an OCI environment, providing the ability to provision File Storage Service instances.

## Notes/Issues


## URLs

* OCI IAM users/groups documentation: 
  * https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingusers.htm
  * https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managinggroups.htm

## Contributing

This project is open source. Oracle appreciates any contributions that are made by the open source community.

## Versions

This module has been developed and tested by running terraform on macOS Mojave Version 10.14.5

```
user-mac$ terraform --version
Terraform v0.12.3
+ provider.oci v3.31.0
```

## License

Copyright (c) 2020, Oracle and/or its affiliates.

Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

See [LICENSE](LICENSE) for more details.
