#Test de cambio

terraform {
  backend "s3"{
    bucket                 = "bucket-terraform-lab"
    region                 = "us-east-1"
    key                    = "backend.tfstate"
    dynamodb_table         = "terraformstatelock"
  }
}

