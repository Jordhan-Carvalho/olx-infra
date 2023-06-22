# https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "backend-ec2-template" {
  image_id      = "ami-053b0d53c279acc90" # Ubuntu server 22.0
  instance_type = "t2.micro"              # Free tier
  lifecycle {
    create_before_destroy = true
  }
}

# https://aws.amazon.com/autoscaling
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "autoscaling-backend" {
  availability_zones = ["us-east-1a"]
  # desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.backend-ec2-template.id
    version = "$Latest"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
# Without this policy autoscale would only replace failing ec2 instances
resource "aws_autoscaling_policy" "scale-up-policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-backend.name
}

# Cloudwatch alarm to be used on the autoscaling autoscaling_policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # Seconds
  statistic           = "Average"
  threshold           = 75 # CPU utilization %

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-backend.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-up-policy.arn]
}

# Scale down alarm and policy
resource "aws_autoscaling_policy" "scale-down-policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-backend.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  alarm_name          = "cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # Seconds
  statistic           = "Average"
  threshold           = 10 # CPU utilization %

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-backend.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-down-policy.arn]
}

# Attach the ELB to the autoscaling
resource "aws_autoscaling_attachment" "backend-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling-backend.id
  elb                    = aws_elb.backend-loadbalancer.id
}

# Create the ELB -- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb
resource "aws_elb" "backend-loadbalancer" {
  name               = "backend-loadbalancer"
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

}
