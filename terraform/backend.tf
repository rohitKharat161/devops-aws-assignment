terraform {
  backend "s3" {
    bucket = "devops-assignment-tfstate-587806480204"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}