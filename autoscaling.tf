# autoscaling.tf | autoscaling ec2 

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-083cd4eb32643c8a0"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.service_security_group.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.app_name}-${var.app_environment}-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = "asg"
  vpc_zone_identifier  = aws_subnet.public.*.id
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 0
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}