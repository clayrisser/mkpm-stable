include mkpm.mk

FIND ?= find
GIT ?= git
MKPM_NAME ?= unknown

.PHONY: publish
publish:
	@echo $(GIT) add $(MKPM_NAME)/$(MKPM_NAME).tar.gz
	@echo $(GIT) commit $(MKPM_NAME).tar.gz -m "Publish $(MKPM_NAME) version $(MKPM_VERSION)" $(NOFAIL)
	@echo $(GIT) tag $(MKPM_NAME)/$(MKPM_VERSION)
	@echo $(GIT) push
	@echo $(GIT) push --tags
