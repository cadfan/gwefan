---
title: "pwyslais"
description: "AI-powered personal journal and external memory system"
summary: "External memory system with AI-powered entity extraction, pattern detection and contextual nudges. Self-hosted on Raspberry Pi."
showReadingTime: false
---

An AI-powered external memory system designed around a specific problem: a brain that drops context. The system asks you questions, extracts knowledge from your answers, learns from your other projects in the background, and emphasises the things you would otherwise forget.

The Welsh word *pwyslais* means emphasis &mdash; from *pwys* (weight) and *llais* (voice). The system puts weight on what matters and gives it a voice.

---

## Overview

- **Platform:** iOS (SwiftUI), Web, CLI
- **Backend:** Flask + SQLite on Raspberry Pi 5B
- **Intelligence:** Claude API for entity extraction, pattern detection, contextual nudges
- **Database:** SQLite with WAL mode, FTS5 full-text search, 12 intelligence tables
- **Status:** Private, active development

---

## Architecture

The core loop: nudge &rarr; entry &rarr; extraction &rarr; follow-up &rarr; entry.

When you open the app, the system assembles context from your recent entries, open threads, detected patterns, and time of day, then generates a live contextual question. You answer. The system extracts entities, mood, and themes in the background. Sometimes it follows up. Each turn teaches the system more, making the next nudge more relevant.

All AI calls happen server-side. The long-term goal is ambient data retrieval from islet, llywio, and other systems &mdash; so the journal fills itself before you open it.

---

## Clients

**iOS** &mdash; SwiftUI with offline queue. Three tabs: Heddiw (Today), Hanes (History), Gosodiadau (Settings). Entries sync when connection returns.

**Web** &mdash; Vanilla HTML/JS/CSS. Search, dark/light/sepia modes, desktop and mobile.

**CLI** &mdash; Python thin client for terminal journaling.

---

## Intelligence layer

- **Contextual nudges** &mdash; live, bilingual prompts assembled from the knowledge graph
- **Entity extraction** &mdash; people, places, projects, activities, emotions, health markers
- **Pattern detection** &mdash; recurring themes and mood trends across 30-day windows
- **Thread tracking** &mdash; open items that resolve only on explicit confirmation
- **Weekly reports** &mdash; Claude Opus retrospective emailed every Sunday
- **Instant feedback** &mdash; on-demand mood assessment of individual entries
