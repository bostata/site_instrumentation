SECRETS_TFVARS = "tfvars/secrets.tfvars"
STAGE_TFVARS = "tfvars/stage.tfvars"
STAGE_STATE = "tfstate/stage.tfstate"
PROD_TFVARS = "tfvars/prod.tfvars"
PROD_STATE = "tfstate/prod.tfstate"


init-stage:
	terraform init -var-file=$(SECRETS_TFVARS) -var-file=$(STAGE_TFVARS)


plan-stage:
	terraform plan -var-file=$(SECRETS_TFVARS) -var-file=$(STAGE_TFVARS) -state=$(STAGE_STATE)


apply-stage:
	terraform apply -var-file=$(SECRETS_TFVARS) -var-file=$(STAGE_TFVARS) -state=$(STAGE_STATE)


destroy-stage:
	terraform destroy -var-file=$(SECRETS_TFVARS) -var-file=$(STAGE_TFVARS) -state=$(STAGE_STATE)

init-prod:
	terraform init -var-file=$(SECRETS_TFVARS) -var-file=$(PROD_TFVARS)


plan-prod:
	terraform plan -var-file=$(SECRETS_TFVARS) -var-file=$(PROD_TFVARS) -state=$(PROD_STATE)


apply-prod:
	terraform apply -var-file=$(SECRETS_TFVARS) -var-file=$(PROD_TFVARS) -state=$(PROD_STATE)


destroy-prod:
	terraform destroy -var-file=$(SECRETS_TFVARS) -var-file=$(PROD_TFVARS) -state=$(PROD_STATE)
