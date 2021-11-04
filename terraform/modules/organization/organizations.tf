# resource "aws_organizations_account" "aws_organizations_account_toshi" {
#   email     = "toshi@toshi.click"
#   name      = "toshi"
#   parent_id = aws_organizations_organizational_unit.aws_organizations_organizational_unit_prod.id
# }

# resource "aws_organizations_account" "aws_organizations_account_server_toshi" {
#   email     = "server@toshi.click"
#   name      = "toshiyuki abe"
#   parent_id = "r-rcwt"
# }
# resource "aws_organizations_organization" "aws_organizations_organization_toshi" {
#   aws_service_access_principals = ["sso.amazonaws.com"]
#   feature_set                   = "ALL"
# }

# resource "aws_organizations_organization" "aws_organizations_organization_server_toshi" {
#   aws_service_access_principals = ["sso.amazonaws.com"]
#   feature_set                   = "ALL"
# }
# resource "aws_organizations_organizational_unit" "aws_organizations_organizational_unit_dev" {
#   name      = "dev"
#   parent_id = aws_organizations_organizational_unit.aws_organizations_organizational_unit_service.id
# }

# resource "aws_organizations_organizational_unit" "aws_organizations_organizational_unit_prod" {
#   name      = "prod"
#   parent_id = aws_organizations_organizational_unit.aws_organizations_organizational_unit_service.id
# }

# resource "aws_organizations_organizational_unit" "aws_organizations_organizational_unit_security" {
#   name      = "security"
#   parent_id = "r-rcwt"
# }

# resource "aws_organizations_organizational_unit" "aws_organizations_organizational_unit_service" {
#   name      = "service"
#   parent_id = "r-rcwt"
# }
resource "aws_organizations_policy" "aws_organizations_policy_full" {
  content     = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"*\",\n      \"Resource\": \"*\"\n    }\n  ]\n}"
  description = "Allows access to every operation"
  name        = "FullAWSAccess"
  type        = "SERVICE_CONTROL_POLICY"
}
