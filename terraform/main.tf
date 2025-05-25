provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "books_api_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.books_api_sg.id]

  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = file("user_data.sh")

  tags = {
    Name = "BooksAPIServer"
  }
}

resource "aws_security_group" "books_api_sg" {
  name        = "books-api-sg"
  description = "Allow HTTP and HTTPS"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
