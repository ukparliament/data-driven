NAME = ukpds/data-driven

# GO_PIPELINE_COUNTER is the pipeline number, passed from our build agent.
GO_PIPELINE_COUNTER?="unknown"
DOCKER_SWARM_URL?="unknown"

# Construct the image tag.
VERSION=0.1.$(GO_PIPELINE_COUNTER)

build :
	docker-compose build

run :
	docker-compose up -d

runalone:
	docker run -p 80:3000 $(NAME)
	# Container port 3000 is specified in Dockerfile
	# Browse to http://localhost:80 to see the application

run-docker-cloud:
	docker-cloud stack up

runalone-docker-cloud:
	docker-cloud stack up -f docker-cloud.standalone.yml

rebuild :
	docker-compose down
	docker-compose up -d

test :
	docker-compose run web rake spec
	docker-compose down

push:
	docker build -t $(NAME):$(VERSION) -t $(NAME):latest .
	docker push $(NAME):$(VERSION)
	docker push $(NAME):latest
	docker rmi $(NAME):$(VERSION)
	docker rmi $(NAME):latest

deploy-ci:
	export DOCKER_HOST=$(DOCKER_SWARM_URL) && export IMAGE_NAME=$(NAME):$(VERSION) && docker-compose -f docker-compose.ci.yml down && docker-compose -f docker-compose.ci.yml up -d

# http://serverfault.com/questions/682340/update-the-container-of-a-service-in-amazon-ecs?rq=1
deploy-ecs-ci:
	aws ecs register-task-definition --cli-input-json file://./aws_ecs/data-driven.json
	aws ecs update-service --service DataDriven --cluster ecs-ci --region eu-west-1 --task-definition DataDriven

scale-ci:
	export DOCKER_HOST=$(DOCKER_SWARM_URL) && export IMAGE_NAME=$(NAME):$(VERSION) && docker-compose -f docker-compose.ci.yml scale web=3