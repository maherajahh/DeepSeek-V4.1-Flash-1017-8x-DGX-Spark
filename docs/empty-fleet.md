# Empty fleet

This repo does not contain the engine image. A machine with no `vllm-dsv41:overlay5` has to build Tony's earlier coats first, at one pin. Do not use a newer vLLM tree. His patches target that tree. A newer tree can boot and then emit garbage.

Pin: [tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark](https://github.com/tonyd2wild/DeepSeek-V4.1-Flash-vLLM-DGX-Spark) at `a2664a7e4ac7bc823ef29c8d7725abfe4d286f8a`.

vLLM tree under those patches: `e47aa780bccf59f59dfa2cbb18e17a10b4fe69ba`. His `build/fetch_vllm_branch.sh` checks that commit out. The branch name `dsv41-feat` is gone.

## Coats, in order

Do this on every node. The image is node-local. We do not publish the 23 GB image.

1. **overlay1.** Not one script. Two pieces, both in his repo:
   - `build/Dockerfile.overlay` starts from `vllm/vllm-openai:nightly-8a728663c1c3eeace834a95f5654fa653cc1998c` and copies a `vllm/` tree into site-packages. That tree must be the commit above, from `build/fetch_vllm_branch.sh`.
   - `build/build_stable_ext.sh` rebuilds `_C_stable_libtorch` for SM 12.1. It is a lab script. It expects a container named `v41build`. It is not a `docker build` you can paste blind.
   His write-up of this coat is `docs/RECIPE.md` section 3. If that section and these two files disagree, the files win, and do not invent a third command.

2. **overlay3.** `bash build/build_overlay3.sh`. Requires overlay1. FlashInfer v0.7.0rc1.

3. **overlay4.** `bash build/build_overlay4.sh`. Requires overlay3. This prebuild exists because a runtime compile of `mxfp8_gemm_cutlass_sm120` exhausted host memory when several nodes compiled at once. Build one node at a time if memory gets tight.

4. **overlay5.** From this repo, on the head: `./launch/build-image.sh`. If `vllm-dsv41:overlay5` is already local, it skips. If overlay4 is missing, it stops and names that step. It will not compile next to a running `vllm_dsv41`.

## After the image exists

Weights are separate. `./launch/fetch-weights.sh` downloads official `deepseek-ai/DeepSeek-V4.1-Flash-1017` only when the head has fewer than 48 shards. It does not re-download a complete tree.

`./launch/doctor.sh` then `./launch/boot-1017-1m.sh`. The boot stops only `vllm_dsv41`.
