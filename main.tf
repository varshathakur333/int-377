provider "aws" {
  region = "ap-south-1"
}

# Lookup the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

# Provision a Security Group for Web + Monitoring stack
resource "aws_security_group" "weather_sg" {
  name        = "weather-app-sg"
  description = "Allow inbound traffic for web app and monitoring services"

  # HTTP (Weather App)
  ingress {
    description = "Weather App HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana UI
  ingress {
    description = "Grafana Dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus Console
  ingress {
    description = "Prometheus Server"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH for administrator access
  ingress {
    description = "SSH admin access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict to your IP!
  }

  # Jenkins UI
  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins Agent communication
  ingress {
    description = "Jenkins Agent Port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "weather-app-security-group"
  }
}

# Provision the EC2 Instance
resource "aws_instance" "weather" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  # Update with your AWS SSH Key Name (must exist in your AWS account)
  key_name = "my-ssh-key"

  vpc_security_group_ids = [aws_security_group.weather_sg.id]

  # User Data Script to automatically install Docker, pull resources, and start compose
  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              yum update -y
              
              # Install Git and Docker
              yum install -y git docker
              
              # Start Docker and enable boot persistence
              systemctl start docker
              systemctl enable docker
              
              # Add ec2-user to docker group
              usermod -aG docker ec2-user
              
              # Install Docker Compose CLI plugin
              mkdir -p /usr/local/lib/docker/cli-plugins/
              curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              
              # Create symlink for standalone 'docker-compose' command compatibility
              ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose
              
              # Clone your weather repository (Replace URL below with your actual repository URL)
              # For demonstration, we create directory structure manually if cloning is not used:
              mkdir -p /home/ec2-user/app/grafana/provisioning/datasources
              mkdir -p /home/ec2-user/app/grafana/provisioning/dashboards
              mkdir -p /home/ec2-user/app/grafana/dashboards
              
              # Fetch/write the configuration files on startup
              cat <<'INNEREOF' > /home/ec2-user/app/Dockerfile
              FROM nginx:alpine
              COPY nginx.conf /etc/nginx/nginx.conf
              COPY . /usr/share/nginx/html
              EXPOSE 80
              INNEREOF
              
              # We will start the stack when files are in place!
              EOF

  tags = {
    Name = "weather-monitoring-server"
  }
}

# Output variables to make it easy to connect
output "weather_app_url" {
  description = "The URL of the Weather Application website"
  value       = "http://${aws_instance.weather.public_ip}"
}

output "grafana_url" {
  description = "The URL of the Grafana Monitoring Dashboard"
  value       = "http://${aws_instance.weather.public_ip}:3000"
}

output "prometheus_url" {
  description = "The URL of the Prometheus Console"
  value       = "http://${aws_instance.weather.public_ip}:9090"
}