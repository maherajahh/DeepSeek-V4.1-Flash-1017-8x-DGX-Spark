# Same seven questions, 2026-10-19

DeepSeek's own API (`deepseek-flash`, thinking off) and this boot (`deepseek-v4.1-flash-1017` on spark1:8888, temperature 0). Not Tony's 69-question suite. Seven short questions with a known answer.

| Question | DeepSeek's API | this boot |
|---|---|---|
| 17 × 23 | 391 | 391 |
| reverse "spark" | kraps | kraps |
| JSON only | `{"ok": true}` | `{"ok": true}` |
| capital of France | Paris | Paris |
| 2 to the power of 10 | 1024 | 1024 |
| ball costs how much | 0.05 | 0.05 |
| does `bigger` return the larger number? | No. It returns `a` in both branches, so it never returns `b`. | No. It returns `a` in both branches, so it never returns `b`. |

7/7 both sides. The last answer matched word for word. This does not prove every answer will match. It is the check that the boot still talks like DeepSeek's copy of 1017.
