#!/usr/bin/env bash
# Check the eight nodes. Does not stop containers, download weights, or build images.
set -euo pipefail
SSH_USER="${SSH_USER:-$USER}"
FAB_IPS="${FAB_IPS:-10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8}"
TONY_COMMIT="${TONY_COMMIT:-a2664a7}"
IMAGE="${IMAGE:-vllm-dsv41:overlay5}"
MODEL_HOST="${MODEL_HOST:-/var/tmp/models/DeepSeek-V4.1-Flash-1017}"
PATCH_DIR="${PATCH_DIR:-$HOME/dsv41-recipe/patch}"
read -r -a FAB <<< "$FAB_IPS"
[ "${#FAB[@]}" -eq 8 ] || { echo "FAB_IPS needs 8 addresses" >&2; exit 2; }

fail=0
bad() { echo "FAIL $*" >&2; fail=1; }

on_node() {
  local ip="$1"
  local snippet="$2"
  if ip -4 addr show 2>/dev/null | grep -q "inet ${ip}/"; then
    bash -c "$snippet"
  else
    ssh -o BatchMode=yes -o ConnectTimeout=12 "${SSH_USER}@${ip}" "bash -c $(printf '%q' "$snippet")"
  fi
}

echo "doctor $(date -u +%FT%TZ) image=$IMAGE tony_prefix=$TONY_COMMIT"
echo "this script does not stop containers"
for ip in "${FAB[@]}"; do
  echo "---- $ip"
  snippet=$(cat <<EOF
set -euo pipefail
MODEL_HOST='$MODEL_HOST'
IMAGE='$IMAGE'
PATCH_DIR='$PATCH_DIR'
TONY_COMMIT='$TONY_COMMIT'
shards=\$(ls "\$MODEL_HOST"/*.safetensors 2>/dev/null | wc -l | tr -d ' ')
echo "shards=\$shards"
if docker image inspect "\$IMAGE" >/dev/null 2>&1; then echo image=yes; else echo image=no; fi
if [ -f "\$PATCH_DIR/mounts.txt" ]; then
  miss=0
  while read -r f rel; do
    [ -z "\$f" ] && continue
    [ -f "\$PATCH_DIR/\$f" ] || miss=\$((miss+1))
  done < "\$PATCH_DIR/mounts.txt"
  echo "patches_missing=\$miss"
else
  echo "patches_missing=no-manifest"
fi
repo=\$(dirname "\$PATCH_DIR")
if git -C "\$repo" rev-parse HEAD >/dev/null 2>&1; then
  echo "tony=\$(git -C "\$repo" rev-parse --short=12 HEAD)"
else
  echo "tony=not-a-git-checkout"
fi
if command -v ibdev2netdev >/dev/null 2>&1; then
  up=\$(ibdev2netdev | awk '/Up/{c++} END{print c+0}')
  echo "ib_up=\$up"
  ibdev2netdev | awk '/Up/{print}'
else
  echo "ib_up=0"
  echo "ibdev2netdev-missing"
fi
st=\$(docker ps --filter name=^vllm_dsv41\$ --format '{{.Status}}' | head -1)
echo "container=\${st:-none}"
EOF
)
  if ! out=$(on_node "$ip" "$snippet" 2>&1); then
    bad "$ip ssh or check failed"
    echo "$out"
    continue
  fi
  echo "$out"
  echo "$out" | grep -q '^shards=48$' || bad "$ip shards are not 48"
  echo "$out" | grep -q '^image=yes$' || bad "$ip image $IMAGE missing"
  echo "$out" | grep -q '^patches_missing=0$' || bad "$ip Tony patch files missing under $PATCH_DIR"
  tony=$(echo "$out" | awk -F= '/^tony=/{print $2}')
  case "$tony" in
    "$TONY_COMMIT"*) ;;
    not-a-git-checkout) bad "$ip patch dir is not Tony checkout $TONY_COMMIT" ;;
    *) bad "$ip Tony commit $tony does not match $TONY_COMMIT" ;;
  esac
  echo "$out" | grep -q '^ib_up=0$' && bad "$ip no Up RoCE device"
done

if [ "$fail" -ne 0 ]; then
  echo "DOCTOR_FAIL"
  exit 1
fi
echo "DOCTOR_OK"
