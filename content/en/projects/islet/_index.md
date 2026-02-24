---
title: "islet"
description: "A local-first glucose intelligence platform for Type 1 diabetes"
summary: "Local-first glucose intelligence platform for Type 1 diabetes. Self-hosted on Raspberry Pi."
showReadingTime: false
layout: single
cover:
  image: "icon.png"
  alt: "islet icon"
  relative: true
  hiddenInSingle: true
---

{{< islet-intro >}}

<a href="/projects/islet/direction/" class="direction-link">
  <div class="direction-link-title">Direction</div>
  <div class="direction-link-desc">Where islet and glucore are going: from recording to understanding</div>
</a>

---

## Architecture

{{< islet-pipeline >}}

The system runs 24/7 on a Raspberry Pi 5B as a systemd service. All primary data is stored locally in SQLite under self-hosted control. Nightscout polling remains available as a fallback.

---

## Progress

The project followed a specification-first approach — every design decision was documented before implementation began.

{{< islet-timeline >}}

---

<article class="post-entry">
  <header class="entry-header">
    <h2 class="entry-hint-parent">Direction</h2>
  </header>
  <div class="entry-content">
    <p>From glucose recording to metabolic understanding — where islet and glucore are going.</p>
  </div>
  <footer class="entry-footer">
    <span title="2026-02-22">February 22, 2026</span>&nbsp;·&nbsp;<span>5 min</span>&nbsp;·&nbsp;<span>Christopher Griffiths</span>
  </footer>
  <a class="entry-link" aria-label="post link to Direction" href="/projects/islet/direction/"></a>
</article>

---

## Commit History

{{< islet-commits >}}
