# mongodb

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | 1.21.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | 1.21.4 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.4/docs/resources/cluster) | resource |
| [mongodbatlas_database_user.default](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.4/docs/resources/database_user) | resource |
| [mongodbatlas_project.test](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.4/docs/resources/project) | resource |
| [mongodbatlas_project_ip_access_list.ip](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.21.4/docs/resources/project_ip_access_list) | resource |
| [random_password.dbuser](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.dbuser](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mongodbatlas_cloud_provider"></a> [mongodbatlas\_cloud\_provider](#input\_mongodbatlas\_cloud\_provider) | Cloud provider | `string` | n/a | yes |
| <a name="input_mongodbatlas_cloud_region"></a> [mongodbatlas\_cloud\_region](#input\_mongodbatlas\_cloud\_region) | Cloud provider region name (note that MongoDB values are different than usual Cloud provider ones) | `string` | n/a | yes |
| <a name="input_mongodbatlas_cluster"></a> [mongodbatlas\_cluster](#input\_mongodbatlas\_cluster) | Atlas cluster | `string` | n/a | yes |
| <a name="input_mongodbatlas_collection"></a> [mongodbatlas\_collection](#input\_mongodbatlas\_collection) | Atlas collection | `string` | n/a | yes |
| <a name="input_mongodbatlas_database"></a> [mongodbatlas\_database](#input\_mongodbatlas\_database) | Atlas database | `string` | n/a | yes |
| <a name="input_mongodbatlas_org_id"></a> [mongodbatlas\_org\_id](#input\_mongodbatlas\_org\_id) | Organization ID | `string` | n/a | yes |
| <a name="input_mongodbatlas_private_key"></a> [mongodbatlas\_private\_key](#input\_mongodbatlas\_private\_key) | Private API key to authenticate to Atlas | `string` | n/a | yes |
| <a name="input_mongodbatlas_project"></a> [mongodbatlas\_project](#input\_mongodbatlas\_project) | Atlas project | `string` | n/a | yes |
| <a name="input_mongodbatlas_public_key"></a> [mongodbatlas\_public\_key](#input\_mongodbatlas\_public\_key) | Public API key to authenticate to Atlas | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster"></a> [cluster](#output\_cluster) | MongoDB Atlas Cluster |
| <a name="output_collection"></a> [collection](#output\_collection) | MongoDB Atlas Collection |
| <a name="output_connection_password"></a> [connection\_password](#output\_connection\_password) | database pwd provisioned |
| <a name="output_connection_user"></a> [connection\_user](#output\_connection\_user) | database user provisioned |
| <a name="output_database"></a> [database](#output\_database) | MongoDB Atlas Database |
| <a name="output_host"></a> [host](#output\_host) | Cluster host address |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | MongoDB Atlas Project ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
