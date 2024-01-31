output "slb_ip" {
  description = "The IP address of the SLB instance."
  value       = kubernetes_service.wordpress.status[0].load_balancer[0].ingress[0].ip
}