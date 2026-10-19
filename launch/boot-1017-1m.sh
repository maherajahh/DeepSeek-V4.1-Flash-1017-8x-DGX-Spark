#!/usr/bin/env bash
# Boot official DeepSeek-V4.1-Flash-1017, TP8, window 1,048,576.
# Run this on the head (rank 0). It copies launch/dsv41-tp8.sh to each node
# as ~/dsv41-tp8.sh, starts workers 7→1, then the head.
# Stops only the container named vllm_dsv41. Does not touch any other stack.
#
# Edit if your lab is different:
#   SSH_USER=you FAB_IPS="10.0.0.1 10.0.0.2 ...8 addrs" NCCL_IB_ADDR_RANGE=10.0.0.0/24 ./launch/boot-1017-1m.sh
set -euo pipefail
cd "$(dirname "$0")"
LAUNCHER="$(pwd)/dsv41-tp8.sh"
test -f "$LAUNCHER"
SSH_USER="${SSH_USER:-$USER}"
FAB_IPS="${FAB_IPS:-10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8}"
NCCL_IB_ADDR_RANGE="${NCCL_IB_ADDR_RANGE:-10.99.20.0/24}"
read -r -a FAB <<< "$FAB_IPS"
[ "${#FAB[@]}" -eq 8 ] || { echo "FAB_IPS needs 8 addresses, got ${#FAB[@]}" >&2; exit 2; }

LOG=$HOME/logs/reboot-1017-1m.log
mkdir -p "$HOME/logs"
exec >>"$LOG" 2>&1
echo "==== REBOOT 1017 1M $(date -u +%FT%TZ) ===="

peer() { ssh -o BatchMode=yes -o ConnectTimeout=20 -o StrictHostKeyChecking=accept-new "${SSH_USER}@$1" "$2"; }
copy_to() { scp -o BatchMode=yes -o ConnectTimeout=20 "$LAUNCHER" "${SSH_USER}@$1:dsv41-tp8.sh"; }

echo "stop vllm_dsv41 only"
docker rm -f vllm_dsv41 2>/dev/null || true
for ip in "${FAB[@]:1}"; do
  peer "$ip" "docker rm -f vllm_dsv41 2>/dev/null || true" || true
done

echo "install launcher"
cp "$LAUNCHER" "$HOME/dsv41-tp8.sh"
for ip in "${FAB[@]:1}"; do
  copy_to "$ip"
done

ENVS="export TEXT_ONLY=0 SERVED_NAMES=\"deepseek-v4.1-flash-1017 deepseek-v4.1-flash\" MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 MAX_BATCHED=2048 EXP_NAME=boot1017-1m-bite2048 PATCH_DIR=\$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 FAB_IPS=\"${FAB_IPS}\" NCCL_IB_ADDR_RANGE=\"${NCCL_IB_ADDR_RANGE}\" NCCL_EXTRA=\"-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False\""

for r in 7 6 5 4 3 2 1; do
  ip="${FAB[$r]}"
  echo "launch rank $r $ip"
  peer "$ip" "$ENVS; \$HOME/dsv41-tp8.sh $r" || { echo "FAIL_RANK_$r"; exit 1; }
  sleep 4
done
echo "launch rank 0 ${FAB[0]}"
eval "$ENVS"
"$HOME/dsv41-tp8.sh" 0 || { echo FAIL_RANK_0; exit 1; }

for i in $(seq 1 90); do
  ml=$(curl -sf -m 4 http://127.0.0.1:8888/v1/models | python3 -c "import sys,json; print(json.load(sys.stdin)[\"data\"][0].get(\"max_model_len\",\"\"))" 2>/dev/null || true)
  echo "poll $i maxlen=$ml $(date -u +%T)"
  if [ "$ml" = "1048576" ]; then
    echo LIVE_1M
    exit 0
  fi
  sleep 20
done
echo FAIL_NO_1M
docker logs --tail 80 vllm_dsv41 || true
exit 1
