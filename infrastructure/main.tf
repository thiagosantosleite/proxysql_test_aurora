terraform {
  backend "local" {
    path = "local-state/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}
