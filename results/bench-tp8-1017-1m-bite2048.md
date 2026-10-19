## tp8-1017-1m-bite2048 (2026-10-19T17:27:24Z)

office 8x GB10 TP8 official DeepSeek-V4.1-Flash-1017 maxlen=1048576 gmu=0.75 bite=2048 overlay5

Prompt set `v1` (identical across boots), temperature 0, thinking off. Tokens from the server's usage block; TTFT = first token delta.

### Throughput by concurrency (8 categories; the counting ceiling is excluded)

| C | aggregate tok/s | per-stream tok/s | mean TTFT (s) |
|---|---|---|---|
| C1 | 54.78 | 61.3 | 0.255 |
| C2 | 87.29 | 50.64 | 0.291 |
| C3 | 117.86 | 45.24 | 0.316 |
| C4 | 143.76 | 42.56 | 0.344 |
| C5 | 158.8 | 37.42 | 0.353 |
| C6 | 172.99 | 33.55 | 0.427 |

### Per-stream tok/s by category

| category | C1 | C2 | C3 | C4 | C5 | C6 |
|---|---|---|---|---|---|---|
| coding | 89.12 | 72.81 | 62.46 | 67.83 | 64.9 | 49.8 |
| json | 73.77 | 58.3 | 59.32 | 44.68 | 42.8 | 37.08 |
| narrative | 32.24 | 29.5 | 24.5 | 22.85 | 16.92 | 16.01 |
| prose | 42.26 | 33.28 | 30.62 | 25.55 | 18.7 | 23.02 |
| math | 76.38 | 57.71 | 54.36 | 56.17 | 46.13 | 46.35 |
| reasoning | 52.58 | 52.58 | 43.64 | 32.05 | 37.91 | 34.52 |
| summary | 40.31 | 29.48 | 22.88 | 27.73 | 22.02 | 18.97 |
| format | 83.72 | 71.48 | 64.11 | 63.6 | 49.98 | 42.69 |
| ceiling_count | 102.29 | 96.43 | 82.96 | 82.1 | 77.37 | 73.15 |

### Cold prefill (unique prefix)

| target | prompt tokens | TTFT (s) | prefill tok/s |
|---|---|---|---|
| 2000 | 2950 | 1.82 | 1620.8 |
| 8000 | 11592 | 5.931 | 1954.3 |
| 32000 | 46810 | 41.622 | 1124.6 |
| 64000 | 93335 | 72.558 | 1286.3 |
