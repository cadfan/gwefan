---
title: "ira"
description: "iRacing companion for telemetry, race planning and session management"
summary: "iRacing companion for telemetry, race planning and session management. C11, OAuth2, iRacing API."
showReadingTime: false
---

Companion application for iRacing, written in C. Runs alongside iRacing to provide real-time telemetry, automatic application management, race filtering, and session planning tools.

**Source:** [github.com/cadfan/ira](https://github.com/cadfan/ira)

---

## Core Features

- **Real-time telemetry** — speed, RPM, gear, pedal inputs, lap times, fuel level at 60Hz via iRacing shared memory
- **Telemetry logging** — CSV recording with automatic session detection and configurable sample rate
- **Background app launcher** — manage helper applications with per-session launch triggers and conditional car/track filtering
- **Race filtering** — find races matching owned content, license range, category, setup type, and duration preferences
- **Race guide** — upcoming session schedule, registration counts, and series details from the iRacing API
- **Session registrations** — view registered sessions with start times and entry counts

---

## Technical Details

- **Language:** C11 with the Meson build system
- **Authentication:** OAuth2 (iRacing's current API standard)
- **API integration:** iRacing member info, schedule data, session registrations, owned content detection
- **Versioning:** CalVer
- **Platform:** Windows
