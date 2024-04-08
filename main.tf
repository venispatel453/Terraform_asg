# Creating a launch template 
resource "aws_launch_template" "lt" {
  user_data = var.user_data
  name_prefix = "${var.env}-asg"
  instance_type = var.instance_type
  image_id = var.ami_id

  iam_instance_profile {
    name = "ecsInstanceRole"
  }
  tags = {
    Environment = "${var.env}"
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.security_group_ids 
  }
} 

# Creating an auto-scaling-group

resource "aws_autoscaling_group" "asg" {
  name = "${var.env}-asg"
  vpc_zone_identifier = var.vpc_zone_identifier
  max_size = var.max_size
  min_size = var.min_size
  health_check_grace_period = 300
  health_check_type = "ELB"
  suspended_processes = ["Terminate"]
  desired_capacity = var.desired_size
  force_delete = true

  launch_template {
    id = aws_launch_template.lt.id
    version =  "$Latest"
  }
}

# Creating an auto-scaling attachment

resource "aws_autoscaling_attachment" "as_attach" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn = var.alb_arn
}