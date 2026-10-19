# Needle — official 1017, TP8, bite 2048

2026-10-19. Tony `bench/v41needle.py`. Temperature 0. Thinking off. Depth 0.5. Model `deepseek-v4.1-flash-1017`. Head `127.0.0.1:8888`.

| | |
|---|---|
| Target | 1,048,576 |
| Prompt tokens | **1,042,513** |
| Cap on this boot | 1,048,576 |
| Bite | `--max-num-batched-tokens 2048` |
| TTFT | 1278.3 s |
| Prefill | 815.5 tok/s |
| Answer | `COPPER-LANTERN-8315` |
| Pass | yes |

The harness aims at the cap and leaves room for the question. The prompt was not 1,048,576 tokens. It was 1,042,513, and the passphrase came back.

1024 does not boot with vision on. The engine wants at least 1025 tokens for one image item, and chunked image input is off. 2048 is the bite that started and passed this test.

Raw: [needle-1m-bite2048.json](needle-1m-bite2048.json).
