# File: /Makefile
# Project: mkpm-stable
# File Created: 27-09-2021 17:41:09
# Author: Clay Risser
# -----
# Last Modified: 27-09-2021 19:15:36
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
ifneq (,$(MKPM))

GIT ?= git
DRYRUN ?= false
PUBLISH_DIR := $(MKPM_TMP)/publish

ifeq (true,$(DRYRUN))
	RUN := true
else
	RUN :=
endif

.PHONY: lfs
ifeq ($(shell $(GIT) lfs $(NOOUT) && echo true || echo false),true)
lfs:
else
ifeq ($(PLATFORM),linux)
ifeq ($(FLAVOR),debian)
lfs: sudo
	@sudo apt-get install -y git-lfs
	@$(GIT) lfs install
endif
endif
ifeq ($(PLATFORM),darwin)
lfs:
	@brew install git-lfs
	@$(GIT) lfs install
endif
endif
ifneq ($(shell cat .gitattributes 2>$(NULL) | $(GREP) -q '*.tar.gz' $(NOOUT) && echo true || echo false),true)
	@$(GIT) lfs track "*.tar.gz"
endif

.PHONY: publish
publish:
ifneq (,$(ARGS))
	@rm -rf $(MKPM_TMP)/info.mk $(NOFAIL)
	@mkdir -p $(PUBLISH_DIR) && rm -rf $(PUBLISH_DIR) $(NOFAIL)
	@export MKPM_PACKAGE_REPO=$$(echo $(ARGS) | $(SED) 's|\s.*$$||g') && \
		$(GIT) clone $$MKPM_PACKAGE_REPO $(PUBLISH_DIR) && \
		\
		echo "include $(PUBLISH_DIR)/mkpm.mk" > $(MKPM_TMP)/info.mk && \
		echo ".DEFAULT_GOAL := env" >> $(MKPM_TMP)/info.mk && \
		echo ".PHONY: env" >> $(MKPM_TMP)/info.mk && \
		echo "env:" >> $(MKPM_TMP)/info.mk && \
		echo '	@echo $$($$(ENV_NAME))' >> $(MKPM_TMP)/info.mk && \
		\
		export MKPM_NAME=$$(ENV_NAME=MKPM_NAME make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_VERSION=$$(ENV_NAME=MKPM_VERSION make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_DESCRIPTION=$$(ENV_NAME=MKPM_DESCRIPTION make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_PACKAGES=$$(ENV_NAME=MKPM_PACKAGES make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_SOURCES=$$(ENV_NAME=MKPM_SOURCES make -f $(MKPM_TMP)/info.mk) && \
		\
		echo MKPM_NAME: $$MKPM_NAME && \
		echo MKPM_VERSION: $$MKPM_VERSION && \
		echo MKPM_DESCRIPTION: $$MKPM_DESCRIPTION && \
		echo MKPM_PACKAGES: $$MKPM_PACKAGES && \
		echo MKPM_SOURCES: $$MKPM_SOURCES && \
		\
		echo $$ $(MAKE) -C $(PUBLISH_DIR) pack && \
		echo $$ mkdir -p $$MKPM_NAME && \
		echo $$ cp $(PUBLISH_DIR)/$$MKPM_NAME.tar.gz $$MKPM_NAME/$$MKPM_NAME.tar.gz && \
		echo $$ $(GIT) add $$MKPM_NAME/$$MKPM_NAME.tar.gz && \
		echo $$ $(GIT) commit $$MKPM_NAME/$$MKPM_NAME.tar.gz -m "Publish $$MKPM_NAME version $$MKPM_VERSION" $(NOFAIL) && \
		echo $$ $(GIT) tag $$MKPM_NAME/$$MKPM_VERSION && \
		echo $$ $(GIT) push && \
		echo $$ $(GIT) push --tags && \
		\
		$(RUN) $(MAKE) -C $(PUBLISH_DIR) pack && \
		$(RUN) mkdir -p $$MKPM_NAME && \
		$(RUN) cp $(PUBLISH_DIR)/$$MKPM_NAME.tar.gz $$MKPM_NAME/$$MKPM_NAME.tar.gz && \
		$(RUN) $(GIT) add $$MKPM_NAME/$$MKPM_NAME.tar.gz && \
		$(RUN) $(GIT) commit $$MKPM_NAME/$$MKPM_NAME.tar.gz -m "Publish $$MKPM_NAME version $$MKPM_VERSION" $(NOFAIL) && \
		$(RUN) $(GIT) tag $$MKPM_NAME/$$MKPM_VERSION && \
		$(RUN) $(GIT) push && \
		$(RUN) $(GIT) push --tags
endif

.PHONY: clean
clean:
	@$(GIT) clean -fXd

.PHONY: purge
purge: clean

endif
