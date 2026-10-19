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
| Vision | on (`TEXT_ONLY=0`). One proof: 32×32 red PNG → `Red`. See [results/vision-1017.md](results/vision-1017.md). |
| Tools | parsers on. Not a tool-call eval. |
| Context window | API reports `1048576` (`GMU=0.75`). That is the configured max, not a needle test. |
| Longest measured prompt | 93,335 tokens (cold prefill below). No 1M retrieval test in this repo. |
| API | head `:8888`, ids `deepseek-v4.1-flash-1017` and `deepseek-v4.1-flash` |

The live server batches up to 8192 tokens (`--max-num-batched-tokens 8192`). A 1M prompt at that chunk size is a memory spike this repo has not run, and will not claim.

## Measured (Tony `v41bench.py`, prompt set v1, temperature 0, thinking off)

Same harness Tony used for 1017g. Counting ceiling excluded from the 8-category mean. His column is 4 Sparks at 300K. This column is 8 Sparks with the window set to 1M. Extra boxes help. They do not double decode. This is not a TensorFold comparison. Tony’s TensorFold 4-Spark lane is still faster than this vLLM lane.

| C | this boot (8×, window 1M) | Tony 1017g (4×, 300K) |
|---|---|---|
| C1 aggregate tok/s | **57.3** | 48.5 |
| C2 | **93.1** | 76.6 |
| C3 | **120.7** | 102.6 |
| C4 | **147.4** | 123.2 |
| C5 | **166.5** | 144.6 |
| C6 | **186.4** | 165.7 |
| C1 mean TTFT (s) | **0.25** | 0.28 |
| Cold prefill ~93K | **2183 tok/s** (43s) | ~42s on his writeup |

One-user coding: **85.4 tok/s**.

Raw: [results/bench-tp8-1017-1m.md](results/bench-tp8-1017-1m.md), [results/bench-tp8-1017-1m.json](results/bench-tp8-1017-1m.json).

## What this is not

- Not Tony’s 4-box 1017 recipe
- Not Magnus’s uncensored checkpoint
- Not TensorFold / EXL3
- Not “we invented 8-wide DeepSeek”
- Not a 1M needle proof
- Not a vision benchmark (one red square)

## Clone and serve

One path. Run these on the head. They do not stop a live container.

Weights stay at `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48 shards, official `deepseek-ai/DeepSeek-V4.1-Flash-1017`). If that tree is already complete, `fetch-weights.sh` does not download it again.

The image is not uploaded here. `build-image.sh` clones [Tony's recipe](https://github.com/tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark) at `a2664a7` and runs his `build/build_overlay5.sh` only when `vllm-dsv41:overlay5` is missing. If the tag is already local, it skips. Overlay5 is his last step: overlay4 has to exist first (`Dockerfile.overlay`, `build/build_overlay3.sh`, `build/build_overlay4.sh` in that same pin). Do not build those patches on a newer vLLM tree.

```bash
export FAB_IPS="10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8"
export SSH_USER="$USER"
./launch/doctor.sh          # must print DOCTOR_OK. does not stop anything
./launch/fetch-weights.sh   # SKIP if every node already has 48 shards
./launch/build-image.sh     # SKIP if vllm-dsv41:overlay5 is already local
./launch/boot-1017-1m.sh    # stops only vllm_dsv41, then starts TP8
curl -s http://127.0.0.1:8888/v1/models
```

Measured flags, already what the boot script exports: `GMU=0.75`, `MAXLEN=1048576`, bite `--max-num-batched-tokens 8192`. The window is set to 1,048,576. A 1M prompt at that bite is not safe. Longest measured prompt is 93,335 tokens.

`doctor.sh` refuses to call the boot ready unless every node has the image tag, 48 shards, Tony's checkout at `a2664a7`, and an Up RoCE device. The launcher prints the NIC it picked. Office names (`rocep1s0f0,roceP2p1s0f0` / `enp1s0f0np0`) are the fallback when those devices are Up.

Hand launch, if you are not using the boot script:

```bash
export TEXT_ONLY=0 SERVED_NAMES="deepseek-v4.1-flash-1017 deepseek-v4.1-flash" \
  MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 EXP_NAME=boot1017-1m \
  PATCH_DIR=$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 \
  FAB_IPS="$FAB_IPS" NCCL_IB_ADDR_RANGE=10.99.20.0/24 \
  NCCL_EXTRA="-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False"
# workers first, ranks 7→1, then the head:  ./launch/dsv41-tp8.sh <rank>
```

## Credits

See [CREDITS.md](CREDITS.md). Order: DeepSeek → Tony → Magnus → engine.

## License

MIT for *this* repo’s notes and launch wrappers. Weights stay DeepSeek’s. Tony’s and Magnus’s code stay theirs.
