variable "wordpress_version" {
  description = "The version of wordpress. Default to 4.7.3."
  default     = "4.7.3"
  type        = string
}

variable "mysql_password" {
  description = "Please input mysql password."
  type        = string
}
variable "mysql_version" {
  description = "The version of mysql which wordpress used. Default to 5.6."
  default     = "5.6"
  type        = string
}

