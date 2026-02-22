---
title: "Specification-first: how islet went from zero to a working system in one session"
date: 2026-02-22
description: "Why I wrote seven documents before a single line of code, and how that made Phase 1 of islet a one-session build."
tags: ["islet", "design", "process"]
---

<p class="blog-lead">There's a strong temptation, when you know what you want to build, to just start building it. Open an editor, create a file, write the first function. You'll figure out the rest as you go.</p>

I've done that plenty of times. It works — until it doesn't. The problems tend to arrive around the third or fourth decision that depends on an earlier one you didn't think through. By then you're committed, and the cost of changing direction is no longer zero.

With islet, I decided to try something different.

## The problem

islet is a glucose intelligence platform for Type 1 diabetes. The core job is straightforward: take continuous glucose monitor (CGM) readings from a sensor, store them locally, and build analytics on top. No cloud services, no third-party dependencies for the critical path. Everything runs on a Raspberry Pi under my own control.

But "straightforward" hides a lot of decisions. How should the data be stored? What deduplication strategy handles re-ingested records? How does authentication work against the upstream API? What happens when the network drops at 3am? What does the schema look like, and what happens when it needs to change?

Each of these questions has multiple reasonable answers, and the wrong combination creates problems that only surface later.

## Seven documents before one line of code

Before writing any implementation code, I wrote seven specification documents:

<div class="spec-grid">
  <div class="spec-card">
    <div class="spec-card-title">Project context</div>
    <div class="spec-card-desc">Naming contract, pipeline architecture, hard constraints. What islet is and isn't.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Phase 1 task spec</div>
    <div class="spec-card-desc">Twelve sections, 370 lines. Every module, function signature, and error path.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Data schema</div>
    <div class="spec-card-desc">Canonical SQLite schema. Three tables, indexes, ingest rules. Every column justified.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Environment spec</div>
    <div class="spec-card-desc">Runtime configuration, .env security model, token safety rules.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Delivery checklist</div>
    <div class="spec-card-desc">13 deliverables with 6 concrete acceptance tests.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Meal logging spec</div>
    <div class="spec-card-desc">Phase 1.5 AI-assisted carb estimation. 246 lines.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Roadmap</div>
    <div class="spec-card-desc">Phases through Phase 4, so early decisions wouldn't close off future work.</div>
  </div>
</div>

This took real effort. Writing a spec is not the fun part. But something useful happened during the process: decisions that would have been made under time pressure during implementation were instead made calmly, with full context, before any code existed to defend.

For example, the deduplication strategy. Nightscout assigns each record an `_id`. Using `INSERT OR IGNORE` on that field means re-ingesting the same data is a no-op. Simple — but only if you decide it during schema design. If you discover you need it after you've already built an insert pipeline that assumes every record is new, the fix is much more invasive.

## One session

<div class="blog-stat-row">
  <div class="blog-stat"><div class="blog-stat-num">23</div><div class="blog-stat-label">files</div></div>
  <div class="blog-stat"><div class="blog-stat-num">1,070</div><div class="blog-stat-label">lines of code</div></div>
  <div class="blog-stat"><div class="blog-stat-num">3,808</div><div class="blog-stat-label">records backfilled</div></div>
</div>

With the spec complete, Phase 1 implementation was a single session. A Nightscout client, SQLite storage layer, daemon with backfill, CLI with five commands, systemd service, install scripts.

There were no design decisions to make during implementation. Every module had a defined interface. Every error path had a specified behaviour. The only surprises were small environmental ones — the default database path didn't work on Windows, bearer auth wasn't accepted by my Nightscout instance — and both were resolved in minutes because the architecture didn't need to change.

The deployment went the same way. Clone, install, start. The daemon backfilled 3,808 historical records on first run. Within minutes it was polling live data, and it hasn't stopped since.

## What the spec-first approach actually gives you

It's not about having perfect documentation. Several of those documents have been updated since. The schema is now on version 6. The pipeline has changed significantly.

<blockquote class="blog-pullquote">What it gives you is decisions made in the right order.</blockquote>

When you're writing a spec, you can hold the whole system in your head because nothing exists yet. You can change your mind about the schema without rewriting code. You can spot that your dedup strategy conflicts with your auth model before either one is built.

Once implementation starts, your degrees of freedom shrink with every file you create. The spec-first approach means you've already used that freedom well.

## The pattern since

Every subsequent phase of islet has followed the same approach. Phase 2 (the glucore analytics engine) was specced, reviewed, then implemented in waves. Phase 3 (replacing the Nightscout dependency) was planned against the existing spec, not retrofitted.

The project is now at around 5,900 lines of implementation code with 588 tests. It runs 24/7 on a Raspberry Pi, handling live CGM data. Every design decision traces back to a document that was written before the code it describes.

I'm not claiming this approach works for everything. For exploratory work, for prototypes, for things where you don't know what you're building yet — start coding. But when you do know what you want and the system needs to be reliable, writing the spec first is the highest-leverage work you can do.

It's not the fun part. But it's the part that makes everything after it go smoothly.
