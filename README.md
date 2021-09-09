# Cosmos Network Ansible Automation
Cosmos 기반 블록체인 노드 자동 배포 및 모니터링 시스템
## 🏗️ 프로젝트 구조
```
cosmos-ansible/
├── ansible.cfg                 # Ansible 설정
├── inventory/
│   ├── hosts.yml              # 호스트 인벤토리
│   └── group_vars/
│       ├── all.yml            # 전역 변수
│       ├── validators.yml     # Validator 노드 변수
│       └── monitoring.yml     # 모니터링 서버 변수
├── playbooks/
│   ├── setup-base.yml         # 기본 서버 설정
│   ├── setup-node.yml         # 노드 설치
│   ├── setup-monitoring.yml   # 모니터링 서버 설정
│   ├── setup-exporters.yml    # 노드 Exporter 설치
│   ├── deploy-chain.yml       # 체인별 배포
│   ├── setup-auto-delegation.yml  # 자동 위임 설정
│   └── restore-snapshot.yml   # 스냅샷 복원
├── roles/
│   ├── common/                # 기본 패키지 및 설정
│   ├── golang/                # Go 언어 설치
│   ├── cosmovisor/            # Cosmovisor 설치
│   ├── cosmos-node/           # Cosmos 노드 공통 설정
│   ├── node-exporter/         # Prometheus Node Exporter
│   ├── cosmos-exporter/       # Cosmos 전용 Exporter
│   ├── prometheus/            # Prometheus 서버
│   ├── grafana/               # Grafana 대시보드
│   ├── alertmanager/          # Alertmanager + Slack
│   ├── auto-delegation/       # 자동 위임 스크립트
│   └── snapshot/              # 스냅샷 복원
├── chain_vars/                # 체인별 설정
│   ├── sei.yml
│   ├── archway.yml
│   ├── persistence.yml
│   ├── umee.yml
│   ├── lava.yml
│   └── ...
├── templates/                 # Jinja2 템플릿
├── scripts/                   # 유틸리티 스크립트
└── dashboards/                # Grafana 대시보드
```
## 🚀 빠른 시작
### 1. 사전 요구사항
```bash
# Ansible 설치 (로컬 머신)
pip3 install ansible
# 필요한 컬렉션 설치
ansible-galaxy collection install community.general
ansible-galaxy collection install community.crypto
```
### 2. 인벤토리 설정
`inventory/hosts.yml` 파일 수정:
```yaml
all:
  children:
    validators:
      hosts:
        sei-validator:
          ansible_host: 1.2.3.4
          chain_name: sei
        archway-validator:
          ansible_host: 5.6.7.8
          chain_name: archway
    monitoring:
      hosts:
        monitor-server:
          ansible_host: 9.10.11.12
```
### 3. 체인 설정
`chain_vars/<chain_name>.yml` 파일 수정:
```yaml
chain_id: "pacific-1"
binary_name: "seid"
binary_version: "v5.0.0"
denom: "usei"
# ... 기타 설정
```
### 4. 배포 실행
```bash
# 1. 기본 서버 설정 (모든 서버)
ansible-playbook playbooks/setup-base.yml
# 2. 모니터링 서버 설정
ansible-playbook playbooks/setup-monitoring.yml
# 3. 노드 설치 (특정 체인)
ansible-playbook playbooks/setup-node.yml -e "target_chain=sei"
# 4. Exporter 설치 (노드 서버)
ansible-playbook playbooks/setup-exporters.yml
# 5. 자동 위임 설정 (선택)
ansible-playbook playbooks/setup-auto-delegation.yml -e "target_chain=sei"
```
## 📊 모니터링
### 접속 정보
- **Grafana**: http://<monitoring-server>:3000
- **Prometheus**: http://<monitoring-server>:9090
- **Alertmanager**: http://<monitoring-server>:9093
### 기본 계정
- Grafana: admin / admin (최초 로그인 시 변경)
## 🔧 주요 명령어
### 노드 관리
```bash
# 노드 상태 확인
ansible validators -m shell -a "systemctl status cosmovisor"
# 노드 재시작
ansible validators -m shell -a "systemctl restart cosmovisor"
# 동기화 상태 확인
ansible validators -m shell -a "curl -s localhost:26657/status | jq .result.sync_info"
```
### 스냅샷 복원
```bash
# 스냅샷 복원
ansible-playbook playbooks/restore-snapshot.yml \
  -e "target_chain=sei" \
  -e "snapshot_url=https://snapshots.polkachu.com/snapshots/sei/sei_12345678.tar.lz4"
```
### 자동 위임
```bash
# 자동 위임 활성화
ansible-playbook playbooks/setup-auto-delegation.yml \
  -e "target_chain=sei" \
  -e "delegation_interval=3600"
```
## 📁 체인 추가 방법
1. `chain_vars/` 디렉토리에 새 체인 설정 파일 생성
2. 인벤토리에 새 호스트 추가
3. 배포 실행
## ⚠️ 주의사항
1. **키 보안**: `priv_validator_key.json`, `node_key.json`은 반드시 백업
2. **Double Signing**: 동일 validator key로 여러 노드 실행 금지
3. **방화벽**: 필요한 포트만 개방
