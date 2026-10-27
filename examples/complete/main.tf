provider "alicloud" {
  region = "cn-zhangjiakou"
}

data "alicloud_instance_types" "default" {
  #  kubernetes_node_role = "Worker"
  cpu_core_count = 4
  memory_size    = 8
}

#############################################################
# create managed-kubernetes
#############################################################

module "managed-k8s" {
  source  = "terraform-alicloud-modules/managed-kubernetes/alicloud"
  version = "2.0.0"

  k8s_name_prefix       = "tf-example"
  cluster_spec          = "ack.pro.small"
  cpu_core_count        = 4
  memory_size           = 8
  new_vpc               = true
  k8s_pod_cidr          = cidrsubnet("10.0.0.0/8", 8, 36)
  k8s_service_cidr      = cidrsubnet("172.16.0.0/16", 4, 7)
  worker_instance_types = [data.alicloud_instance_types.default.instance_types[0].id]
  kubernetes_version    = "1.24.6-aliyun.1"
  cluster_addons = [
    {
      name   = "flannel",
      config = "",
    },
    {
      name   = "flexvolume",
      config = "",
    },
    {
      name   = "alicloud-disk-controller",
      config = "",
    },
    {
      name   = "logtail-ds",
      config = "{\"IngressDashboardEnabled\":\"true\"}",
    },
    {
      name   = "nginx-ingress-controller",
      config = "{\"IngressSlbNetworkType\":\"internet\"}",
    },
  ]
}

data "alicloud_cs_cluster_credential" "auth" {
  cluster_id                 = module.managed-k8s.this_k8s_id
  temporary_duration_minutes = 60
}

locals {
  kube_config = yamldecode(data.alicloud_cs_cluster_credential.auth.kube_config)
}

provider "kubernetes" {
  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.kube_config.users[0].user["client-certificate-data"])
  client_key             = base64decode(local.kube_config.users[0].user["client-key-data"])
}

module "k8s" {
  source = "../.."

  wordpress_version = "7.1.3-php8.3"
  mysql_password    = "Abc1234"

  depends_on = [data.alicloud_cs_cluster_credential.auth]
}
