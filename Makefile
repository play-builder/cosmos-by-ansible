# ============================================
# Cosmos Ansible Makefile
# ============================================

.PHONY: help setup-base setup-monitoring setup-node setup-exporters deploy restore-snapshot auto-delegation status backup lint

# Default target
help:
	@echo "============================================"
	@echo "Cosmos Ansible Automation"
	@echo "============================================"
	@echo ""
	@echo "Usage: make <target> [CHAIN=<chain_name>] [SNAPSHOT_URL=<url>]"
	@echo ""
	@echo "Targets:"
	@echo "  setup-base        - 기본 서버 설정 (모든 서버)"
	@echo "  setup-monitoring  - 모니터링 서버 설정"
	@echo "  setup-node        - 노드 설치 (CHAIN 필수)"
	@echo "  setup-exporters   - Exporter 설치"
	@echo "  deploy            - 전체 배포 (CHAIN 필수)"
	@echo "  restore-snapshot  - 스냅샷 복원 (CHAIN, SNAPSHOT_URL 필수)"
	@echo "  auto-delegation   - 자동 위임 설정 (CHAIN 필수)"
	@echo "  status            - 노드 상태 확인"
	@echo "  backup            - 키 백업"
	@echo "  lint              - Ansible 문법 검사"
	@echo ""
	@echo "Examples:"
	@echo "  make setup-monitoring"
	@echo "  make setup-node CHAIN=sei"
	@echo "  make deploy CHAIN=archway"
	@echo "  make restore-snapshot CHAIN=sei SNAPSHOT_URL=https://..."
	@echo ""
	@echo "============================================"

# Base setup for all servers
setup-base:
	ansible-playbook playbooks/setup-base.yml

# Setup monitoring server
setup-monitoring:
	ansible-playbook playbooks/setup-monitoring.yml

# Setup node (requires CHAIN)
setup-node:
ifndef CHAIN
	$(error CHAIN is required. Usage: make setup-node CHAIN=sei)
endif
	ansible-playbook playbooks/setup-node.yml -e "target_chain=$(CHAIN)"

# Setup exporters on validators
setup-exporters:
	ansible-playbook playbooks/setup-exporters.yml

# Full deployment (requires CHAIN)
deploy:
ifndef CHAIN
	$(error CHAIN is required. Usage: make deploy CHAIN=sei)
endif
	ansible-playbook playbooks/deploy-chain.yml -e "target_chain=$(CHAIN)"

# Restore snapshot (requires CHAIN and SNAPSHOT_URL)
restore-snapshot:
ifndef CHAIN
	$(error CHAIN is required. Usage: make restore-snapshot CHAIN=sei SNAPSHOT_URL=https://...)
endif
ifndef SNAPSHOT_URL
	$(error SNAPSHOT_URL is required. Usage: make restore-snapshot CHAIN=sei SNAPSHOT_URL=https://...)
endif
	ansible-playbook playbooks/restore-snapshot.yml -e "target_chain=$(CHAIN)" -e "snapshot_url=$(SNAPSHOT_URL)"

# Setup auto delegation (requires CHAIN)
auto-delegation:
ifndef CHAIN
	$(error CHAIN is required. Usage: make auto-delegation CHAIN=sei)
endif
	ansible-playbook playbooks/setup-auto-delegation.yml -e "target_chain=$(CHAIN)"

# Check status of all nodes
status:
	@chmod +x scripts/check-status.sh
	@./scripts/check-status.sh

# Backup validator keys
backup:
	@chmod +x scripts/backup-keys.sh
	@./scripts/backup-keys.sh

# Lint ansible files
lint:
	ansible-lint playbooks/*.yml
	ansible-playbook playbooks/setup-base.yml --syntax-check
	ansible-playbook playbooks/setup-monitoring.yml --syntax-check
	ansible-playbook playbooks/setup-node.yml --syntax-check -e "target_chain=sei"

# Generate SSH keys
ssh-keys:
	@chmod +x scripts/generate-ssh-keys.sh
	@./scripts/generate-ssh-keys.sh

# Ping all hosts
ping:
	ansible all -m ping

# List all hosts
hosts:
	ansible all --list-hosts
