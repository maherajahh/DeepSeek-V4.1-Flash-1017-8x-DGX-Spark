# Pins

Verified 2026-10-19.

| Item | Value |
|------|--------|
| Weights | `deepseek-ai/DeepSeek-V4.1-Flash-1017` @ `1bae0e1088993b9b82de08f59de5be5a34e42170` |
| Path | `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48/48 shards) |
| Tony recipe commit | `a2664a7e4ac7bc823ef29c8d7725abfe4d286f8a` |
| vLLM image | `vllm-dsv41:overlay5` |
| Image id | `sha256:c92feb5ffab6f15cb5d1330abd448ef1664a6f13bfeae616982b73bf2a4baaf9` |
| Server fingerprint | `vllm-0.28.1rc1.dev388+g8a728663c-tp8-d428ca86` |
| TEXT_ONLY | `0` |
| GMU / max-model-len | `0.75` / `1048576` |
| max-num-batched-tokens | `2048` (1024 will not boot with vision on) |
| Needle | depths 0.1 / 0.5 / 0.9 pass; prompts 1042741 / 1042513 / 1042394; bite 2048 |
| Fabric | `10.99.20.1`–`.8` rank 0–7 (`FAB_IPS` overrides) |
| Bench | Tony `bench/v41bench.py`, label `tp8-1017-1m-bite2048` (this boot) |
| Vision / tools | Tony demo 7/7 on this boot |
