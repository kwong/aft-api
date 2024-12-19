# Data source to create ZIP from existing file, triggered only on file changes
# data "archive_file" "helloworld" {
#   type       = "zip"
#   source_dir = local.lambda_function_path_dir
#   # filename    = "helloworld.py"
#   #excludes    = setsubtract(fileset(local.lambda_function_path_dir, "*"), ["main.py"])
#   output_path = "${dirname(local.lambda_upload_dir)}/helloworld.zip"

# }

data "archive_file" "request_handler" {
  type       = "zip"
  source_dir = "${path.module}/src/api_request_handler/"
  # filename    = "helloworld.py"
  #excludes    = setsubtract(fileset(local.lambda_function_path_dir, "*"), ["main.py"])
  output_path = "${path.module}/upload/request_handler.zip"
}

# locals {
#   lambda_upload_path = "${path.module}/upload/helloworld.zip"
#   #lambda_function_path_dir = "${path.module}/src/hello-world/"
#   lambda_function_hash = filemd5(local.lambda_upload_path)
#   lambda_upload_dir    = "${path.module}/upload/"
# }
