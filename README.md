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

## Launch

Weights: Hugging Face `deepseek-ai/DeepSeek-V4.1-Flash-1017` on every node at `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48 shards).

Clone Tony’s recipe to `~/dsv41-recipe` (patches). Image: `vllm-dsv41:overlay5` (`pins.md`). The image is not published here. You need that local build.

Workers first (ranks 7→1), head last (rank 0). Defaults in `launch/dsv41-tp8.sh` are the official 1017 ids, not an uncensored name.

```bash
export TEXT_ONLY=0 SERVED_NAMES="deepseek-v4.1-flash-1017 deepseek-v4.1-flash" \
  MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 EXP_NAME=boot1017-1m \
  PATCH_DIR=$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 \
  FAB_IPS="10.99.20.1 10.99.20.2 10.99.20.3 10.99.20.4 10.99.20.5 10.99.20.6 10.99.20.7 10.99.20.8" \
  NCCL_IB_ADDR_RANGE=10.99.20.0/24 \
  NCCL_EXTRA="-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False"
# on each worker:  ./launch/dsv41-tp8.sh <rank>
# on head:         ./launch/dsv41-tp8.sh 0
```

Or, on the head, after editing `FAB_IPS` / `SSH_USER` if needed:

```bash
./launch/boot-1017-1m.sh
```

That script copies `launch/dsv41-tp8.sh` to each node as `~/dsv41-tp8.sh` and starts it. It stops only `vllm_dsv41`.

## Credits

See [CREDITS.md](CREDITS.md). Order: DeepSeek → Tony → Magnus → engine.

## License

MIT for *this* repo’s notes and launch wrappers. Weights stay DeepSeek’s. Tony’s and Magnus’s code stay theirs.
