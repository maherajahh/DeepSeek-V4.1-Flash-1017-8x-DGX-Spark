# Credits

Order is load-bearing. Do not reorder in public posts.

## 1. DeepSeek

- Model: [deepseek-ai/DeepSeek-V4.1-Flash-1017](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017)

## 2. Tony / Tech2Wild (Kai)

- Recipe: [tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark](https://github.com/tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark)
- 1017 on **four** Sparks: `runs/2026-10-17-1017` (`boot1017g`)
- We are not the authors of those patches.

## 3. Magnus

- 8-rank stretch (older checkpoint): [im0xMagnus/deepseek-v4.1-flash-uncensored-8x-dgx-spark](https://github.com/im0xMagnus/deepseek-v4.1-flash-uncensored-8x-dgx-spark)
- His published weights are dealignai uncensored. **This notebook uses official 1017.**

## 4. Engine

- vLLM overlay5 (`pins.md`): `vllm-dsv41:overlay5`

## 5. This notebook

- Lab: 8× DGX Spark (GB10). Public notes: [maherajahh](https://github.com/maherajahh).

If a public sentence sounds like we invented 8-wide DeepSeek serving, it is wrong. Fix it.
