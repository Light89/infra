terraform {
  backend "s3" {
    bucket                      = "ef-infra"
    key                         = "dev/terraform.tfstate"
    region                      = "eu-central-1" # Value is ignored but required by terraform AWS provider
    endpoint                    = "https://fsn1.your-objectstorage.com"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.60"
    }
  }
}
