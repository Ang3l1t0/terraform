# ecs | Elastic Container Service

# Task Definition
resource "aws_ecs_task_definition" "ecs_task" {
  family = "${var.app_name}-task"

  container_definitions = jsonencode([{
    name       = "${var.app_name}-${var.app_environment}-container",
    image      = "${aws_ecr_repository.aws_ecr.repository_url}:latest",
    entryPoint = []
    environment = [{
      "name"  = "environment",
      "value" = "${var.app_environment}"
    }],
    essential = true
    portMapping = [
      {
        "containerPort" = 80,
        "hostPort"      = 80
      }
    ]
  }])

  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = "128"
  cpu                      = "1024"

  tags = {
    "Name"        = "${var.app_name}-ecs-td"
    "Environment" = var.app_environment
  }
}

# Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  tags = {
    "Name"        = "${var.app_name}-${var.app_environment}-cluster"
    "Environment" = var.app_environment
  }
}

#Service
resource "aws_ecs_service" "ecs_service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.ecs_cluster.id
  task_definition      = aws_ecs_task_definition.ecs_task.arn
  desired_count        = 1
  launch_type          = "EC2"
  scheduling_strategy  = "REPLICA"
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id
    ]
  }
}
