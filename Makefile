# Avic's dotfiles - single entry point. Run `make` for the menu.
#
# Every quality check runs pre-commit inside Dockerfile.pre-commit, so Docker
# is the only tool a machine needs. The container runs as the calling user, so
# hooks that fix files in place never leave them owned by root.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

ROOT_DIR  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
IMAGE     := avic-dotfiles-pre-commit:local
CACHE_DIR := $(HOME)/.cache/avic-dotfiles-pre-commit
HOOKS_DIR  = $(shell git -C "$(ROOT_DIR)" rev-parse --path-format=absolute --git-path hooks)

BOLD   := \033[1m
GREEN  := \033[32m
CYAN   := \033[36m
RESET  := \033[0m

# -t only when attached to a terminal, so colors work interactively while git
# hooks and CI still get plain output.
DOCKER = mkdir -p "$(CACHE_DIR)" && \
	docker run --rm $$([ -t 1 ] && echo -t) \
	  --user "$$(id -u):$$(id -g)" -e HOME=/tmp \
	  -v "$(ROOT_DIR)":/repo \
	  -v "$(CACHE_DIR)":/cache
DOCKER_RUN = $(DOCKER) $(IMAGE)

# The commit range pre-commit-pr-run checks: what a PR from HEAD would contain.
FROM_REF ?= origin/master
TO_REF   ?= HEAD

.DEFAULT_GOAL := help
.NOTPARALLEL:

##@ Setup
.PHONY: install
install: ## Symlink the dotfiles into $HOME (./init.sh)
	@"$(ROOT_DIR)/init.sh"

.PHONY: hooks
hooks: image ## Install git hooks that run pre-commit in Docker on commit and push
	@for stage in pre-commit pre-push; do \
	  printf '#!/bin/sh\n# Installed by `make hooks` - runs pre-commit in Docker.\nexec make -C "%s" --no-print-directory lint-staged STAGE=%s\n' \
	    "$(ROOT_DIR)" "$$stage" > "$(HOOKS_DIR)/$$stage"; \
	  chmod +x "$(HOOKS_DIR)/$$stage"; \
	done
	@printf "$(GREEN)hooks installed in $(HOOKS_DIR)$(RESET)\n"

.PHONY: unhook
unhook: ## Remove the git hooks
	@rm -f "$(HOOKS_DIR)/pre-commit" "$(HOOKS_DIR)/pre-push"
	@printf "$(GREEN)hooks removed$(RESET)\n"

##@ Quality
.PHONY: pre-commit-run
pre-commit-run: image ## Run every hook on every file, plus a secret scan of the tree
	@$(DOCKER_RUN) run --all-files
	@$(DOCKER_RUN) run --all-files --hook-stage manual gitleaks-tree

# Hooks on the files changed in FROM_REF..TO_REF, and gitleaks on those commits
# - so a secret added and then removed again within the PR is still caught.
.PHONY: pre-commit-pr-run
pre-commit-pr-run: image ## Run the hooks on a PR's changes: FROM_REF..TO_REF (what CI runs)
	@printf "$(BOLD)checking $(FROM_REF)..$(TO_REF)$(RESET)\n"
	@$(DOCKER_RUN) run --from-ref "$(FROM_REF)" --to-ref "$(TO_REF)"
	@$(DOCKER) --entrypoint gitleaks $(IMAGE) git --redact --no-banner \
	  --log-opts="$(FROM_REF)..$(TO_REF)"

STAGE ?= pre-commit
.PHONY: lint-staged
lint-staged: image ## Run the hooks on staged files only (what the git hooks call)
	@$(DOCKER_RUN) run --hook-stage $(STAGE)

.PHONY: shellcheck
shellcheck: image ## Run only shellcheck, on every script
	@$(DOCKER_RUN) run --all-files shellcheck

.PHONY: secrets
secrets: image ## Scan the working tree and the full git history for secrets
	@$(DOCKER_RUN) run --all-files --hook-stage manual gitleaks-tree
	@$(DOCKER_RUN) run --all-files --hook-stage manual gitleaks-history

.PHONY: autoupdate
autoupdate: image ## Bump the hook revisions in .pre-commit-config.yaml
	@$(DOCKER_RUN) autoupdate

##@ Docker
.PHONY: image
image: ## Build the pre-commit image (cached, fast when unchanged)
	@docker build -q -t $(IMAGE) - < "$(ROOT_DIR)/Dockerfile.pre-commit" >/dev/null

.PHONY: shell
shell: image ## Open a shell in the pre-commit image
	@docker run --rm -it --user "$$(id -u):$$(id -g)" -e HOME=/tmp -v "$(ROOT_DIR)":/repo \
	  -v "$(CACHE_DIR)":/cache --entrypoint bash $(IMAGE)

.PHONY: clean
clean: ## Remove the image and the hook cache
	@docker image rm -f $(IMAGE) >/dev/null 2>&1 || true
	@rm -rf "$(CACHE_DIR)"
	@printf "$(GREEN)cleaned$(RESET)\n"

##@ Help
.PHONY: help
help: ## Show this menu
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(BOLD)Avic'\''s dotfiles$(RESET)\n"} \
	      /^[a-zA-Z_.-]+:.*?##/ { printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2 } \
	      /^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@printf "\n"
