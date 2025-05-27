resource "aws_instance" "ghost" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 in us-east-1
  instance_type = var.instance_type

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "GhostCMS"
  }

  vpc_security_group_ids = [aws_security_group.ghost_sg.id]
}

resource "aws_security_group" "ghost_sg" {
  name        = "ghost-sg"
  description = "Allow Ghost access on port 2368"
  ingress {
    from_port   = 2368
    to_port     = 2368
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
