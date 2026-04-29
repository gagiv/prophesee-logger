---
stepsCompleted: [1]
inputDocuments:
  - '_bmad-output/brainstorming/brainstorming-session-2026-04-29-1201.md'
  - 'README.md'
  - 'package.json'
workflowType: 'architecture'
project_name: 'prophesee-logger'
user_name: 'Mfishman'
date: '2026-04-29'
prdGate: 'overridden'
prdGateNote: 'No PRD existed at workflow start. User chose [Override] to proceed using the brainstorming session and the architect (Winston) recommendation as proxy input context. Architectural decisions in this document should be revisited if a formal PRD is later authored and disagrees with the assumed scope.'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## PRD Gate — Overridden

**Status:** ⚠️ Proceeding without a formal PRD by user decision.

**Proxy input context** used in place of a PRD:
- **Brainstorming session** ([brainstorming-session-2026-04-29-1201.md](../brainstorming/brainstorming-session-2026-04-29-1201.md)) — captured the central design question (wrap pino directly vs. logger-agnostic abstraction layer)
- **Architect's standing recommendation** — _Winston_ (the system architect persona) recommended **owned narrow API + thin pino implementation, no adapter layer**, on the basis that:
  - Pino's strongest features (worker-thread transports, child-logger bindings, redaction, `pino-http` contract, `pino-roll` rotation) are not portable; a generic abstraction would either leak pino or ship a worse logger
  - Internal-only consumers reduce the cost of a future coordinated migration relative to abstraction tax over years
  - "API ownership ≠ abstraction layer" — re-exporting an owned `Logger` interface backed by pino preserves the swap escape hatch without paying for it daily
- **Project state at start:** Fresh scaffold (`src/index.ts` is `export {};`); pino ecosystem (`pino`, `pino-http`, `pino-pretty`, `pino-roll`) already declared as runtime deps; targets Node.js ≥20, TypeScript ≥5.4

**Caveats this gate creates:**
- Scope and consumer assumptions are inferred, not validated against a written product spec
- "Internal-only consumers" is assumed but not codified
- No prioritized non-functional requirements (perf SLOs, bundle size budgets, transport SLAs) exist yet
- If a PRD is later authored and contradicts these assumptions, the decisions in this document MUST be revisited

