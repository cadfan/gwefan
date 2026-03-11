---
title: "Spoke/Circuit Navigation Bug Report"
date: 2026-03-11
description: "Route recalculation failure and premature arrival triggers — with video evidence."
showReadingTime: false
showBreadCrumbs: false
hiddenInHomeList: true
---

<style>
/* ── Report-specific styles ── */
.report-meta {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem 1.5rem;
  padding: 1.25rem 1.5rem;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--accent) 20%, transparent);
  background: color-mix(in srgb, var(--accent) 4%, var(--entry));
  margin: 0 0 2.5rem;
  font-size: 0.88rem;
  line-height: 1.6;
}
.report-meta dt {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--accent);
  margin: 0;
}
.report-meta dd {
  margin: 0 0 0.6rem;
  color: var(--secondary);
}
@media (max-width: 500px) {
  .report-meta { grid-template-columns: 1fr; }
}

/* Bug section header */
.bug-header {
  display: flex;
  align-items: flex-start;
  gap: 0.85rem;
  margin: 3rem 0 1.2rem;
}
.bug-number {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--theme);
  background: var(--accent);
  width: 2.2rem;
  height: 2.2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  flex-shrink: 0;
  margin-top: 0.15rem;
}
.bug-title {
  font-family: 'JetBrains Mono', monospace;
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  line-height: 1.35;
  margin: 0;
}

/* Evidence pair */
.evidence {
  display: flex;
  gap: 1rem;
  margin: 1.5rem 0;
  align-items: flex-start;
}
.evidence-single {
  display: block;
  margin: 1.5rem auto;
  max-width: 320px;
}
.evidence-shot {
  flex: 1;
  min-width: 0;
}
.evidence-shot img {
  width: 100%;
  border-radius: 12px;
  border: 1px solid color-mix(in srgb, var(--accent) 15%, transparent);
}
.evidence-single img {
  width: 100%;
  border-radius: 12px;
  border: 1px solid color-mix(in srgb, var(--accent) 15%, transparent);
}
.evidence-caption {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--accent);
  margin-top: 0.5rem;
  display: block;
}
.evidence-desc {
  font-size: 0.82rem;
  color: var(--secondary);
  line-height: 1.55;
  margin-top: 0.3rem;
}
@media (max-width: 600px) {
  .evidence { flex-direction: column; }
}

/* Technical callout */
.tech-callout {
  padding: 1rem 1.25rem;
  border-left: 3px solid var(--accent);
  background: color-mix(in srgb, var(--accent) 5%, transparent);
  border-radius: 0 6px 6px 0;
  margin: 1.5rem 0;
  font-size: 0.88rem;
  line-height: 1.65;
}
.tech-callout-title {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--accent);
  margin-bottom: 0.5rem;
}

/* Stop card */
.stop-card {
  padding: 1.25rem 1.5rem;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--accent) 15%, transparent);
  background: var(--entry);
  margin: 1.5rem 0;
}
.stop-card-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 0.6rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}
.stop-name {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
  font-size: 0.92rem;
  letter-spacing: -0.01em;
}
.stop-id {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.68rem;
  color: var(--accent);
  opacity: 0.8;
}
.stop-address {
  font-size: 0.82rem;
  color: var(--secondary);
  margin-bottom: 0.5rem;
}

/* Timeline */
.timeline {
  position: relative;
  margin: 1.5rem 0;
  padding-left: 1.5rem;
}
.timeline::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(
    180deg,
    color-mix(in srgb, var(--accent) 40%, transparent),
    color-mix(in srgb, var(--accent) 15%, transparent)
  );
}
.tl-item {
  position: relative;
  padding: 0.4rem 0 0.8rem 1rem;
}
.tl-item::before {
  content: '';
  position: absolute;
  left: -1.5rem;
  top: 0.65rem;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: color-mix(in srgb, var(--accent) 40%, transparent);
  border: 2px solid var(--entry);
}
.tl-item.tl-bug::before {
  background: var(--accent);
  width: 10px;
  height: 10px;
  left: calc(-1.5rem - 1px);
}
.tl-time {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--accent);
  margin-right: 0.5rem;
}
.tl-desc {
  font-size: 0.85rem;
  color: var(--secondary);
}
.tl-bug .tl-desc {
  color: var(--primary);
  font-weight: 500;
}

/* Video section */
.video-wrap {
  margin: 1.5rem auto;
  max-width: 380px;
}
.video-wrap video {
  width: 100%;
  border-radius: 16px;
  border: 2px solid color-mix(in srgb, var(--accent) 20%, transparent);
}
.video-label {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.62rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--accent);
  text-align: center;
  display: block;
  margin-top: 0.5rem;
  opacity: 0.8;
}

/* Divider */
.report-divider {
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent,
    color-mix(in srgb, var(--accent) 25%, transparent) 20%,
    color-mix(in srgb, var(--accent) 25%, transparent) 80%,
    transparent
  );
  margin: 2.5rem 0;
}

/* Section label */
.section-label {
  font-family: 'JetBrains Mono', monospace;
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  margin-bottom: 0.75rem;
  display: block;
}

/* Context footer */
.report-context {
  border-top: 1px solid color-mix(in srgb, var(--accent) 15%, transparent);
  padding-top: 1.5rem;
  margin-top: 2.5rem;
}
.report-context p {
  font-size: 0.88rem;
  color: var(--secondary);
  line-height: 1.7;
}
</style>

<dl class="report-meta">
  <dt>Device</dt>
  <dd>iPhone 12 Pro, iOS 18</dd>
  <dt>App</dt>
  <dd>Spoke (Circuit) latest version</dd>
  <dt>Navigation</dt>
  <dd>iOS with CarPlay connected</dd>
  <dt>Route area</dt>
  <dd>Fabian Way / Morfa Road / Neath Road / Plasmarl, Swansea</dd>
  <dt>Date</dt>
  <dd>11 March 2026</dd>
  <dt>Onset</dt>
  <dd>Noticeably frequent the past day or two. Persists across app closures and relaunches.</dd>
</dl>

<!-- ════════════════════════════════ BUG 1 ════════════════════════════════ -->

<div class="bug-header">
  <span class="bug-number">1</span>
  <h2 class="bug-title" style="border:none; padding:0; margin:0;">Route does not recalculate after deviating from planned turn</h2>
</div>

When the navigation instructs a turn and I take a different road instead, the route **does not recalculate**. The navigation continues tracking progress along the original route polyline, even when I am on a completely different road.

At the end of Fabian Way (near Parc Tawe), navigation instructed me to cross Tawe Bridge and continue via Pentreguinea Road / Foxhole Road (east side of the River Tawe). I continued straight onto Morfa Road (west side) instead. The navigation did not recalculate — it continued advancing my position along the original route on the other side of the river.

<span class="section-label">Evidence</span>

<div class="evidence">
  <div class="evidence-shot">
    <img src="01-tawe-bridge-instruction.jpg" alt="Navigation instruction to cross Tawe Bridge">
    <span class="evidence-caption">01:00 — Instruction</span>
    <span class="evidence-desc">Navigation says: cross Tawe Bridge on the A483 toward Pentreguinea Rd.</span>
  </div>
  <div class="evidence-shot">
    <img src="03-polyline-snapping.jpg" alt="Driving on Morfa Rd while route line tracks along Foxhole Rd across the River Tawe">
    <span class="evidence-caption">03:32 — No recalculation</span>
    <span class="evidence-desc">Map panned to show both roads. I am driving on Morfa Rd (left, blue arrow). The blue route line runs along Foxhole Rd on the other side of the River Tawe (right). The app thinks I'm progressing along the other road.</span>
  </div>
</div>

<div class="video-wrap">
  <video controls preload="metadata">
    <source src="clip-no-recalc.mp4" type="video/mp4">
  </video>
  <span class="video-label">Clip — Route not recalculating (40s)</span>
</div>

<div class="tech-callout">
  <div class="tech-callout-title">Technical observation</div>
  GPS position updates correctly (blue arrow is in the right place on Morfa Rd). Distance and ETA update as I drive. But the route geometry and turn instructions do not change — they still reference the A4217 on the other side of the river. The system appears to be <strong>snapping my position to the original route polyline</strong> and advancing progress along it, rather than detecting the deviation and triggering a reroute.
</div>

<div class="report-divider"></div>

<!-- ════════════════════════════════ BUG 2 ════════════════════════════════ -->

<div class="bug-header">
  <span class="bug-number">2</span>
  <h2 class="bug-title" style="border:none; padding:0; margin:0;">Premature / false arrival triggers</h2>
</div>

The app triggers "You have arrived" for delivery stops when I am still approaching on the main road, not at the actual destination. This happened **repeatedly** for two consecutive stops. Each time I pressed **Restart**, the false arrival re-triggered almost immediately.

I have experienced similar behaviour in the past when using **Advanced Search** to find an address via postcode — it would often say I'd arrived a few buildings away. I accepted that as a compromise for a highly accurate pin. But when using data sourced directly from **Google Maps** (searching an address and adding it as-is, which is the default), arrival accuracy was always perfect — until now.

This problem has persisted across multiple app closures and relaunches.

<span class="section-label">Stop 1</span>

<div class="stop-card">
  <div class="stop-card-header">
    <span class="stop-name">Universal Hardware Supplies Ltd</span>
    <span class="stop-id">Stop 61/62</span>
  </div>
  <div class="stop-address">227-234 Neath Road, Plasmarl, SA1 2JG</div>
  Arrival triggered at <strong>06:22</strong> in the video while still driving north on Neath Road, <strong>0.4 miles</strong> from the destination at 38 mph. Pressed Restart multiple times — arrival kept re-triggering.
</div>

<div class="evidence">
  <div class="evidence-shot">
    <img src="04-uhs-pre-arrival.jpg" alt="Approaching UHS on Neath Road — 0.2 miles from turn">
    <span class="evidence-caption">06:20 — Approaching</span>
    <span class="evidence-desc">On Neath Road heading north past Texaco Tawe, 0.2mi from the turn. Blue arrow clearly visible on the main road at 36 mph, approaching stop 61.</span>
  </div>
  <div class="evidence-shot">
    <img src="04-uhs-false-arrival.jpg" alt="False arrival triggered for UHS while still 0.4 miles away on Neath Road">
    <span class="evidence-caption">06:22 — False arrival</span>
    <span class="evidence-desc">"Universal Hardware Supplies Ltd — 0.4 miles" appears in the arrival header. Blue arrow still on Neath Road at 38 mph — not even at the Texaco roundabout yet.</span>
  </div>
</div>

<div class="video-wrap">
  <video controls preload="metadata">
    <source src="clip-uhs-arrival.mp4" type="video/mp4">
  </video>
  <span class="video-label">Clip — UHS false arrivals (50s)</span>
</div>

<span class="section-label">Stop 2</span>

<div class="stop-card">
  <div class="stop-card-header">
    <span class="stop-name">Packaging World, Osprey Business Park</span>
    <span class="stop-id">Stop 62/62</span>
  </div>
  <div class="stop-address">Byng Street, Plasmarl, SA1 2NR</div>
  After restarting past UHS, navigation to Packaging World began (0.3 miles). The arrival triggered <strong>at least four times</strong> during approach — each time I pressed Restart, it re-triggered within seconds.
</div>

<div class="evidence">
  <div class="evidence-shot">
    <img src="05-pw-approaching.jpg" alt="Approaching Packaging World, 450ft away">
    <span class="evidence-caption">10:00 — 450 ft away</span>
    <span class="evidence-desc">After Restart. Still 450ft from the destination. About to falsely arrive again.</span>
  </div>
  <div class="evidence-shot">
    <img src="06-pw-false-arrival.jpg" alt="False arrival for Packaging World">
    <span class="evidence-caption">10:10 — False arrival</span>
    <span class="evidence-desc">Arrival screen triggered at Station Rd / Byng St area, not at the actual premises on Byng Street.</span>
  </div>
</div>

<div class="video-wrap">
  <video controls preload="metadata">
    <source src="clip-pw-arrival.mp4" type="video/mp4">
  </video>
  <span class="video-label">Clip — PW false arrivals (60s)</span>
</div>

<div class="tech-callout">
  <div class="tech-callout-title">Observations</div>
  The arrival geofence radius appears too large — both stops trigger while still on the Neath Road approach, not at the actual side-street premises. Pressing Restart does not prevent immediate re-triggering. These are real Google Maps locations (not postcode-derived via Advanced Search), so the coordinates should be accurate.
</div>

<div class="report-divider"></div>

<!-- ════════════════════════════════ VIDEO ════════════════════════════════ -->

<span class="section-label">Full screen recording</span>

Full 11-minute iOS screen recording showing both bugs end-to-end:

<div class="video-wrap">
  <video controls preload="metadata">
    <source src="screen-recording-2026-03-11.mp4" type="video/mp4">
  </video>
  <span class="video-label">Full recording (11 min)</span>
</div>

<span class="section-label">Video timeline</span>

<div class="timeline">
  <div class="tl-item">
    <span class="tl-time">00:00</span>
    <span class="tl-desc">Route begins near New Cut Rd / A483</span>
  </div>
  <div class="tl-item">
    <span class="tl-time">01:00</span>
    <span class="tl-desc">Navigation instructs: cross Tawe Bridge</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">01:30</span>
    <span class="tl-desc">I continue on Morfa Road — route does not recalculate</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">03:32</span>
    <span class="tl-desc">Map panned to show both roads — my position on Morfa Rd, route line on Foxhole Rd</span>
  </div>
  <div class="tl-item">
    <span class="tl-time">05:00</span>
    <span class="tl-desc">Route eventually recalculates on A4067 heading north</span>
  </div>
  <div class="tl-item">
    <span class="tl-time">06:15</span>
    <span class="tl-desc">Approaching Universal Hardware Supplies on Neath Road</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">06:22</span>
    <span class="tl-desc">First false arrival at UHS — still 0.4 miles away at 38 mph</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">06:30</span>
    <span class="tl-desc">Multiple Restart cycles — arrival keeps re-triggering</span>
  </div>
  <div class="tl-item">
    <span class="tl-time">09:30</span>
    <span class="tl-desc">Navigation to Packaging World begins</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">10:00</span>
    <span class="tl-desc">First false arrival at PW (~450 ft away)</span>
  </div>
  <div class="tl-item tl-bug">
    <span class="tl-time">10:10</span>
    <span class="tl-desc">Second, third, fourth false arrivals at PW in quick succession</span>
  </div>
</div>

<div class="report-divider"></div>

<!-- ════════════════════════════════ CONTEXT ════════════════════════════════ -->

<div class="report-context">
<span class="section-label">Context</span>

These two bugs may be related. The route recalculation failure (Bug 1) suggests the navigation engine is not correctly detecting when the driver has left the planned route geometry. The false arrival triggers (Bug 2) may share the same root cause — the geofence or position-matching logic is using the polyline position rather than the actual GPS position, causing it to think the driver is closer to the destination than they actually are.

CarPlay was connected and running during this test. Both bugs are present with CarPlay active.

This behaviour has been noticeably frequent over the past day or two. It was not present before that.

</div>
