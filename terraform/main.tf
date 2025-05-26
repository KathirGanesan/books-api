##############################
# main.tf - Terraform configuration for Books API
##############################

#---------------------------------------
# Configure AWS as the cloud provider
#---------------------------------------
provider "aws" {
  # Region where resources will be created
  region = var.aws_region
}

#---------------------------------------
# Data: IAM assume role policy for EC2
#---------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  # Allow EC2 service to assume this role
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

#---------------------------------------
# EC2 instance for the Books API
#---------------------------------------
resource "aws_instance" "books_api_server" {
  # AMI and instance type pulled from variables
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # Attach the security group defined below
  vpc_security_group_ids = [aws_security_group.books_api_sg.id]

  # Public IP assignment for external access
  associate_public_ip_address = true

  # SSH key for remote access
  key_name = var.key_name

  # Bootstrapping script: installs Docker, nginx, and CloudWatch agent
  user_data = file("user_data.sh")

  # Attach the IAM instance profile so the EC2 can assume the CW Agent role
  iam_instance_profile = aws_iam_instance_profile.cw_agent_profile.name

  # Tags help identify and organize resources
  tags = {
    Name = "BooksAPIServer"
  }
}

#---------------------------------------
# Security Group: allow HTTP/HTTPS/SSH
#---------------------------------------
resource "aws_security_group" "books_api_sg" {
  name        = "books-api-sg"
  description = "Allow inbound HTTP (80), HTTPS (443) and SSH (22)"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [description]
  }
}

#---------------------------------------
# CloudWatch Log Group for application logs
#---------------------------------------
resource "aws_cloudwatch_log_group" "app" {
  # Logical name: /books-api
  name = "/books-api"

  # How many days to retain logs
  retention_in_days = 14
}

#---------------------------------------
# IAM Role for CloudWatch Agent
#---------------------------------------
resource "aws_iam_role" "cw_agent" {
  name = "cloudwatch-agent"

  # Trust policy allowing EC2 to assume this role
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Attach the managed CloudWatch Agent policy
resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.cw_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#---------------------------------------
# Instance Profile for EC2
#---------------------------------------
# Bundles the CW Agent role so EC2 can assume it
resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "cw-agent-instance-profile"
  role = aws_iam_role.cw_agent.name
}

###############################################################################
# Restart Nginx after every terraform apply (or whenever the EC2 instance
# is replaced).  Works with the books-api server you already have.
###############################################################################

variable "ssh_private_key_path" {
  description = "Path to the private key that can SSH into the EC2 instance"
  type        = string
  default     = "~/.ssh/books_api.pem" # adjust if different
}

resource "null_resource" "restart_nginx" {
  # ── Re-run when the instance is replaced OR on every apply
  triggers = {
    instance_id = aws_instance.books_api_server.id
    apply_epoch = timestamp() # remove this line for instance-only restarts
  }

  # ── SSH connection details
  connection {
    type        = "ssh"
    host        = aws_instance.books_api_server.public_ip
    user        = "ubuntu" # or ec2-user / root if you chose a different AMI
    private_key = file(var.ssh_private_key_path)
    timeout     = "30s"
  }

  # ── Command that actually restarts Nginx
  provisioner "remote-exec" {
    inline = [
      "echo '▶ restarting nginx …'",
      "sudo systemctl restart nginx",
      "sudo systemctl status nginx --no-pager -l",
    ]
    # on_failure = "continue"   # uncomment if you’d rather not fail the whole apply
  }

  # Make sure the instance exists first
  depends_on = [aws_instance.books_api_server]
}
