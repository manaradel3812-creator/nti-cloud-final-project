resource "aws_cognito_user_pool" "this" {
  name = "final-project-user-pool"
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "api-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["openid", "email"]
  callback_urls        = ["https://example.com"] 
  logout_urls          = ["https://example.com"]

  supported_identity_providers = ["COGNITO"]
}


resource "aws_cognito_user_pool_domain" "this" {
  domain       = "final-project-auth"
  user_pool_id = aws_cognito_user_pool.this.id
}


