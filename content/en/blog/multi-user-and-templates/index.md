---
title: "Per-user databases and instant food templates"
date: 2026-03-01T00:01:00+00:00
description: "islet moves from single-user to multi-user data isolation with per-user SQLite databases, and food logging gets faster with local templates alongside AI estimation."
tags: ["islet", "architecture", "ios"]
---

<p class="blog-lead">Two changes that have nothing in common except timing. On Friday, islet gained per-user SQLite databases for multi-user data isolation. On Saturday, the iOS food logger gained local food templates for instant meal estimation without an API call. One is about infrastructure. The other is about speed. Both matter more than they look.</p>

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>

## The single-user assumption

Until Friday, islet had one SQLite database. One file. One user. Every glucose reading, every meal, every treatment went into the same tables. That was fine when the only user was the person who built it.

The problem is forward-looking. If someone else ever runs islet &mdash; or if the same instance serves a household &mdash; the data cannot be mixed. Glucose data is personal medical information. There is no acceptable level of cross-contamination.

## Per-user SQLite databases

The solution is one database per user. Not tables partitioned by user ID. Not row-level access control. Separate files.

Each authenticated user gets their own SQLite database, created on first access. The API routes requests based on the authenticated token, which maps to a user identity, which maps to a database path. A request from user A never touches user B's file. There is no query that could accidentally cross the boundary because the boundary is the filesystem.

This is deliberately simple. SQLite's strength is that each database is a single file with no server process. Per-user isolation extends that strength rather than fighting it. No connection pooling complexity. No shared-state concurrency bugs. Each user's data is independently backed up, independently migrated, independently deleted.

<blockquote class="blog-pullquote">The best isolation boundary is one you cannot accidentally cross.</blockquote>

## Food templates

Meanwhile, on the iOS side, a different problem. The food logger has AI-powered meal estimation: describe what you ate, and the system estimates nutritional content. It works well. It is also slow. Every estimate requires an API call to an LLM, which means network latency, token processing time, and occasional provider hiccups.

For the meals you eat repeatedly &mdash; the weekday breakfast, the post-run snack, the Tunnock's Caramel Wafer &mdash; waiting for AI estimation every time is wasteful. The system already has the answer. It just forgets between sessions.

Food templates are a local data source of pre-built meal definitions. When you type a meal description, the system checks templates first. If there is a match, the nutritional estimate appears instantly. No network call. No waiting. The meal is ready to log before you finish the thought.

If there is no template match, the flow falls through to AI estimation as before. The template layer is additive &mdash; it makes the common case fast without changing the uncommon case.

## Surfacing the source

One subtle detail: the iOS chat now tells you where the estimate came from. A template match says so. An AI estimate says so. The distinction matters because template estimates are deterministic and fast while AI estimates are probabilistic and variable. When you see the same meal estimated differently on two occasions, the source label tells you why.

This is the kind of transparency that matters in health tooling. Not because the difference is dangerous &mdash; these are informational estimates, not dosing decisions &mdash; but because trust requires knowing what the system did and why.

## What connects them

Both changes are about the same instinct: data should be where it belongs, accessed in the simplest way possible.

Per-user databases put medical data behind the strongest boundary available: the filesystem. Food templates put common knowledge in the fastest location available: local memory. Neither is architecturally complex. Both are the kind of decision that feels obvious in retrospect and prevents real problems that would otherwise compound.

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>
