# ecr.tf | Elastic Container Registry

resource "aws_ecr_repository" "aws_ecr" {
  name = "${var.app_name}-${var.app_environment}-ecr"
  tags = {
    "Name"        = "${var.app_name}-${var.app_environment}-ecr"
    "Environment" = var.app_environment
  }
}
