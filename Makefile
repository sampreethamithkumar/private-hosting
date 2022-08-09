# TODO: Update the AwsAccountID
AwsAccountId?=
AwsDefaultRegion?=ap-southeast-2
AppName?=PrivateHosting
ImageRepoName?=ecr-react-app
ImageTag?=latest
DockerRegistoryHost=${AwsAccountId}.dkr.ecr.${AwsDefaultRegion}.amazonaws.com

deploy-ecr:
	aws cloudformation deploy \
	--stack-name ecr-stack \
	--template-file ./ecr-template.yaml \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
		EcrName=${ImageRepoName}

docker-login:
	aws ecr get-login-password --region ${AwsDefaultRegion} | docker login --username AWS --password-stdin ${DockerRegistoryHost}

docker-build:
	docker build -t ${ImageRepoName}:${ImageTag} .
	docker tag ${ImageRepoName}:${ImageTag} ${DockerRegistoryHost}/${ImageRepoName}:${ImageTag}

docker-push:
	docker push ${AwsAccountId}.dkr.ecr.${AwsDefaultRegion}.amazonaws.com/${ImageRepoName}:${ImageTag}

deploy-private-hosting:
	aws cloudformation deploy \
	--stack-name ${AppName} \
	--template-file ./template.yaml \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides \
		PrefixName=${AppName} \
		DockerRegistoryHost=${DockerRegistoryHost} \
		DockerImage=${ImageRepoName}:${ImageTag} 

deploy: deploy-ecr docker-login docker-build docker-push deploy-private-hosting
