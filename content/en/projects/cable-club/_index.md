---
title: "cable-club"
description: "GBA emulator with internet link cable for Pokemon trading"
summary: "GBA emulator in Rust with internet link cable for Pokemon trading. 19/19 accuracy tests. Full audio."
showReadingTime: false
---

A Game Boy Advance emulator built from scratch in Rust, designed around internet link cable support for Pokemon trading and battling. Named after the room in the original Pokemon games where you go to trade.

**Source:** [github.com/cadfan/cable-club](https://github.com/cadfan/cable-club)

---

## Core Features

- **ARM7TDMI CPU** — full ARM and Thumb instruction sets with prefetch pipeline
- **PPU rendering** — all background modes (0-4), OBJ sprites with 4bpp/8bpp, affine transformations, alpha blending
- **APU audio** — PSG channels 1-4 (square, wave, noise) with envelopes and sweep, FIFO A/B with DMA-driven PCM, SDL2 output
- **Real BIOS boot** — loads GBA BIOS ROM with skip-boot fallback
- **Save persistence** — SRAM auto-detection and save files
- **DMA** — all 4 channels with mid-transfer timer ticks
- **Accuracy testing** — 19/19 tests passing against NanoBoyAdvance reference hashes
- **TCP relay** — frame-synchronised link cable over the network (in progress)

---

## Technical Details

- **Language:** Rust
- **Display:** SDL2 with integer scaling
- **Input:** Xbox controller (primary) and keyboard
- **Testing:** [gba-accuracy-tests](https://github.com/cadfan/gba-accuracy-tests) — standalone harness with TOML manifests and reference hashes
- **Platform:** Windows (primary), cross-platform via SDL2
- **Status:** v0.3.0 — FireRed boots with sound. Link cable networking next.

---

## Blog Posts

- [I threw away a working emulator](/blog/threw-away-emulator/) — why the first attempt was scrapped
- [Frame 476](/blog/frame-476/) — debugging a prefetch pipeline crash
- [Extracting the judge](/blog/extracting-the-judge/) — building the accuracy test harness
- [Sound](/blog/sound/) — APU synthesis and FIFO audio
