TERRAFORM_VERSION=1.1.6

include .env


load:
	echo ${ssh} ${AWS_REGION} ${ssh_key_path}

init:
	docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-w /workspace \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	init


plan: 
	docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-v ${ssh_key_path}:${ssh_key_path} \
	-w /workspace \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	plan \
	-var="ssh_key_path=${ssh_key_path}"



deploy: 
	docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-v ${ssh_key_path}:${ssh_key_path} \
	-w /workspace \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	apply \
	-var="ssh_key_path=${ssh_key_path}" \
	-auto-approve

destroy: 
	docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-v ${ssh_key_path}:${ssh_key_path} \
	-w /workspace \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	destroy \
	-var="ssh_key_path=${ssh_key_path}" \
	-auto-approve


output:
	docker run --rm -it --name terraform \
	-v $(shell pwd)/infra/terraform/:/workspace \
	-v ${ssh_key_path}:${ssh_key_path} \
	-w /workspace \
	-e AWS_REGION=${AWS_REGION} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	output -json > output.json


ssh: output
	ssh ubuntu@$(shell cat output.json | jq '.public_id.value')

test_api: output
	python3 api/test.py --host $(shell cat output.json | jq '.public_id.value')


chat_url: output
	echo http://$(shell cat output.json | jq -r '.public_dns.value'):7860
