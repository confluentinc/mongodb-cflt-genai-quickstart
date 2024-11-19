output "websocket_endpoint" {
  value = "${module.aws_websocket_api.api_endpoint}/${module.aws_websocket_api.stage_id}"
}