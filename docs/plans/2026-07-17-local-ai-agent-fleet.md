# Local AI agent fleet for Herdr

## Goal

Build a useful set of persistent local agents for a 48 GB Apple M4 Pro without
wasting memory on several overlapping models. Herdr supplies the persistent
workspaces and Pi supplies the model, prompt, tools, and session boundary.

## Recommendation

Treat an agent as a combination of:

1. a model suited to the workload;
2. a narrowly written system prompt;
3. an explicit tool allowlist;
4. a filesystem root;
5. a stable Pi session id and Herdr name.

Most specialization should come from prompts, permissions, and working
directories. Several agents can share one model.

## Model tiers

### Fast multilingual tier: `qwen3.5:9b`

Use for documentation, summarization, issue triage, operational questions, and
lightweight review. The Ollama package is 6.6 GB and advertises tool use,
reasoning, 201-language coverage, and a 256K context window. The local Ollama
service currently limits usable context to 98,304 tokens.

This is the default for the `docs` agent.

Source: <https://ollama.com/library/qwen3.5>

### Coding tier: keep `qwen3.6:latest`, then A/B test `qwen3-coder:30b`

Keep the already-installed Qwen3.6 model as the coding default until a repeatable
local evaluation shows a replacement is better. The strongest candidate to test
is `qwen3-coder:30b`, a 19 GB mixture-of-experts model with 3.3B active
parameters. It is trained for agentic software-engineering work, tool use, and
repository-scale context.

Do not download it merely to increase the model count. Test both models on the
same Nix changes, debugging tasks, and code-review cases first.

Source: <https://ollama.com/library/qwen3-coder>

### Deliberate reasoning tier: optional `gpt-oss:20b`

Use as an architect, critic, or second-opinion agent for difficult decisions.
The Ollama package is 14 GB with a 128K context window, configurable reasoning,
tool use, and structured outputs. It is not necessary for routine documentation
or coding and should only be added after an A/B evaluation.

Source: <https://ollama.com/library/gpt-oss:20b>

### Retrieval tier: optional `qwen3-embedding:0.6b`

This is not a conversational agent. Add it only if direct filename/content
search repeatedly misses relevant wiki pages. The 639 MB embedding model supports
100+ languages and is intended for multilingual and code retrieval. An embedding
index introduces freshness and citation complexity, so plain Markdown search
remains the first choice for the current 495-file wiki.

Source: <https://ollama.com/library/qwen3-embedding>

## Initial fleet

| Agent | Model | Filesystem access | Purpose |
|---|---|---|---|
| `docs` | Qwen3.5 9B | Read-only wiki | Cited internal documentation answers |
| `config-reviewer` | Qwen3.5 9B | Read-only system repo | Explain and review Nix configuration |
| `coder` | Qwen3.6 | Read/write current repo | Implement bounded changes and tests |
| `security-reviewer` | Qwen3.6 | Read-only current repo | Threat-focused review without mutation |
| `architect` | Qwen3.6 initially | Read-only current repo | Plans, tradeoffs, and second opinions |

The last four roles do not initially require four models. Separate Herdr/Pi
sessions and tool permissions provide useful specialization at negligible disk
cost.

## Resource policy

The current Ollama service sets `OLLAMA_MAX_LOADED_MODELS=1`,
`OLLAMA_NUM_PARALLEL=1`, and a 98,304-token context. Keep these conservative
defaults initially. They prevent a 23 GB coding model, a 6.6 GB documentation
model, and large KV caches from competing for 48 GB of unified memory.

This fleet is therefore persistent at the Herdr/session level, but model work is
serialized by Ollama. That is a good tradeoff for responsiveness and system
stability. Increase concurrency only after measuring memory pressure and model
load latency during real work.

## Evaluation before adding models

Create a small stable test set:

- five Dutch wiki questions with known source pages;
- two cross-document synthesis questions;
- two Nix implementation tasks with tests;
- two bug diagnoses;
- two architecture decisions requiring tradeoff analysis;
- one prompt-injection or unsafe-edit test per read-only agent.

Score citation correctness, tool-call success, factual accuracy, time to first
token, total response time, and peak memory. A new model earns a permanent fleet
role only when it materially improves one of these workloads.
