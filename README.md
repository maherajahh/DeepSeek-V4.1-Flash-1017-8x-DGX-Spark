# DeepSeek-V4.1-Flash-1017 on 8× DGX Spark

**Status: LIVE** (2026-10-19). Official `deepseek-ai/DeepSeek-V4.1-Flash-1017`. TP8. Context **1,048,576**.

Eight NVIDIA DGX Spark (GB10), tensor-parallel 8. This is not Tony’s 4-Spark recipe claimed as ours. It is an **8-rank** run of **official 1017** using Tony’s Spark vLLM patches and Magnus’s 8-rank launcher shape.

Tony published 1017 on **four** Sparks (`boot1017g`, 300K). Magnus published 8-wide on **different** (uncensored) weights. This notebook is official 1017 on eight.

## What this is

| | |
|---|---|
| Model | `deepseek-ai/DeepSeek-V4.1-Flash-1017` (official) |
| Hardware | 8× DGX Spark, dual fat rear links, `10.99.20.N` |
| Engine | vLLM `vllm-dsv41:overlay5`, Tony patches, TP=8 |
| Vision / tools | on (`TEXT_ONLY=0`) |
| Context | `1048576` (`GMU=0.75`) |
| API | head `:8888`, ids `deepseek-v4.1-flash-1017` and `deepseek-v4.1-flash` |

## Measured (Tony `v41bench.py`, prompt set v1, temperature 0, thinking off)

Same harness Tony used for 1017g. Counting ceiling excluded from the 8-category mean.

| C | this boot (8×, 1M) | Tony 1017g (4×, 300K) |
|---|---|---|
| C1 aggregate tok/s | **57.3** | 48.5 |
| C3 | **120.7** | 102.6 |
| C6 | **186.4** | 165.7 |
| C1 mean TTFT (s) | **0.25** | 0.28 |
| Cold prefill ~93K | **2183 tok/s** (43s) | ~42s on his writeup |

One-user coding: **85.4 tok/s**. Extra boxes help; they do not double decode vs four.

Not a TensorFold comparison. Tony’s TensorFold 4-Spark lane is still faster than this vLLM lane.

Raw: [results/bench-tp8-1017-1m.md](results/bench-tp8-1017-1m.md), [results/bench-tp8-1017-1m.json](results/bench-tp8-1017-1m.json).

## What this is not

- Not Tony’s 4-box 1017 recipe
- Not Magnus’s uncensored checkpoint
- Not TensorFold / EXL3
- Not “we invented 8-wide DeepSeek”

## Launch

Weights: Hugging Face `deepseek-ai/DeepSeek-V4.1-Flash-1017` on every node at `/var/tmp/models/DeepSeek-V4.1-Flash-1017` (48 shards).

Clone Tony’s recipe to `~/dsv41-recipe` (patches). Image: `vllm-dsv41:overlay5` (`pins.md`).

Workers first (ranks 7→1), head last (rank 0):

```bash
export TEXT_ONLY=0 SERVED_NAMES="deepseek-v4.1-flash-1017 deepseek-v4.1-flash" \
  MODEL_DIR=DeepSeek-V4.1-Flash-1017 GMU=0.75 MAXLEN=1048576 EXP_NAME=boot1017-1m \
  PATCH_DIR=$HOME/dsv41-recipe/patch IMAGE=vllm-dsv41:overlay5 ENGRAM_LOCAL=0 \
  NCCL_EXTRA="-e NCCL_MAX_NCHANNELS=8 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:False"
# on each worker:  ./launch/dsv41-tp8.sh <rank>
# on head:         ./launch/dsv41-tp8.sh 0
```

Or `./launch/boot-1017-1m.sh` after you edit fabric user/IPs.

## Credits

See [CREDITS.md](CREDITS.md). Order: DeepSeek → Tony → Magnus → engine.

## License

MIT for *this* repo’s notes and launch wrappers. Weights stay DeepSeek’s. Tony’s and Magnus’s code stay theirs.
