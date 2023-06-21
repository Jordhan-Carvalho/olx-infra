# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "backend-ec2-template" {
  image_id      = "ami-053b0d53c279acc90" # Ubuntu server 22.0
  instance_type = "t2.micro"              # Free tier
}

# https://aws.amazon.com/autoscaling
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "autoscaling-backend" {
  availability_zones        = ["us-east-1a"]
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.backend-ec2-template.id
    version = "$Latest"
  }
}

