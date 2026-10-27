variable "wordpress_version" {
  description = "The WordPress image version before the -apache suffix. Must be explicitly set, for example 7.1.3-php8.3."
  default     = null
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

