#!/usr/bin/env bash
# Put official 1017 on every node. If 48 shards are already there, do nothing.
# Never deletes a shard. Never re-downloads a complete tree.
set -euo pipefail
SSH_USER="${SSH_USER:-$USER}"
FAB_IPS="${FAB_IPS:-10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8}"
MODEL_HOST="${MODEL_HOST:-/var/tmp/models/DeepSeek-V4.1-Flash-1017}"
REPO="${REPO:-deepseek-ai/DeepSeek-V4.1-Flash-1017}"
read -r -a FAB <<< "$FAB_IPS"
[ "${#FAB[@]}" -eq 8 ] || { echo "FAB_IPS needs 8 addresses" >&2; exit 2; }

count_local() { ls "$MODEL_HOST"/*.safetensors 2>/dev/null | wc -l | tr -d ' '; }
count_remote() {
  ssh -o BatchMode=yes -o ConnectTimeout=12 "${SSH_USER}@$1" "ls '$MODEL_HOST'/*.safetensors 2>/dev/null | wc -l" | tr -d ' '
}

head_n=$(count_local)
echo "head shards=$head_n path=$MODEL_HOST"
if [ "$head_n" = "48" ]; then
  echo "SKIP download: head already has 48 shards"
else
  echo "head is short ($head_n/48). Downloading $REPO once."
  mkdir -p "$MODEL_HOST"
  if command -v hf >/dev/null 2>&1; then
    hf download "$REPO" --local-dir "$MODEL_HOST"
  elif command -v huggingface-cli >/dev/null 2>&1; then
    huggingface-cli download "$REPO" --local-dir "$MODEL_HOST"
  elif python3 -c 'import huggingface_hub' >/dev/null 2>&1; then
    python3 -c 'from huggingface_hub import snapshot_download; snapshot_download("'"$REPO"'", local_dir="'"$MODEL_HOST"'")'
  else
    echo "No hf / huggingface-cli / huggingface_hub, and the head does not already have 48 shards." >&2
    exit 2
  fi
  head_n=$(count_local)
  [ "$head_n" = "48" ] || { echo "download finished with $head_n/48 shards" >&2; exit 1; }
fi

for ip in "${FAB[@]}"; do
  if ip -4 addr show 2>/dev/null | grep -q "inet ${ip}/"; then
    echo "SKIP copy $ip (this host)"
    continue
  fi
  n=$(count_remote "$ip" || echo 0)
  if [ "$n" = "48" ]; then
    echo "SKIP copy $ip already has 48 shards"
    continue
  fi
  echo "copy $ip has $n/48; rsync from head"
  ssh -o BatchMode=yes "${SSH_USER}@${ip}" "mkdir -p '$MODEL_HOST'"
  rsync -a --partial "$MODEL_HOST"/ "${SSH_USER}@${ip}:$MODEL_HOST"/
  n2=$(count_remote "$ip")
  [ "$n2" = "48" ] || { echo "copy to $ip ended at $n2/48" >&2; exit 1; }
  echo "copy $ip now 48"
done
echo "WEIGHTS_OK"
