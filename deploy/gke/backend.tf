terraform {
  backend "gcs" {
      bucket = "sai-demo-bucket-001"
      prefix = "gke-cft-demo/state"
    
  }
}