data "alicloud_instance_types" "default" {
  #  kubernetes_node_role = "Worker"
  cpu_core_count = 1
  memory_size    = 2
}

#############################################################
# create managed-kubernetes
#############################################################

module "managed-k8s" {
  source  = "terraform-alicloud-modules/managed-kubernetes/alicloud"
  version = "1.6.0"

  k8s_name_prefix       = "tf-example"
  cluster_spec          = "ack.pro.small"
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
  output_file                = "./config"
}


provider "kubernetes" {
  config_path = data.alicloud_cs_cluster_credential.auth.output_file
}

module "k8s" {
  source = "../.."

  mysql_password = "Abc1234"

  depends_on = [data.alicloud_cs_cluster_credential.auth]
}
