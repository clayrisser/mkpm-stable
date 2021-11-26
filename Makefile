# File: /Makefile
# Project: mkpm-stable
# File Created: 27-09-2021 17:41:09
# Author: Clay Risser
# -----
# Last Modified: 26-11-2021 02:03:42
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
ifneq (,$(MKPM_READY))

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
		export MKPM_PKG_NAME=$$(ENV_NAME=MKPM_PKG_NAME make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_PKG_VERSION=$$(ENV_NAME=MKPM_PKG_VERSION make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_PKG_DESCRIPTION=$$(ENV_NAME=MKPM_PKG_DESCRIPTION make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_PKG_SOURCE=$$(ENV_NAME=MKPM_PKG_SOURCE make -f $(MKPM_TMP)/info.mk) && \
		export MKPM_PKG_AUTHOR=$$(ENV_NAME=MKPM_PKG_AUTHOR make -f $(MKPM_TMP)/info.mk) && \
		\
		echo MKPM_PKG_NAME: $$MKPM_PKG_NAME && \
		echo MKPM_PKG_VERSION: $$MKPM_PKG_VERSION && \
		echo MKPM_PKG_DESCRIPTION: $$MKPM_PKG_DESCRIPTION && \
		echo MKPM_PKG_SOURCE: $$MKPM_PKG_SOURCE && \
		echo MKPM_PKG_AUTHOR: $$MKPM_PKG_AUTHOR && \
		\
		unset MKPM && \
		unset ROOT && \
		unset PROJECT_ROOT && \
		$(MAKE) -C $(PUBLISH_DIR) pack && \
		\
		echo $$ mkdir -p $$MKPM_PKG_NAME && \
		echo $$ cp $(PUBLISH_DIR)/$$MKPM_PKG_NAME.tar.gz $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz && \
		echo $$ $(GIT) add $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz && \
		echo $$ $(GIT) commit $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz -m "Publish $$MKPM_PKG_NAME version $$MKPM_PKG_VERSION" $(NOFAIL) && \
		echo $$ $(GIT) tag $$MKPM_PKG_NAME/$$MKPM_PKG_VERSION && \
		echo $$ $(GIT) push && \
		echo $$ $(GIT) push --tags && \
		\
		$(RUN) mkdir -p $$MKPM_PKG_NAME && \
		$(RUN) cp $(PUBLISH_DIR)/$$MKPM_PKG_NAME.tar.gz $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz && \
		$(RUN) $(GIT) add $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz && \
		$(RUN) $(GIT) commit $$MKPM_PKG_NAME/$$MKPM_PKG_NAME.tar.gz -m "Publish $$MKPM_PKG_NAME version $$MKPM_PKG_VERSION" $(NOFAIL) && \
		$(RUN) $(GIT) tag $$MKPM_PKG_NAME/$$MKPM_PKG_VERSION && \
		$(RUN) $(GIT) push && \
		$(RUN) $(GIT) push --tags
endif

.PHONY: clean
clean:
	@$(GIT) clean -fXd \
		$(MKPM_GIT_CLEAN_FLAGS)

.PHONY: purge
purge: clean
	@$(GIT) clean -fXd

endif
