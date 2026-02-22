---
title: "islet"
description: "A local-first glucose intelligence platform for Type 1 diabetes"
summary: "Local-first glucose intelligence platform for Type 1 diabetes. Self-hosted on Raspberry Pi."
showReadingTime: false
cover:
  image: "icon.png"
  alt: "islet icon"
  relative: true
  hiddenInSingle: true
---

<img src="icon.png" alt="islet icon" width="128">

A local-first glucose intelligence platform for Type 1 diabetes. Designed around reliability, auditability and self-hosted control rather than dependence on commercial cloud services.

The long-term aim is personalised modelling: learning behavioural and physiological patterns over time and using that knowledge to improve prediction and provide carefully constrained decision support around meals and insulin, with strong safety controls and transparent operation.

Currently in active private development and planned for public release once stable.

---

## At a Glance

| | |
|---|---|
| **Language** | Python 3.13.5 |
| **Implementation** | ~5,860 SLOC (source lines of code) |
| **Tests** | 581 passing (~6,316 SLOC) |
| **Documentation** | ~650 SLOC |
| **Runtime** | Raspberry Pi 5B, systemd, SQLite |
| **Status** | Phase 3.3 — API-only soak in progress |

---

## Architecture

**Pipeline:** Libre 3 EU sensor &rarr; Shuggah &rarr; islet ingest API &rarr; SQLite &rarr; glucore engine &rarr; CLI / API

The system runs 24/7 on a Raspberry Pi 5B as a systemd service. All primary data is stored locally in SQLite under self-hosted control. Nightscout polling remains available as a fallback.

---

## Progress

The project followed a specification-first approach — every design decision was documented before implementation began.

**Phase 1 — Core Pipeline**
Nightscout polling, SQLite storage, daemon with backfill, CLI with 5 commands. 23 files, 1,070 lines in the first implementation session.

**Phase 1.5 — Meal Logging**
AI-assisted carb estimation for meals using multiple providers (Gemini, Claude, GPT). Photo and text input, confirmation workflow, treatment storage.

**Phase 2.0 — glucore Engine**
Glucose analytics: IOB decay curves from treatment history, trend analysis via linear regression, configurable prediction windows with safety contract enforcement on all outputs.

**Phase 2.1 — glucore Enhancements**
COB modelling with exponential carb absorption, autosens (sensitivity ratio from 24h deviation history), enhanced predictions combining IOB + COB + momentum, retrospective validation framework.

**Phase 3.1 — Ingest Endpoints**
Direct POST endpoints replacing Nightscout dependency. Nightscout-compatible format accepted from Shuggah. Deterministic UUID generation for deduplication.

**Phase 3.2 — Nightscout Relay**
Fire-and-forget relay to upstream Nightscout for redundancy. Circuit breaker (opens after 5 failures, probes after 60s). Self-relay guard prevents infinite loops.

**Phase 3.3 — API-Only Soak** *(current)*
Shuggah on iPhone 12 Pro configured to POST directly to islet. Soak test in progress to verify stability before full cutover.

---

## Roadmap

| Phase | Scope | Status |
|-------|-------|--------|
| 3.3 cutover | Switch to API-only ingest, retire Nightscout polling | Pending soak completion |
| 4 | Direct Libre 3 BLE ingestion, replacing Shuggah | Spec outline only |

Phase 4 (direct BLE sensor communication) is expected to be the highest technical risk stage.

---

## Commit History

| Date | Description |
|------|-------------|
| 2026-02-21 | Return records with _id in POST response (Nightscout compat) |
| 2026-02-21 | Shuggah/xDrip4iOS compatibility: status, treatments GET/DELETE, dedup |
| 2026-02-21 | Phase 3.3 prep: extract backoff helper, harden daemon, add 29 tests |
| 2026-02-21 | Add relay timeout and mixed-batch test scenarios |
| 2026-02-21 | Add received count to ingest API responses for duplicate detection |
| 2026-02-21 | Cache SHA-1 api-secret hash at init instead of recomputing per request |
| 2026-02-21 | Standardize API error format, consolidate relay config, shared test fixture |
| 2026-02-20 | Replace string-matching with typed CircuitBreakerOpenError exception |
| 2026-02-20 | Add relay circuit breaker: open after 5 failures, probe after 60s |
| 2026-02-20 | Add Nightscout relay with self-relay guard and 5s timeout |
| 2026-02-20 | Fix treatment validation gap, add conftest.py, centralize constants |
| 2026-02-20 | Schema v6 quality flags, enhanced ingest validation, cross-platform test runners |
| 2026-02-20 | Harden Phase 3.1 ingest: size limits, validation, CORS, error handling |
| 2026-02-20 | Add Phase 3.1: Nightscout-compatible ingest endpoints |
| 2026-02-20 | Add glucore Phase 2.1: COB, autosens, validation, API endpoints |
| 2026-02-19 | Add glucore Phase 2 engine, update project docs |
| 2026-02-19 | Add project icon and first food template |
| 2026-02-18 | Add temporary web UI for food entry |
| 2026-02-18 | Refactor daemon, API, and config to reduce duplication |
| 2026-02-18 | Add ChatGPT App meal intake API (Flask, v5 schema, 56 tests) |
| 2026-02-17 | Add meal CLI commands with v4 schema migration |
| 2026-02-17 | Migrate google-generativeai to google-genai and pin all dependencies |
| 2026-02-17 | Harden Phase 1.5 meal logging from multi-agent review |
| 2026-02-16 | Add meal estimation providers, shared parsing, and sync all docs |
| 2026-02-15 | Add meals table, schema migration runner, and meal CRUD with validation |
| 2026-02-15 | Harden pagination cursor, fix threshold docs, add soak test results |
| 2026-02-15 | Fix pagination gap, health check cold-start, treatments display; add tests |
| 2026-02-15 | Add Phase 1 hardening: staleness detection and health timer |
| 2026-02-15 | Implement Phase 1: Nightscout → SQLite mirror |
| 2026-02-15 | Initial commit: project docs and .gitignore |
