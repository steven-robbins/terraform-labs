
module "k8s-control-plane" {
  source = "../modules/k8s-control-plane"
  cluster_name = "lab1"
  key_name = "workstation"
}

module "k8s-data-plane" {
  source = "../modules/k8s-data-plane"
  cluster_name = "lab1"
  key_name = "workstation"
  bucket_name = module.k8s-control-plane.bucket_name
}