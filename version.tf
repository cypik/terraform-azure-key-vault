terraform {
  required_version = ">= 1.11.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.30.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }
  }
}