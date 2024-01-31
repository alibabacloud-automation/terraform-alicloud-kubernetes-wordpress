output "slb_ip" {
  value       = module.k8s.slb_ip
  description = "The IP address of the SLB"
}