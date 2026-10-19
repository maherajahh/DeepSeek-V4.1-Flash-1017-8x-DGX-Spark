#!/usr/bin/env bash
# Thirty-second check that the server is the 1017 boot. Does not send a long prompt.
# Does not stop anything.
set -euo pipefail
BASE="${BASE:-http://127.0.0.1:8888/v1}"
WANT_LEN="${WANT_LEN:-1048576}"
json=$(curl -sf -m 8 "$BASE/models") || { echo "SMOKE_FAIL cannot reach $BASE/models" >&2; exit 1; }
python3 -c '
import json, sys
want = int(sys.argv[1])
data = json.loads(sys.argv[2]).get("data") or []
ids = [m.get("id") for m in data]
hit = next((m for m in data if m.get("id") == "deepseek-v4.1-flash-1017"), None)
if hit is None:
    print("SMOKE_FAIL missing deepseek-v4.1-flash-1017; saw", ids)
    sys.exit(1)
got = hit.get("max_model_len")
if got != want:
    print("SMOKE_FAIL max_model_len", got, "want", want)
    sys.exit(1)
print("SMOKE_OK", hit.get("id"), "max_model_len", got)
' "$WANT_LEN" "$json"
