# Pins

Verified 2026-10-19.

| Item | Value |
|------|--------|
| Weights | `deepseek-ai/DeepSeek-V4.1-Flash-1017` |
| Path | `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48/48 shards) |
| Tony recipe commit | `a2664a7` |
| vLLM image | `vllm-dsv41:overlay5` |
| Image id | `sha256:c92feb5ffab6f15cb5d1330abd448ef1664a6f13bfeae616982b73bf2a4baaf9` |
| TEXT_ONLY | `0` |
| GMU / max-model-len | `0.75` / `1048576` |
| Fabric | `10.99.20.1`–`.8` rank 0–7 |
| Bench | Tony `bench/v41bench.py`, label `tp8-1017-1m` |
