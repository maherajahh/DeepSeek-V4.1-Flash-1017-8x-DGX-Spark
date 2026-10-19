# Pins

Verified 2026-10-19.

| Item | Value |
|------|--------|
| Weights | `deepseek-ai/DeepSeek-V4.1-Flash-1017` |
| Path | `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48/48 shards) |
| Tony recipe commit | `a2664a7` |
| vLLM image | `vllm-dsv41:overlay5` |
| Image id | `sha256:c92feb5ffab6f15cb5d1330abd448ef1664a6f13bfeae616982b73bf2a4baaf9` |
| Server fingerprint | `vllm-0.28.1rc1.dev388+g8a728663c-tp8-d428ca86` |
| TEXT_ONLY | `0` |
| GMU / max-model-len | `0.75` / `1048576` (configured; no 1M needle) |
| max-num-batched-tokens | `8192` |
| Fabric | `10.99.20.1`–`.8` rank 0–7 (`FAB_IPS` overrides) |
| Bench | Tony `bench/v41bench.py`, label `tp8-1017-1m` |
| Vision smoke | 32×32 red PNG → `Red` (`chatcmpl-9c40078ae228297e`) |
