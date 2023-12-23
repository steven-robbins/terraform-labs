
module "k8s-control-plane" {
  source = "../modules/k8s-control-plane"
  cluster_name = "lab1"
  key_name = "workstation"
}

module "k8s-data-plane-1" {
  source = "../modules/k8s-data-plane"
  cluster_name = "lab1"
  key_name = "workstation"
  bucket_name = module.k8s-control-plane.bucket_name
}

module "k8s-data-plane-2" {
  source = "../modules/k8s-data-plane"
  cluster_name = "lab1"
  key_name = "workstation"
  bucket_name = module.k8s-control-plane.bucket_name
}

output "control-plane-dns" {
  module.k8s-control-plane.public-dns
}

output "data-plane-1-dns" {
  module.k8s-data-plane-1.public-dns
}

output "data-plane-2-dns" {
  module.k8s-data-plane-2.public-dns
}