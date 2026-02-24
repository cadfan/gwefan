---
title: "Warm Amber: an iOS companion for islet"
date: 2026-02-24T00:01:00+00:00
description: "Why a personal glucose platform needed a native app, and what SwiftUI, XcodeGen and a shared design language look like when you're building for one."
tags: ["islet", "ios", "design"]
---

<p class="blog-lead">For three weeks, islet has lived in a terminal. The daemon runs on a Raspberry Pi, the analytics engine crunches numbers in the background, the API accepts uploads &mdash; all invisible unless you know the right curl command. Logging a meal meant SSH and a CLI. That works at a desk. It does not work holding a fork.</p>

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions. PCU values are informational only and must not be used as dosing advice.</p>

The server already supported meal logging &mdash; a food logging API (introduced in Phase 1.5) with AI-assisted carb estimation via a configurable provider, session management, and meal lifecycle. The technical capability existed. What was missing was a way to use it without a terminal.

## Why native

A web app was the obvious choice. But meal logging has a specific interaction pattern: you're eating, you pull out your phone, you type what you're eating, you put the phone down. The whole thing needs to take less than a minute. It needs to work with one hand.

Native SwiftUI gets you the keyboard behaviour, the scroll physics, the date picker, and the system navigation for free. A web app would need to fight for all of those.

<blockquote class="blog-pullquote">The best client for a system of one is the one that gets out of the way fastest.</blockquote>

## What the app does

Four screens. No onboarding.

<div class="spec-grid spec-grid-2col">
  <div class="spec-card">
    <div class="spec-card-title">Dashboard</div>
    <div class="spec-card-desc">Current glucose reading colour-coded by range, insulin on board, carbs on board, 30-minute prediction, data freshness.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Food logger</div>
    <div class="spec-card-desc">Manual entry with macro tags (fat, protein, fibre, GI, absorption speed) &mdash; or ask the AI to estimate carbs through a multi-turn conversation.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Meal history</div>
    <div class="spec-card-desc">Recent meals with status badges. Swipe to delete unconfirmed entries.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Settings</div>
    <div class="spec-card-desc">Server URL and bearer token. Test connection button. That's it.</div>
  </div>
</div>

The AI estimation is the most interesting part. You describe what you're eating &mdash; "two slices of sourdough with butter and a fried egg" &mdash; and the model either estimates directly or asks follow-up questions. The conversation is multi-turn: it might ask about portion size or cooking method before committing to a number. When it does estimate, the form auto-fills with carbs, GI level, and absorption speed. You review, adjust if needed, and submit.

The estimation API behind this is stateless. The client sends the full conversation history on every request; the server holds no session state for the AI conversation. That means the server can restart between turns without breaking a conversation, and there's nothing to expire or clean up.

## The Warm Amber theme

The app shares its visual identity with this website.

<div class="colour-palette">
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#1d1e20"></div>
    <div class="colour-swatch-label">Background</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#2e2e33"></div>
    <div class="colour-swatch-label">Card</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#d4924b"></div>
    <div class="colour-swatch-label">Warm Amber</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#dadadb"></div>
    <div class="colour-swatch-label">Text</div>
  </div>
</div>

Dark background, warm amber accent, off-white text. The same palette as the site you're reading now. Glucose readings get their own colour logic: a cold-to-hot spectrum where low readings are indigo, in-range is green, and highs run from orange to red.

<div class="colour-palette">
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#6366f1"></div>
    <div class="colour-swatch-label">Urgent low</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#818cf8"></div>
    <div class="colour-swatch-label">Low</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#4ade80"></div>
    <div class="colour-swatch-label">In range</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#fb923c"></div>
    <div class="colour-swatch-label">High</div>
  </div>
  <div class="colour-swatch">
    <div class="colour-swatch-block" style="background:#ef4444"></div>
    <div class="colour-swatch-label">Urgent high</div>
  </div>
</div>

The temperature metaphor makes the colours intuitive without needing a legend. Cold is concerning, warm is concerning, green is where you want to be.

## Building from Windows

The development machine runs Windows. The build target is iOS. This is not a normal workflow.

XcodeGen solves the project file problem. The Xcode project is generated from a YAML file, so Swift source code can be written and committed from any platform. The actual build happens via SSH to a Mac running Xcode. Write, push, SSH, build, deploy.

SwiftUI and async/await made the client side straightforward. The API client is an actor &mdash; thread-safe by construction, no manual locking. Network calls are async functions that return Codable models. The views are declarative.

What was not straightforward: making Swift's Codable decoders match the actual API response shapes. Several rounds of "the app compiles, the JSON doesn't decode" before the models and the server agreed on field names and nesting.

<div class="blog-stat-row">
  <div class="blog-stat"><div class="blog-stat-num">4</div><div class="blog-stat-label">screens</div></div>
  <div class="blog-stat"><div class="blog-stat-num">1,608</div><div class="blog-stat-label">Swift SLOC</div></div>
  <div class="blog-stat"><div class="blog-stat-num">1</div><div class="blog-stat-label">user</div></div>
</div>

## Designing for one

islet has exactly one user. There is no onboarding flow, no account creation, no usage analytics. The server URL and token are pre-configured. The server URL points to `islet.griffiths.cymru`.

That changes every design decision. There's no need for error messages that explain the system to a stranger. No need for a forgot-password flow. No need for feature discovery. The app opens, shows the data, logs the food, and gets out of the way.

Every feature either solves a daily problem or it doesn't exist.
