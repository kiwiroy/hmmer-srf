# -*- mode: makefile -*-
PREFIX=/opt/singularity
RECIPE_FILE=Singularity

GIT_TOPLEVEL=$(shell git rev-parse --show-toplevel)
GIT_DIRTY=$(shell git status --porcelain)

IMAGE_NAME=$(shell basename $(GIT_TOPLEVEL) -srf)
IMAGE_VERSION=latest
IMAGE_FILE=$(IMAGE_NAME)-$(IMAGE_VERSION).sif

BUILD_OPTIONS=
SOURCE_DEPS=
SYMLINK_COMMAND=singularity exec $(IMAGE_FILE) cat /opt/hmmer-commands | xargs -n1 ln -sf $(IMAGE_FILE)

.PHONY: all run symlinks clean up-to-date build install
all: build

run: clean build

symlinks: $(IMAGE_FILE)
	@$(SYMLINK_COMMAND)

clean:
	@rm -rf $(IMAGE_FILE)

$(IMAGE_FILE): $(RECIPE_FILE) $(SOURCE_DEPS)
	@echo Will build $(IMAGE_FILE) from $(RECIPE_FILE)
	@singularity build $(BUILD_OPTIONS) $(IMAGE_FILE) $(RECIPE_FILE)

up-to-date:
	@test -z "$(GIT_DIRTY)" || { echo "repository is dirty, stash or commit" && exit 1; }

build: up-to-date $(IMAGE_FILE)

install: build
	@install -d $(PREFIX)/bin/
	@install $(IMAGE_FILE) $(PREFIX)/bin/
	@cd $(PREFIX)/bin/ && $(SYMLINK_COMMAND)

dist: NAME_VERSION=$(IMAGE_NAME)-$(IMAGE_VERSION)
dist: build
	@make install PREFIX=$(NAME_VERSION)
	@tar -zcf $(NAME_VERSION).tar.gz $(NAME_VERSION)
	@rm -rf $(NAME_VERSION)
