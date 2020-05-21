# azure-devops-workspace
ubuntu devops workspace running in azure


# terraform vars

adminAccountName = "notadmin"

adminSourceAddress = "192.168.100.100/32"

location = "eastus1"

region = "East US 1"

sshPublicKey="ssh-rsa AAAA....=="

onboardScript = "https://raw.githubusercontent.com/vinnie357/workspace-onboard-bash-templates/master/terraform/azure/sca/onboard.sh"

repositories = "https://github.com/Mikej81/terraform-azure-f5-scca.git,https://github.com/vinnie357/terraform-azure-bigiq.git"

# env vars
## tf cloud
```hcl
ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```
## bash
```bash
# azure
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```