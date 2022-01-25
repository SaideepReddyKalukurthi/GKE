provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_container_cluster" "demo-1" {
    name = var.cluster_name
    location = "${var.region}-a"
    project = var.project_id
    initial_node_count = 2 
}

data "google_client_config" "default" {}


module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  project_id           = var.project_id
  cluster_name         = google_container_cluster.demo-1.name
  location             = google_container_cluster.demo-1.location
  use_private_endpoint = false
}

# provider "kubernetes" {
#   cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
#   host                   = module.gke_auth.host
#   token                  = module.gke_auth.token

# }

provider "kubernetes" {
  host                   = "https://${google_container_cluster.demo-1.endpoint}"
  token                  = module.gke_auth.token
#   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
   cluster_ca_certificate = module.gke_auth.cluster_ca_certificate

}

resource "kubernetes_deployment" "first-deployment" {
  metadata {
    name = "k8-app"
    labels = {
      app="k8-app-prod"
    }

  }

  spec {
   selector {
     match_labels = {
       app="k8-app-prod"
     }
   }
    replicas = "3"
    template {
      metadata {
        labels = {
          app="k8-app-prod"
        }
      }
      spec {
        container {
          name = "k8-app"
         image = "gcr.io/triple-baton-337806/sai@sha256:1688963903b902d183c4e9f854f96ee178f8123b925ad6bc8ff252b834076167" 
         port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "first-service" {
  depends_on = [kubernetes_deployment.first-deployment]
  metadata {
      
       name="k8-app-prod"
    labels = {
        app="k8-app-prod"
    }

  }
  spec {
    port {
      port = 8080
      protocol = "TCP"
      target_port = "80"
    }
 selector = {
      app="k8-app-prod"

    }
    type = "LoadBalancer"
  }
}