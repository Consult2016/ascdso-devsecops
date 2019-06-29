This repository (docker4aws) contains files copied from <a target="_blank" href="https://bootstrap-it.com/docker4aws/">https://bootstrap-it.com/docker4aws</a> created by David Clinton as part of his video class on Pluralsight <a target="_blank" href="https://app.pluralsight.com/library/courses/using-docker-aws/description">"Using Docker on AWS"</a>. The description for that class is:

> "Get yourself up to speed running your Docker workloads on AWS. Learn the CLI tools you'll need to manage containers using ECS - including Amazon's managed container launch type, Fargate - and Kubernetes (EKS) and the ECR image repo service."

Scripts here automate the create of a WordPress image in Dockerhub (<a target="_blank" href="https://hub.docker.com">https://hub.docker.com</a>).

<img width="20" height="20" src="https://wilsonmar.github.io/images/Video-icon-800x800.svg"> A link to the specific video making use of the file is provided.
But know you need a subscription to Pluralsight to see the video.

### Script for installing Docker on Ubuntu

(docker-ubuntu-install.sh)[docker-ubuntu-install.sh]

### A simple Dockerfile

simple/Dockerfile

### Build and run a container

docker-container-build.sh

### WordPress stack.yml file for local deployment

stack.yml

### Prepare an EC2 launch type

ecs-ec2-launch.yml

### docker-compose.yml for EC2 launch

docker-compose.yml

### ecs-params.yml for EC2 launch

ecs-params.yml

### Launch EC2 type

ecs-ec2-launch.sh

### YAML files for Fargate

ecs-fargate-launch.yml

### Launch Fargate type

ecs-fargate-launch.sh

### Install eksctl, kubectl, and aws-iam-authenticator

install-ecs-utils.sh

### Build Kubernetes cluster and download YAML files

eksctl-create-cluster.sh

### Build Apache webserver container on Docker CE

Apache/Dockerfile

### Apache on ECS

Apache/docker-compose.yml

### ECR authentication and administration

ecr-auth-admin.sh
