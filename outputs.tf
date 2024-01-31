output "slb_ip" {
  value = kubernetes_service.wordpress.status.0.load_balancer.0.ingress.0.ip
}