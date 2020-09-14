
# Dockerfile to be used
GPU_DOCKER_FILE=gpu.Dockerfile

# Docker image variables
SVC_GPU=tensorflow-opencv-py3
VERSION=1.13.2_latest
REGISTRY_URL=kbogdan

# Set variable to indicate if the docker is to be used locally
# In this case, for example, I want to run stuff as root and install jupyter
# You can comment this part if you want
LOCAL=True

TAG_VERSION_TF_GPU=1.13.2-gpu-py3 # latest-gpu-py3
TAG_VERSION_TF_GPU_LOCAL=1.13.2-gpu-py3-jupyter

ifeq ($(LOCAL), True)
    TAG_VERSION_TF_GPU = $(TAG_VERSION_TF_GPU_LOCAL)
endif

# Volumes
# Since the makefile is generally inside a 'docker' folder, we get
# the parent of current dir
MY_INSIDE_VOLUME_GPU=/work

# Container related
NAME_CONTAINER=kbogdan-tf1.13

# Check the docker version to correctly set the gpu command
docker_version=$(shell docker version --format '{{.Server.APIVersion}}')
ifeq ($(shell expr $(docker_version) \>= 1.40), 1)
    docker_gpu=--gpus all
else
    docker_gpu=--runtime=nvidia
endif


build-image:
	@echo "[build] Building gpu docker image..."
	@echo `id -ng ${USER}`
	@docker build \
	    --build-arg TAG_VERSION=$(TAG_VERSION_TF_GPU) \
	    --build-arg UID=`id -u` \
	    --build-arg GID=`id -g` \
	    --build-arg USER_NAME=${USER} \
	    --build-arg GROUP=`id -ng ${USER}` \
	    -t $(REGISTRY_URL)/$(SVC_GPU):$(VERSION) -f $(GPU_DOCKER_FILE) .
	@echo "\n[build] Delete old image versions..."
	@docker images|sed "1 d"|grep "<none> *<none>"|awk '{print $$3}'|sort|uniq|xargs docker rmi -f
run-container:
	@echo "[run] Running container for a gpu-based image..."
	@printf "<%s>\n" $(MY_OUTSIDE_VOLUME_GPU)
	@docker run -it $(docker_gpu) \
	    --userns=host \
	    -p 6010:6006 -p 8890:8888 \
	    -v ${shell cd ../ && pwd}:$(MY_INSIDE_VOLUME_GPU) \
	    --name $(NAME_CONTAINER) $(REGISTRY_URL)/$(SVC_GPU):$(VERSION) /bin/bash
run-local-container:
	@echo "[run] Running gpu docker image..."
	@docker run -it \
	    $(docker_gpu) \
	    -p 8888:8888 -p 6006:6006 \
	    -v ${shell cd ../ && pwd}:$(MY_INSIDE_VOLUME_GPU) \
	    --name $(NAME_CONTAINER) $(REGISTRY_URL)/$(SVC_GPU):$(VERSION) /bin/bash
upload-image:
	@echo "[upload] Uploading gpu docker image..."
	@docker push $(REGISTRY_URL)/$(SVC_GPU)
clean:
	@echo "[clean] Cleaning docker images..."
	@docker rmi -f $(REGISTRY_URL)/$(SVC_GPU):$(VERSION)
