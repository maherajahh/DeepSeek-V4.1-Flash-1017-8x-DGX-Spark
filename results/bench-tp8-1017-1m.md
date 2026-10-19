## tp8-1017-1m (2026-10-19T05:12:50Z)

office 8x GB10 TP8 official DeepSeek-V4.1-Flash-1017 maxlen=1048576 gmu=0.75 overlay5

Prompt set `v1` (identical across boots), temperature 0, thinking off. Tokens from the server's usage block; TTFT = first token delta.

### Throughput by concurrency (8 categories; the counting ceiling is excluded)

| C | aggregate tok/s | per-stream tok/s | mean TTFT (s) |
|---|---|---|---|
| C1 | 57.34 | 63.97 | 0.247 |
| C2 | 93.11 | 53.17 | 0.263 |
| C3 | 120.66 | 45.86 | 0.313 |
| C4 | 147.39 | 43.77 | 0.32 |
| C5 | 166.46 | 38.57 | 0.351 |
| C6 | 186.36 | 37.12 | 0.396 |

### Per-stream tok/s by category

| category | C1 | C2 | C3 | C4 | C5 | C6 |
|---|---|---|---|---|---|---|
| coding | 85.43 | 80.31 | 71.15 | 65.1 | 62.16 | 53.16 |
| json | 74.27 | 55.52 | 50.42 | 41.86 | 44.8 | 40.68 |
| narrative | 33.31 | 28.68 | 24.73 | 21.36 | 18.27 | 16.46 |
| prose | 44.03 | 31.37 | 32.32 | 28.15 | 23.51 | 22.33 |
| math | 75.11 | 69.9 | 54.08 | 53.95 | 44.64 | 46.78 |
| reasoning | 67.83 | 56.55 | 40.86 | 47.74 | 35.93 | 37.73 |
| summary | 43.61 | 33.23 | 27.51 | 28.75 | 25.35 | 21.24 |
| format | 88.2 | 69.82 | 65.77 | 63.22 | 53.87 | 58.58 |
| ceiling_count | 100.83 | 96.86 | 88.2 | 81.32 | 71.29 | 70.94 |

### Cold prefill (unique prefix)

| target | prompt tokens | TTFT (s) | prefill tok/s |
|---|---|---|---|
| 2000 | 2950 | 1.382 | 2134.0 |
| 8000 | 11592 | 5.366 | 2160.1 |
| 32000 | 46810 | 20.807 | 2249.7 |
| 64000 | 93335 | 42.748 | 2183.4 |
