---
title: "casectl"
description: "Headless-first controller for the Freenove Raspberry Pi case"
summary: "Raspberry Pi case controller. CLI, web dashboard, TUI. Plugin architecture. Python + FastAPI."
showReadingTime: false
---

Headless-first multi-interface controller for the Freenove Computer Case Kit Pro (FNK0107 series) for Raspberry Pi. Manages PWM fans, WS2812 LEDs, and SSD1306 OLED display via a plugin-based daemon.

**Source:** [github.com/cadfan/casectl](https://github.com/cadfan/casectl) ·
**Docs:** [casectl.griffiths.cymru](https://casectl.griffiths.cymru/)

---

## Core Features

- **Three interfaces** — CLI, web dashboard (HTMX), and TUI (`casectl top`)
- **Plugin architecture** — every feature is a plugin (8 built-in)
- **Fan control** — temperature-based auto, RPi fan-follow, manual, custom curves, off
- **LED control** — rainbow, breathing, follow-temp, manual colour (16 named colours + hex)
- **OLED display** — 4 cycling info screens (128×64 SSD1306)
- **MQTT** — Home Assistant auto-discovery
- **Automation** — event-driven rules with conditions, actions, and priority
- **Alerting** — webhook, ntfy.sh, and SMTP
- **Monitoring** — CPU, memory, disk, temperature, fan speed, Prometheus metrics

---

## Technical Details

- **Language:** Python 3.11+
- **Daemon:** FastAPI with WebSocket and SSE
- **CLI:** Click with tab completion
- **Testing:** 313 tests, 68% coverage
- **Platform:** Raspberry Pi OS (Bookworm)
- **Status:** v0.2.0 — running as a systemd service on griffpi

---

## Blog Posts

- [Controlling the case](/blog/controlling-the-case/) — why the stock software was not enough
