terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider (us-west-2)
provider "aws" {
  region = "us-west-2"
}

# Second region provider
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Third region provider
provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}
