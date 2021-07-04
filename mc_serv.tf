
# Add an A record to the domain for mc-server droplet.
resource "digitalocean_record" "subdomain" {
  domain = var.top_level_domain
  type   = "A"
  name   = var.subdomain
  value  = digitalocean_droplet.mc-server.ipv4_address
  ttl    = 30
}
resource "digitalocean_droplet" "mc-server" {
  image = "docker-18-04"
  name = var.subdomain
  region = var.region
  size = var.size
  private_networking = true
  ssh_keys = [
    var.ssh_fingerprint
  ]
  provisioner "file" {
    source      = "uploadFolder/"
    destination = "."
  }
  connection {
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
    host = digitalocean_droplet.mc-server.ipv4_address
  }
  provisioner "remote-exec" {
    inline = concat(
        [
            "wget https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz",
            "tar -xvzf mcrcon-0.7.1-linux-x86-64.tar.gz",
            "mv mcrcon-0.7.1-linux-x86-64/mcrcon /usr/local/bin",
            "tar -xvzf minecraft-server.tar.gz",
            "cd minecraft-server",
            "docker-compose up -d",
            "sleep 180",
            "docker-compose logs jre"
        ],
        formatlist("mcrcon -p %s \"whitelist add %s\"", "${var.rcon_pwd}", var.users),
        formatlist("mcrcon -p %s \"op %s\"", "${var.rcon_pwd}", var.ops),
        [
            "dig +short myip.opendns.com @resolver1.opendns.com"
        ]
    )
  }
  provisioner "remote-exec" {
    when    = destroy
    inline = [
      "mcrcon -H localhost -p ${var.rcon_pwd} save-all",
      "sleep 15", // TODO: Investigate the rcon solution to get status from mc server
      "mcrcon -H localhost -p ${var.rcon_pwd} stop",
      "sleep 15",
      "docker-compose down",
      "tar -cvzf minecraft-server.tar.gz minecraft-server",
    ]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "scp -i ${var.pvt_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${digitalocean_droplet.mc-server.ipv4_address}:minecraft-server.tar.gz uploadFolder"
  }
}

resource "digitalocean_firewall" "mc-server" {
  name = "only-22-and-25565"

  droplet_ids = [digitalocean_droplet.mc-server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "25565"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "25565"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
