#!/usr/bin/env bash
set -euo pipefail
LOG=$HOME/logs/reboot-1017-1m.log
mkdir -p "$HOME/logs"
exec >>"$LOG" 2>&1
echo "==== REBOOT 1017 1M $(date -u +%FT%TZ) ===="
PEER() { ssh -o BatchMode=yes -o ConnectTimeout=20 -o StrictHostKeyChecking=accept-new "${USER}@10.99.20.$1" "$2"; }

echo "stop all 8"
for n in 1 2 3 4 5 6 7 8; do
  if [ "$n" = 1 ]; then
    docker rm -f vllm_dsv41 glm53 2>/dev/null || true
  else
    PEER "$n" "docker rm -f vllm_dsv41 glm53 2>/dev/null || true" || true
  fi
done

ENVS='export TEXT_ONLY=0 SERVED_NAMES="deepseek-v4.1-flash-1017 deepseek-v4.1-flash" MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 EXP_NAME=boot1017-1m PATCH_DIR=$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 NCCL_EXTRA="-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False"'

for r in 7 6 5 4 3 2 1; do
  n=$((r+1))
  echo "launch rank $r spark$n"
  PEER "$n" "$ENVS; \$HOME/dsv41-tp8-office.sh $r" || { echo FAIL_RANK_$r; exit 1; }
  sleep 4
done
echo "launch rank 0 spark1"
eval "$ENVS"
"$HOME/dsv41-tp8-office.sh" 0 || { echo FAIL_RANK_0; exit 1; }

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
