resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my-vpc"
    }
  
}

resource "aws_subnet" "test"{
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "dev-subnet"
    }
}

## Here VPC coud reference name is my-vpc
## resource local reference name is dev
