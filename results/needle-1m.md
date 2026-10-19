# Needle — official 1017, TP8, bite 2048

2026-10-19. Tony `bench/v41needle.py`. Temperature 0. Thinking off. Model `deepseek-v4.1-flash-1017`. Head `127.0.0.1:8888`. Cap on this boot: 1,048,576. Bite 2048.

The harness aims at the cap and leaves room for the question. None of these prompts was 1,048,576 tokens.

| Depth | Where | Prompt tokens | TTFT (s) | Prefill tok/s | Answer | Pass |
|---|---|---|---|---|---|---|
| 0.1 | near the start | 1,042,741 | 1564.6 | 666.4 | `COPPER-LANTERN-8315` | yes |
| 0.5 | middle | 1,042,513 | 1278.3 | 815.5 | `COPPER-LANTERN-8315` | yes |
| 0.9 | near the end | 1,042,394 | 1590.6 | 655.4 | `COPPER-LANTERN-8315` | yes |

1024 does not boot with vision on. The engine wants at least 1025 tokens for one image item, and chunked image input is off. 2048 is the bite that started and passed these tests.

Raw: [needle-1m-bite2048.json](needle-1m-bite2048.json), [needle-depth01.json](needle-depth01.json), [needle-depth09.json](needle-depth09.json).
