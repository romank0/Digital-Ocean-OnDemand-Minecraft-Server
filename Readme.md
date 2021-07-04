# On demand Minecraft Server with Terraform and Digital Ocean

Guide: https://medium.com/@vyrtualsynthese/on-demand-minecraft-server-with-terraform-and-digital-ocean-3afcc8a5fe90


Initialize:

```
RCON_PASSWORD=somepassword ./init.sh http://path/to/server.jar
```

Create `some-server.tfvars` from `terraform.tfstate.dist`.

Start:
```
terraform apply -var-file=some-server.tfvars
```

Stop:
```
terraform destroy -auto-approve -var-file=some-server.tfvars
```
