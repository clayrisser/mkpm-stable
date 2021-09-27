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
