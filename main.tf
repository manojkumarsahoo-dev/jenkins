resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my-vpc"
    }
  
}

## Here VPC coud reference name is my-vpc
## resource local reference name is dev
