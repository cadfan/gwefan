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

{{< islet-stats >}}

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

{{< islet-commits >}}
