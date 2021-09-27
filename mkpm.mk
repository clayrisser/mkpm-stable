# File: /mkpm.mk
# Project: mkpm-stable
# File Created: 27-09-2021 17:41:23
# Author: Clay Risser
# -----
# Last Modified: 27-09-2021 17:55:45
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

MKPM_PACKAGES := \

MKPM_SOURCES := \

MKPM_PACKAGE_DIR := .mkpm

NUMPROC := 1

############# MKPM BOOTSTRAP SCRIPT BEGIN #############
MKPM_BOOTSTRAP := https://bitspur.gitlab.io/community/mkpm/bootstrap.mk
NULL := /dev/null
MKDIR_P := mkdir -p
ifeq ($(OS),Windows_NT)
	MKDIR_P = mkdir
	NULL = nul
	SHELL := cmd.exe
endif
-include $(MKPM_PACKAGE_DIR)/.bootstrap.mk
$(MKPM_PACKAGE_DIR)/.bootstrap.mk:
	@$(MKDIR_P) $(MKPM_PACKAGE_DIR)
	@cd $(MKPM_PACKAGE_DIR) && \
		$(shell curl --version >$(NULL) 2>$(NULL) && \
			echo curl -Ls -o || \
			echo wget -q --content-on-error -O) \
		.bootstrap.mk $(MKPM_BOOTSTRAP) >$(NULL)
############## MKPM BOOTSTRAP SCRIPT END ##############