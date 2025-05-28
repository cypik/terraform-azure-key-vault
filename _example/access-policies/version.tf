
terraform {
  required_version = ">= 1.11.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.30.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}