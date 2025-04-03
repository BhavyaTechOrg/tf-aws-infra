
# Auto Scaling Group

resource "aws_autoscaling_group" "webapp_asg" {
  name                      = "webapp-asg-${var.environment}-${random_id.suffix.hex}"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.webapp_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "webapp-${var.environment}-${random_id.suffix.hex}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "CreatedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Scale Up Policy

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-${var.environment}-${random_id.suffix.hex}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}


# Scale Down Policy

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-${var.environment}-${random_id.suffix.hex}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}


# CloudWatch Alarm - Scale Up

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high-${var.environment}-${random_id.suffix.hex}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Alarm when server CPU exceeds 5%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
  lifecycle {
    create_before_destroy = true
  }
}


# CloudWatch Alarm - Scale Down

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low-${var.environment}-${random_id.suffix.hex}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_description   = "Alarm when server CPU is below 3%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
  lifecycle {
    create_before_destroy = true
  }
}
