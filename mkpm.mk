# File: /mkpm.mk
# Project: mkpm-stable
# File Created: 27-09-2021 17:41:23
# Author: Clay Risser
# -----
# Last Modified: 30-09-2021 04:38:46
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
define mkdir_p
mkdir -p $1
endef
ifeq ($(OS),Windows_NT)
	NULL = nul
	SHELL = cmd.exe
	.SHELLFLAGS = /q /v /c
define mkdir_p
cmd.exe /q /v /c "set p=$1 & mkdir !p:/=\! 2>nul || echo >nul"
endef
endif
-include $(MKPM_PACKAGE_DIR)/.bootstrap.mk
$(MKPM_PACKAGE_DIR)/.bootstrap.mk:
	@$(call mkdir_p,$(MKPM_PACKAGE_DIR))
	@cd $(MKPM_PACKAGE_DIR) && \
		$(shell curl --version >$(NULL) 2>$(NULL) && \
			echo curl -L -o || \
			echo wget --content-on-error -O) \
		.bootstrap.mk $(MKPM_BOOTSTRAP) >$(NULL)
############## MKPM BOOTSTRAP SCRIPT END ##############
