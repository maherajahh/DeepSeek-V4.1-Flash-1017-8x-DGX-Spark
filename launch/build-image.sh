#!/usr/bin/env bash
# Build vllm-dsv41:overlay5 from Tony's pinned recipe, or skip if that tag is already local.
# Does not delete images. Does not stop containers. Refuses to compile while vllm_dsv41 is running
# unless FORCE_BUILD=1 (a compile next to a live serve can lock the box).
set -euo pipefail
IMAGE="${IMAGE:-vllm-dsv41:overlay5}"
TONY_COMMIT="${TONY_COMMIT:-a2664a7e4ac7bc823ef29c8d7725abfe4d286f8a}"
TONY_URL="${TONY_URL:-https://github.com/tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark.git}"
TONY_DIR="${TONY_DIR:-$HOME/dsv41-recipe}"

if docker image inspect "$IMAGE" >/dev/null 2>&1; then
  id=$(docker image inspect "$IMAGE" --format '{{.Id}}')
  echo "SKIP build: $IMAGE already present ($id)"
  echo "IMAGE_OK"
  exit 0
fi

if docker ps --filter name=^vllm_dsv41$ --format '{{.Names}}' | grep -q . && [ "${FORCE_BUILD:-0}" != "1" ]; then
  echo "vllm_dsv41 is running and $IMAGE is missing. Refusing to compile beside a live serve." >&2
  echo "Stop the serve yourself, then re-run. This script will not stop it." >&2
  exit 2
fi

if [ -d "$TONY_DIR/.git" ]; then
  have=$(git -C "$TONY_DIR" rev-parse HEAD)
  case "$have" in
    "$TONY_COMMIT"*) ;;
    *) echo "Tony checkout at $TONY_DIR is $have, want $TONY_COMMIT. Not moving it." >&2; exit 2 ;;
  esac
else
  git clone "$TONY_URL" "$TONY_DIR"
  git -C "$TONY_DIR" checkout "$TONY_COMMIT"
fi

if ! docker image inspect vllm-dsv41:overlay4 >/dev/null 2>&1; then
  echo "overlay5 is Tony's last step. overlay4 is not on this node." >&2
  echo "Build his chain in $TONY_DIR first: Dockerfile.overlay, build/build_overlay3.sh, build/build_overlay4.sh." >&2
  echo "Pin is $TONY_COMMIT. Do not build those patches on a newer vLLM tree." >&2
  exit 2
fi

cp "$TONY_DIR/build/prewarm5.py" "$TONY_DIR/build/verify5.py" /tmp/
bash "$TONY_DIR/build/build_overlay5.sh"
docker image inspect "$IMAGE" >/dev/null
echo "IMAGE_OK"
