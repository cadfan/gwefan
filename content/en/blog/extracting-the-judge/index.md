---
title: "Extracting the judge"
date: 2026-04-04T00:02:00+00:00
description: "Testing a GBA emulator is its own engineering problem. So I extracted the test harness into a standalone project that any emulator can use."
tags: ["cable-club", "gba-accuracy-tests", "testing", "development"]
---

<p class="blog-lead">When I <a href="/blog/threw-away-emulator/">rewrote cable-club</a>, the first thing I built was not the CPU or the renderer. It was the test harness. An emulator without accuracy tests is a program that produces plausible-looking output with no way to know if it is correct. I had already learned that lesson once.</p>

## What accuracy testing means

A GBA emulator can pass every standard CPU test suite &mdash; every ARM instruction, every Thumb instruction, every edge case in isolation &mdash; and still produce the wrong output when running a real game. The test suites verify that individual instructions behave correctly. They do not verify that the CPU, memory bus, DMA controller, interrupt system, and PPU all interact correctly over thousands of frames.

Accuracy testing means running a test ROM for a fixed number of frames, capturing the final framebuffer, and comparing it against a reference produced by a known-correct emulator. If the pixels match, the entire system &mdash; not just the CPU &mdash; produced the right result.

The reference emulator is NanoBoyAdvance, a cycle-accurate GBA emulator that passes 100% of the standard test suites. If NanoBoyAdvance and cable-club produce the same frame after the same number of cycles, cable-club is correct. If they differ, something is wrong, and the diff image shows exactly which pixels are off.

<blockquote class="blog-pullquote">An emulator without accuracy tests is a program that produces plausible-looking output with no way to know if it is correct.</blockquote>

## The format

Each test is defined in a TOML manifest:

```toml
[test]
name = "arm"
rom_url = "https://github.com/jsmolka/gba-tests/releases/..."
rom_sha256 = "abc123..."
frames = 120

[[references]]
emulator = "NanoBoyAdvance"
version = "1.8.2"
bios = "real"
hash = "def456..."
```

The reference hash is a SHA256 of the raw framebuffer bytes &mdash; 240&times;160 pixels in BGR555 format, 76,800 bytes. Not a PNG hash, because PNG encoding varies between libraries and platforms. Raw framebuffer bytes are deterministic.

The ROM is not stored in the repository. A download script fetches test ROMs from their original sources. The repository contains only manifests, reference hashes, and tooling.

## Why it became a separate project

The test harness started as a crate inside cable-club. It worked for cable-club, but the format &mdash; TOML manifests, reference hashes, a comparison tool &mdash; is not Rust-specific. Any GBA emulator in any language can run a ROM headlessly, capture a screenshot, and compare a hash.

The GBA emulation community does not have a shared accuracy benchmark. The closest precedent is c-sp/game-boy-test-roms for the Game Boy, which curates test ROMs into versioned releases. But it stops at ROM distribution. Nobody built the automated comparison layer &mdash; the part that tells you whether your emulator's output actually matches reality.

So I extracted the test data, manifests, comparison tool, and runner framework into [gba-accuracy-tests](https://github.com/cadfan/gba-accuracy-tests) &mdash; a standalone Python project that any emulator can plug into.

## How other emulators use it

A runner is a small adapter that knows how to invoke an emulator headlessly. The repository ships with runners for mGBA (via Lua scripting) and cable-club (via its accuracy-sweep binary). Adding a new emulator means writing a Python file with two functions: `is_available()` and `run_test()`.

```bash
python compare.py run --runner mgba --suite jsmolka
```

The output is pass/fail per test, with diff images for failures showing exactly which pixels differ from the reference. CI-friendly. Language-agnostic.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">19</div>
    <div class="blog-stat-label">Test ROMs</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">2</div>
    <div class="blog-stat-label">Runners</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">19/19</div>
    <div class="blog-stat-label">Cable-club passing</div>
  </div>
</div>

## What the tests caught

The [Frame 476 bug](/blog/frame-476/) was found because the accuracy harness ran FireRed long enough for the prefetch pipeline issue to surface. Standard CPU tests would not have caught it.

But the harness caught subtler things too. An LZ77 VRAM decompression routine that wrote bytes instead of halfwords &mdash; producing a corrupted Oak portrait that looked almost right but had shifted pixel columns. A VBlank flag that was not being cleared when the scanline counter wrapped to zero, causing the PPU to skip frames. ARM LDM/STM instructions that used the wrong register bank when the S-bit was set, breaking user-mode access from privileged code.

Each of these bugs passed the standard test suites. Each produced wrong output that the accuracy harness detected as a hash mismatch. Each came with a diff image pointing to the exact pixels that were wrong.

<blockquote class="blog-pullquote">Each bug passed the standard test suites. Each was caught by frame-level comparison against a known-correct reference.</blockquote>

## The gap in the ecosystem

The GBA emulation ecosystem has excellent test ROMs (jsmolka, ARMWrestler, mgba-suite) and excellent reference emulators (NanoBoyAdvance, mGBA). What it lacks is the glue &mdash; the automated pipeline that connects test ROMs to reference hashes to pass/fail results. Every emulator author builds their own ad-hoc testing workflow.

gba-accuracy-tests is an attempt to fill that gap. It is early &mdash; two runners, nineteen tests, references from a single gold-standard emulator. But the format is extensible, the tooling is language-agnostic, and the [repository is public](https://github.com/cadfan/gba-accuracy-tests) for anyone building a GBA emulator who wants to know if their output is correct.
