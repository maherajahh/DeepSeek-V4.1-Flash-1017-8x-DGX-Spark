# Vision and tools — this boot, bite 2048

2026-10-19T17:49:05Z. Tony `tools/vision_tools_demo.py` against `http://127.0.0.1:8888/v1`. Model id the script sends is `deepseek-v4.1-flash`, which this boot also serves. Temperature 0.

| Check | Result | Answer |
|---|---|---|
| V1 three stripes, left to right | PASS | `red, green, blue` |
| V2 two images, first then second | PASS | `first=red, second=blue` |
| V3 2×2 grid, top-right | PASS | `Green` |
| T1 weather tool call | PASS | `get_weather` Paris, c |
| T2 tool result round trip | PASS | 18 °C, light rain |
| T3 two cities | PASS | Tokyo and Berlin, both celsius |
| T4 forced `get_time` | PASS | `get_time` Sydney |

7/7 PASS. This is his short demo, not a vision benchmark and not a tool-call benchmark.
