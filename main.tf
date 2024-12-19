

module "aft_api" {
  source = "./modules/rest-api-gateway"

  app_name    = var.app_name
  environment = var.environment
  region      = "ap-southeast-1"

  openapi_config = templatefile(("api.yaml"), {
    create_invoke_arn = "arn:aws:apigateway:ap-southeast-1:lambda:path/2015-03-31/functions/${aws_lambda_function.create.arn}/invocations" #aws_lambda_function.create.arn,
    api_title         = "AFT API",
    api_desc          = "AFT API",
    api_ver           = "1.0.0",
    }
  )
}

module "ddb" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name        = "aft-api-metadata"
  hash_key    = "id"
  table_class = "STANDARD"

  attributes = [
    {
      name = "id" # uuid
      type = "S"
    }
  ]
}

resource "aws_lambda_function" "create" {
  function_name = "request_handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = "900"

  filename         = data.archive_file.request_handler.output_path
  source_code_hash = data.archive_file.request_handler.output_base64sha256

  environment {
    variables = {
      MGMT_ASSUME_ROLE = "arn:aws:iam::253490781334:role/test-lambda-role"
    }
  }
}

## IAM role for Lambda (as defined in previous example)
resource "aws_iam_role" "lambda_role" {
  name = "api_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "lambda_assume_role" {
  name = "lambda-assume-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::253490781334:role/test-lambda-role"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = module.ddb.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_assume_role" {
  policy_arn = aws_iam_policy.lambda_assume_role.arn
  role       = aws_iam_role.lambda_role.name
}

# resource "aws_lambda_function" "hello" {
#   function_name = "helloworld"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "main.handler"
#   runtime       = "python3.10"
#   architectures = ["arm64"]

#   filename         = local.lambda_upload_path
#   source_code_hash = filebase64sha256(local.lambda_upload_path)
# }



# IAM role for Lambda (as defined in previous example)
# resource "aws_iam_role" "lambda_role" {
#   name = "api_lambda_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = aws_iam_role.lambda_role.name
# }

# Allow our lambda function to be invoked by the API GW
resource "aws_lambda_permission" "create_endpoint" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${module.aft_api.apigateway_execution_arn}/*/*"
}

resource "aws_iam_role" "api_gateway_role" {
  name = "aft-api-apigw-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_ddb_access" {
  name = "api-gateway-ddb-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = module.ddb.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_ddb_access" {
  policy_arn = aws_iam_policy.api_gateway_ddb_access.arn
  role       = aws_iam_role.api_gateway_role.name
}


# resource "aws_api_gateway_integration" "status" {
#   rest_api_id             = module.aft_api.apigateway_api_id
#   resource_id             = aws_api_gateway_resource.status.id
#   http_method             = aws_api_gateway_method.status.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.hello.invoke_arn
# }

# resource "aws_api_gateway_method" "status" {
#   rest_api_id   = module.aft_api.apigateway_api_id
#   resource_id   = aws_api_gateway_resource.status.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
# Add RESTful methods
# resource "aws_api_gateway_resource" "create" {
#   rest_api_id = module.aft_api.apigateway_api_id
#   parent_id   = module.aft_api.apigateway_api_root_resource_id
#   path_part   = "create"
# }

# resource "aws_api_gateway_resource" "status" {
#   rest_api_id = module.aft_api.apigateway_api_id
#   parent_id   = module.aft_api.apigateway_api_root_resource_id
#   path_part   = "status"
# }

# resource "aws_api_gateway_method" "create_account" {
#   rest_api_id   = module.aft_api.apigateway_api_id
#   resource_id   = aws_api_gateway_resource.create.id
#   http_method   = "POST"
#   authorization = "NONE" # Consider using API KEY or IAM authorization
# }

# resource "aws_api_gateway_method" "status_check" {
#   rest_api_id   = module.aft_api.apigateway_api_id
#   resource_id   = aws_api_gateway_resource.status.id
#   http_method   = "GET"
#   authorization = "NONE" # Consider using API KEY or IAM authorization
# }
