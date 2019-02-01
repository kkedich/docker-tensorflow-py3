# Commands
DOCKER_COMMAND=docker
NVIDIA_DOCKER_COMMAND=nvidia-docker
CPU_DOCKER_FILE=Dockerfile.cpu
GPU_DOCKER_FILE=Dockerfile.gpu

# Docker image
SVC_CPU=tensorflow-py3
SVC_GPU=tensorflow-py3
VERSION=latest
REGISTRY_URL=kbogdan

# Tag version of Tensorflow
TAG_VERSION_TF_GPU=1.11.0-gpu-py3 # latest-gpu-py3
TAG_VERSION_TF_CPU=1.11.0-py3     # latest-py3

# Volumes
MY_OUTSIDE_VOLUME_GPU=/home/work-local/
MY_OUTSIDE_VOLUME_CPU=/home/work-local/

MY_INSIDE_VOLUME_GPU=/work/
MY_INSIDE_VOLUME_CPU=/work/

# Container
NAME_CONTAINER=kbogdan-tf


build-cpu:
	@echo "[build] Building cpu docker image..."
	@$(DOCKER_COMMAND) build --build-arg TAG_VERSION=$(TAG_VERSION_TF_CPU) -t $(REGISTRY_URL)/$(SVC_CPU):$(VERSION) -f $(CPU_DOCKER_FILE) .
	@echo "[build] Delete old versions..."
	@$(DOCKER_COMMAND) images|sed "1 d"|grep "<none> *<none>"|awk '{print $$3}'|sort|uniq|xargs $(DOCKER_COMMAND) rmi -f
build-gpu:
	@echo "[build] Building gpu docker image..."
	@$(DOCKER_COMMAND) build --build-arg TAG_VERSION=$(TAG_VERSION_TF_GPU) -t $(REGISTRY_URL)/$(SVC_GPU):$(VERSION) -f $(GPU_DOCKER_FILE) .
	@echo "[build] Delete old versions..."
	@$(DOCKER_COMMAND) images|sed "1 d"|grep "<none> *<none>"|awk '{print $$3}'|sort|uniq|xargs $(DOCKER_COMMAND) rmi -f
run-cpu:
	@echo "[run] Running cpu docker image..."
	@$(DOCKER_COMMAND) run -it -p 8888:8888 -p 6006:6006 -v $(MY_OUTSIDE_VOLUME_CPU):$(MY_INSIDE_VOLUME_CPU) --name $(NAME_CONTAINER) $(REGISTRY_URL)/$(SVC_CPU):$(VERSION) /bin/bash
run-gpu:
	@echo "[run] Running gpu docker image..."
	@$(NVIDIA_DOCKER_COMMAND) run -it -v $(MY_OUTSIDE_VOLUME_GPU):$(MY_INSIDE_VOLUME_GPU) --name $(NAME_CONTAINER) $(REGISTRY_URL)/$(SVC_GPU):$(VERSION) /bin/bash
upload-cpu:
	@echo "[upload] Uploading cpu docker image..."
	@$(DOCKER_COMMAND) push $(REGISTRY_URL)/$(SVC_CPU)
upload-gpu:
	@echo "[upload] Uploading gpu docker image..."
	@$(DOCKER_COMMAND) push $(REGISTRY_URL)/$(SVC_GPU)
clean:
	@echo "[clean] Cleaning docker images..."
	@$(DOCKER_COMMAND) rmi -f $(REGISTRY_URL)/$(SVC_GPU):$(VERSION)
	@$(DOCKER_COMMAND) rmi -f $(REGISTRY_URL)/$(SVC_GPU):$(VERSION)
