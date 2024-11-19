variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}

variable "websocket_endpoint" {
  description = "The endpoint of the websocket API our frontend will connect to. Example format: wss://<api-id>.execute-api.<region>.amazonaws.com/<stage>"
  type        = string
}