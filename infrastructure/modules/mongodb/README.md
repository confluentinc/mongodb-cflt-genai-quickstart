# mongodb

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 1.12 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | ~> 1.12 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) | resource |
| [mongodbatlas_database_user.default](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_project.test](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project) | resource |
| [mongodbatlas_project_ip_access_list.ip](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [mongodbatlas_search_index.search-vector](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/search_index) | resource |
| [random_password.dbuser](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [random_string.dbuser](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mongodbatlas_cloud_provider"></a> [mongodbatlas\_cloud\_provider](#input\_mongodbatlas\_cloud\_provider) | Cloud provider | `string` | `"AWS"` | no |
| <a name="input_mongodbatlas_cloud_region"></a> [mongodbatlas\_cloud\_region](#input\_mongodbatlas\_cloud\_region) | Cloud provider region name (note that MongoDB values are different than usual Cloud provider ones) | `string` | `"US_EAST_1"` | no |
| <a name="input_mongodbatlas_cluster"></a> [mongodbatlas\_cluster](#input\_mongodbatlas\_cluster) | Atlas cluster | `string` | `"genai"` | no |
| <a name="input_mongodbatlas_collection"></a> [mongodbatlas\_collection](#input\_mongodbatlas\_collection) | Atlas collection | `string` | `"products_summarized_with_embeddings"` | no |
| <a name="input_mongodbatlas_database"></a> [mongodbatlas\_database](#input\_mongodbatlas\_database) | Atlas database | `string` | `"genai"` | no |
| <a name="input_mongodbatlas_org_id"></a> [mongodbatlas\_org\_id](#input\_mongodbatlas\_org\_id) | Organization ID | `string` | n/a | yes |
| <a name="input_mongodbatlas_private_key"></a> [mongodbatlas\_private\_key](#input\_mongodbatlas\_private\_key) | Private API key to authenticate to Atlas | `string` | n/a | yes |
| <a name="input_mongodbatlas_project"></a> [mongodbatlas\_project](#input\_mongodbatlas\_project) | Atlas project | `string` | `"GenAI-Quickstart"` | no |
| <a name="input_mongodbatlas_public_key"></a> [mongodbatlas\_public\_key](#input\_mongodbatlas\_public\_key) | Public API key to authenticate to Atlas | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_password"></a> [connection\_password](#output\_connection\_password) | database pwd provisioned |
| <a name="output_connection_user"></a> [connection\_user](#output\_connection\_user) | database user provisioned |
| <a name="output_host"></a> [host](#output\_host) | Cluster host address |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
