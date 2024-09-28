# Specify the provider and region for AWS
provider "aws" {
  region = "us-west-2"  # Specify the AWS region where your resources will be created (e.g., us-west-2)
}

# Create a new VPC (Virtual Private Cloud)
# A VPC is a logically isolated network environment in the AWS cloud.
# It allows you to define a virtual network that closely resembles a traditional network that you might operate in your own data center.
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"        # Define the IP range for the VPC using CIDR notation. 
                                              # This allows for 65,536 IP addresses (10.0.0.1 to 10.0.255.254).
  enable_dns_support   = true                  # Enable DNS resolution for the VPC, allowing resources within the VPC to resolve domain names.
  enable_dns_hostnames = true                  # Enable DNS hostnames for instances in the VPC, allowing instances to have domain names.
  tags = {                                   # Tags are key-value pairs that help you identify and organize resources.
    Name = "MyVPC"                          # Assign a name tag to the VPC for easier identification.
  }
}

# Create a subnet within the VPC
# A subnet is a range of IP addresses in your VPC. Subnets allow you to segment your network and manage resources more effectively.
# Each subnet resides in a single availability zone (AZ), which is a distinct location within a region.
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id      # Link the subnet to the VPC we just created using the VPC ID.
  cidr_block        = "10.0.1.0/24"          # Define the IP range for this subnet using CIDR notation.
                                              # This allows for 256 IP addresses (10.0.1.1 to 10.0.1.254).
  availability_zone = "us-west-2a"           # Specify the availability zone for the subnet; AZs are isolated from each other for high availability.
  tags = {                                   # Assign tags to the subnet for easier management.
    Name = "MySubnet"                       # Assign a name tag to the subnet.
  }
}

# Create a security group to control access to the instance
# A security group acts as a virtual firewall for your instances to control inbound and outbound traffic.
# It contains rules that specify allowed connections based on IP address, port, and protocol.
resource "aws_security_group" "allow_ssh" {
  name        = "tryThis"                   # Name of the security group for identification.
  description = "Allow SSH"                 # Description of what this security group is for (in this case, allowing SSH access).
  vpc_id      = aws_vpc.my_vpc.id           # Link the security group to the VPC we created earlier.

  ingress {                                  # Define rules for incoming traffic.
    from_port   = 22                        # Allow incoming traffic on port 22, which is used for SSH.
    to_port     = 22                        # Allow incoming traffic on port 22.
    protocol    = "tcp"                     # Specify that the protocol is TCP (Transmission Control Protocol).
    cidr_blocks = ["0.0.0.0/0"]             # Allow SSH connections from any IP address (0.0.0.0/0); be cautious with this in production.
  }

  egress {                                   # Define rules for outgoing traffic.
    from_port   = 0                          # Allow all outbound traffic (0 means any port).
    to_port     = 0                          # Allow all outbound traffic.
    protocol    = "-1"                       # -1 means all protocols (allows any type of traffic).
    cidr_blocks = ["0.0.0.0/0"]              # Allow all outbound traffic to any IP address.
  }
}

# Create an Internet Gateway to provide internet access to your VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Create a route table to route internet traffic through the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"                 # Route all traffic to the internet
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the route table with your subnet
resource "aws_route_table_association" "my_rt_association" {
  subnet_id      = aws_subnet.my_subnet.id   # Associate the route table with your subnet
  route_table_id = aws_route_table.public_rt.id
}

# Create an EC2 instance
# EC2 (Elastic Compute Cloud) is a web service that provides resizable compute capacity in the cloud.
# An EC2 instance is a virtual server in AWS that you can use to run applications.
resource "aws_instance" "example2" {
  ami                    = "ami-08d8ac128e0a1b91c"  # Specify the Amazon Machine Image (AMI) ID to use for the instance.
  instance_type          = "t2.micro"               # Specify the instance type; t2.micro is a low-cost, general-purpose instance type.
  subnet_id              = aws_subnet.my_subnet.id  # Place the instance in the created subnet so it can communicate with other resources.
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]  # Attach the security group to the instance for controlling traffic.
  associate_public_ip_address = true                # Ensure the instance gets a public IP
  user_data              = file("user-data.sh")     # Provide a user data script to execute on instance startup; useful for automation (like installing software).
  tags = {                                           # Assign tags to the instance for better identification and management.
    Name = "MyInstance2"                          # Assign a name tag to the instance.
  }
}
