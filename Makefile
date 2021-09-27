# File: /Makefile
# Project: mkpm-stable
# File Created: 27-09-2021 17:41:09
# Author: Clay Risser
# -----
# Last Modified: 27-09-2021 17:55:50
# Modified By: Clay Risser
# -----
# BitSpur Inc (c) Copyright 2021
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include mkpm.mk

FIND ?= find
GIT ?= git
MKPM_NAME ?= unknown

.PHONY: lfs
ifeq ($(shell $(GIT) lfs $(NOOUT) && echo true || echo false),true)
lfs:
else
ifeq ($(PLATFORM),linux)
ifeq ($(FLAVOR),debian)
lfs: sudo
	@sudo apt-get install -y git-lfs
	@git lfs install
endif
endif
ifeq ($(PLATFORM),darwin)
lfs:
	@brew install git-lfs
	@git lfs install
endif
endif
ifneq ($(shell cat .gitattributes 2>$(NULL) | $(GREP) -q '*.tar.gz' $(NOOUT) && echo true || echo false),true)
	@$(GIT) lfs track "*.tar.gz"
endif

.PHONY: publish
publish:
	@echo $(GIT) add $(MKPM_NAME)/$(MKPM_NAME).tar.gz
	@echo $(GIT) commit $(MKPM_NAME).tar.gz -m "Publish $(MKPM_NAME) version $(MKPM_VERSION)" $(NOFAIL)
	@echo $(GIT) tag $(MKPM_NAME)/$(MKPM_VERSION)
	@echo $(GIT) push
	@echo $(GIT) push --tags
