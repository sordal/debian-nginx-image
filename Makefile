ifdef VERSION
	project_version:=$(VERSION)
else
	project_version:=$(shell git rev-parse --short=8 HEAD)
endif

ifdef PROJECT_NAME
	project_name:=$(PROJECT_NAME)
else
	project_name:=$(shell basename $(CURDIR))
endif

ifdef SRC_DIR
	source_directory:=$(SRC_DIR)
else
	source_directory:=$(CURDIR)/image
endif

docker_cmd:=$(shell if [[ `docker ps` == *"CONTAINER ID"* ]]; then echo "docker";else echo "sudo docker";fi)
repository:=gcr.io/applegate-road-2829/$(project_name)
latest_image:=$(repository):latest
version_image:=$(repository):$(project_version)
docker_tag_cmd:=$(docker_cmd) tag
docker_compose_cmd:=$(shell if [[ `docker ps` == *"CONTAINER ID"* ]]; then echo "docker-compose";else echo "sudo docker-compose";fi)

settings:
	@echo [INFO] [settings]
	@echo [INFO]    project_version=$(project_version)
	@echo [INFO]    project_name=$(project_name)
	@echo [INFO]    docker_cmd=$(docker_cmd)
	@echo [INFO]    docker_tag_cmd=$(docker_tag_cmd)
	@echo [INFO]    repository=$(repository)
	@echo [INFO]    latest_image=$(latest_image)
	@echo [INFO]    version_image=$(version_image)
	@echo [INFO]    source_directory=$(source_directory)
	@echo [INFO]    docker_compose_cmd=$(docker_compose_cmd)
	@echo

help: settings
	@printf "\e[1;34m[INFO] [information]\e[00m\n\n"
	@echo [INFO] This make process supports the following targets:
	@echo [INFO]    clean   - clean up and targets in project
	@echo [INFO]    build   - build both the project and Docker image
	@echo [INFO]    push    - push image to repository
	@echo [INFO]    run     - run the service locally in development environment
	@echo
	@echo [INFO] The script supports the following parameters:
	@echo [INFO]    VERSION      - version to tag docker image wth, default value is the git hash
	@echo [INFO]    PROJECT_NAME - project name, default is git project name
	@echo [INFO]    SRC_DIR      - source code, default is "image"
	@echo
	@echo [INFO] This tool expects the project to be located in a directory called image.
	@echo [INFO] If there is a Makefile in the image directory, then this tool will execute it
	@echo [INFO] with either clean and build targets.
	@echo
	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     $(docker_cmd) run -t -i  $(version_image)
	@echo [INFO]
	@echo [INFO] Run as service with ports in interactive mode:
	@echo [INFO]
	@echo [INFO]     make run

build_source_directory:
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	@echo [DEBUG] Found Makefile
	$(MAKE) -C $(source_directory) build VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif

build_docker:
	$(docker_cmd) build --rm --build-arg PROJECT_VERSION=$(project_version) --build-arg PROJECT_NAME=$(project_name) --tag $(version_image) $(source_directory)
	$(docker_tag_cmd) $(version_image) $(latest_image)

	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     $(docker_cmd) run -t -i  $(version_image)
	@echo [INFO]
	@echo [INFO] Run as service with ports in interactive mode:
	@echo [INFO]
	@echo [INFO]     make run

build: settings build_source_directory build_docker

clean: settings
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	$(MAKE) -C $(source_directory) clean VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif
	$(docker_compose_cmd) rm -f

push_source_directory:
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	$(MAKE) -C $(source_directory) push VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif

push: settings push_source_directory build_docker
	$(docker_tag_cmd)  $(version_image) $(latest_image)
	$(docker_cmd) push $(version_image)
	$(docker_cmd) push $(latest_image)

run: settings
	$(docker_compose_cmd) up

