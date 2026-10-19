# DeepSeek-V4.1-Flash-1017 on 8× DGX Spark

**Status: LIVE** (2026-10-19). Official `deepseek-ai/DeepSeek-V4.1-Flash-1017`. TP8.

Eight NVIDIA DGX Spark (GB10), tensor-parallel 8. This is not Tony’s 4-Spark recipe claimed as ours. It is an **8-rank** run of **official 1017** using Tony’s Spark vLLM patches and Magnus’s 8-rank launcher shape.

Tony published 1017 on **four** Sparks (`boot1017g`, 300K). Magnus published 8-wide on **different** (uncensored) weights. This notebook is official 1017 on eight.

## What this is

| | |
|---|---|
| Model | `deepseek-ai/DeepSeek-V4.1-Flash-1017` (official) |
| Hardware | 8× DGX Spark, dual fat rear links. Measured fabric `10.99.20.1`–`.8`. Edit `FAB_IPS` for another lab. |
| Engine | vLLM `vllm-dsv41:overlay5`, Tony patches, TP=8 |
| Vision | on. This boot, Tony's demo: 3 images and 4 tool checks, 7/7. See [results/vision-tools-2048.md](results/vision-tools-2048.md). |
| Tools | same file. One weather call is not the whole check. Not a benchmark. |
| Context window | Cap `1048576`. Needle passed near the start, middle, and end. Prompts were 1,042,741 / 1,042,513 / 1,042,394 tokens. See [results/needle-1m.md](results/needle-1m.md). |
| Bite | `--max-num-batched-tokens 2048`. 1024 will not boot with vision on (image token budget is 1025). |
| API | head `:8888`, ids `deepseek-v4.1-flash-1017` and `deepseek-v4.1-flash` |

The serving bite is 2048. A 1024 bite dies at startup with vision on. The speed table is this boot, same process as the needle.

## Measured (Tony `v41bench.py`, prompt set v1, temperature 0, thinking off)

Same harness Tony used for 1017g. Counting ceiling excluded from the 8-category mean. His column is 4 Sparks at 300K, bite not ours. This column is 8 Sparks, window cap 1,048,576, bite 2048. Extra boxes help. They do not double decode. Long prompts are slower at this bite than on the earlier 8192 boot. This is not a TensorFold comparison. Tony’s TensorFold 4-Spark lane is still faster than this vLLM lane.

| C | this boot (8×, cap 1M, bite 2048) | Tony 1017g (4×, 300K) |
|---|---|---|
| C1 aggregate tok/s | **54.8** | 48.5 |
| C2 | **87.3** | 76.6 |
| C3 | **117.9** | 102.6 |
| C4 | **143.8** | 123.2 |
| C5 | **158.8** | 144.6 |
| C6 | **173.0** | 165.7 |
| C1 mean TTFT (s) | **0.26** | 0.28 |
| Cold prefill ~93K | **1286 tok/s** (73s) | ~42s on his writeup |
| Needle read, 1,042,513 tokens | **815.5 tok/s** (1278s) | not in his 1017g table |

One-user coding: **89.1 tok/s**.

Raw: [results/bench-tp8-1017-1m-bite2048.md](results/bench-tp8-1017-1m-bite2048.md), [results/bench-tp8-1017-1m-bite2048.json](results/bench-tp8-1017-1m-bite2048.json). The older 8192-bite table is [results/bench-tp8-1017-1m.md](results/bench-tp8-1017-1m.md). Do not mix them.

## What this is not

- Not Tony’s 4-box 1017 recipe
- Not Magnus’s uncensored checkpoint
- Not TensorFold / EXL3
- Not “we invented 8-wide DeepSeek”
- Not a vision benchmark (Tony's 3-image demo passed; that is not a vision suite)
- Not a tool-call benchmark (his 4 tool checks passed; that is not a suite)
- Not "the prompt was exactly 1,048,576 tokens" (the three prompts were 1,042,741 / 1,042,513 / 1,042,394; the cap is 1,048,576)

## Clone and serve

One path. Run these on the head. They do not stop a live container.

Weights stay at `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48 shards, official `deepseek-ai/DeepSeek-V4.1-Flash-1017`). If that tree is already complete, `fetch-weights.sh` does not download it again.

The image is not uploaded here. Empty machines follow [docs/empty-fleet.md](docs/empty-fleet.md): Tony at `a2664a7`, overlay1 then overlay3 then overlay4, then `./launch/build-image.sh` for overlay5. Overlay1 is not a single script. Do not build those patches on a newer vLLM tree.

```bash
export FAB_IPS="10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8"
export SSH_USER="$USER"
./launch/doctor.sh          # must print DOCTOR_OK. does not stop anything
./launch/fetch-weights.sh   # SKIP if every node already has 48 shards
./launch/build-image.sh     # SKIP if vllm-dsv41:overlay5 is already local
./launch/boot-1017-1m.sh    # stops only vllm_dsv41, then starts TP8
curl -s http://127.0.0.1:8888/v1/models
```

Measured flags in `launch/boot-1017-1m.sh`: `GMU=0.75`, `MAXLEN=1048576`, bite `MAX_BATCHED=2048`. 1024 will not start with vision on. The needle that passed used this 2048 bite.

`doctor.sh` refuses to call the boot ready unless every node has the image tag, 48 shards, Tony's checkout at `a2664a7`, and an Up RoCE device. The launcher prints the NIC it picked. Office names (`rocep1s0f0,roceP2p1s0f0` / `enp1s0f0np0`) are the fallback when those devices are Up.

Hand launch, if you are not using the boot script:

```bash
export TEXT_ONLY=0 SERVED_NAMES="deepseek-v4.1-flash-1017 deepseek-v4.1-flash" \
  MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 MAX_BATCHED=2048 EXP_NAME=boot1017-1m-bite2048 \
  PATCH_DIR=$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 \
  FAB_IPS="$FAB_IPS" NCCL_IB_ADDR_RANGE=10.99.20.0/24 \
  NCCL_EXTRA="-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False"
# workers first, ranks 7→1, then the head:  ./launch/dsv41-tp8.sh <rank>
```

## Credits

See [CREDITS.md](CREDITS.md). Order: DeepSeek → Tony → Magnus → engine.

## License

MIT for *this* repo’s notes and launch wrappers. Weights stay DeepSeek’s. Tony’s and Magnus’s code stay theirs.
