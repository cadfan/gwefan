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

{{< islet-intro >}}

---

## Architecture

{{< islet-pipeline >}}

The system runs 24/7 on a Raspberry Pi 5B as a systemd service. All primary data is stored locally in SQLite under self-hosted control. Nightscout polling remains available as a fallback.

---

## Progress

The project followed a specification-first approach — every design decision was documented before implementation began.

{{< islet-timeline >}}

---

## Commit History

{{< islet-commits >}}
