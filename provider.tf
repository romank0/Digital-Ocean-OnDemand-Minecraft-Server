variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "rcon_pwd" {}
variable "region" {}
variable "size" {}

variable "top_level_domain" {}
variable "subdomain" {}

provider "digitalocean" {
  token = var.do_token
}
