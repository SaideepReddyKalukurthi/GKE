provider "google" {
    project = var.project_id
}


module "gke-demo" {
    source = "../../module/gkr"
    project_id = var.project_id
    region = var.region
    cluster_name = var.cluster_name
    

}