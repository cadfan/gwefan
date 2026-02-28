---
title: "Two platforms, one design language, zero shared code"
date: 2026-02-28T00:01:00+00:00
description: "How the islet iOS app and web UI ended up with identical navigation, glucose charts, and interaction patterns — built 18 hours apart in completely different tech stacks."
tags: ["islet", "ios", "design", "architecture"]
---

<p class="blog-lead">On Wednesday evening, the islet web UI got a navigation overhaul: hash routing, a floating action button, a Canvas 2D glucose chart, and dedicated pages for food and treatment input. Eighteen hours later, the iOS app got the same overhaul: TabView, a floating action button, a SwiftUI Charts glucose chart, and sheet modals for input. Same design. Same information architecture. Not a single line of shared code.</p>

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>

## The monolith problem

Both platforms had the same structural issue. Everything lived on one screen.

The iOS app had a 1,166-line `DashboardView` that tried to do everything: display the current glucose reading, render an inline food input form with AI estimation, show treatment logging buttons, present a full meal timeline with confirm/reject/edit/delete actions, and host a settings modal. Scrolling down to log a meal meant scrolling past data you didn't need. Scrolling back up to check your glucose meant scrolling past the form you just used.

The web UI had the same problem in a different language. A single HTML page rendered by a Python string: CGM bar, metrics row, food form, treatment form, timeline. One long vertical stack with no way to navigate between sections.

Neither platform had a glucose chart. Neither had a way to browse history beyond today. Both had input forms wedged inline between display elements, competing for attention on every visit.

<blockquote class="blog-pullquote">When the dashboard tries to be everything, it ends up being good at nothing.</blockquote>

## Web first

The web UI moved first. The single page became a client-side hash router with four routes:

<div class="spec-grid spec-grid-2col">
  <div class="spec-card">
    <div class="spec-card-title">#/dashboard</div>
    <div class="spec-card-desc">CGM reading, metrics, 24-hour glucose chart, today's timeline.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">#/food</div>
    <div class="spec-card-desc">Dedicated food input page with category buttons, nutrition grid, AI estimation.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">#/treatment</div>
    <div class="spec-card-desc">Treatment type selector, units input, time picker.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">#/history</div>
    <div class="spec-card-desc">Range picker (24h/3d/7d/14d), glucose chart, full event timeline.</div>
  </div>
</div>

A floating action button on the dashboard opens to reveal Food and Treatment shortcuts. A hamburger menu slides in a navigation drawer. Input forms live on their own pages instead of being wedged inline.

The glucose chart uses Canvas 2D with coloured range bands &mdash; blue-purple for low, green for in-range (3.9&ndash;10.0 mmol/L), orange-red for high. Dashed threshold lines at 3.9 and 10.0. Retina-aware pixel scaling. And a gap detection algorithm: if consecutive readings are more than ten minutes apart, the line breaks rather than drawing a misleading straight line across the gap.

## iOS, eighteen hours later

The iOS app solved the same problems with the same structure but different tools.

The monolithic `DashboardView` split into a three-tab `TabView`: Dashboard, History, and Settings. The same floating action button pattern &mdash; but instead of navigating to a hash route, it presents SwiftUI `.sheet()` modals for food and treatment input.

The glucose chart uses SwiftUI Charts instead of Canvas. Same coloured range bands as the web version (rendered as `RectangleMark` backgrounds with low opacity). Same dashed threshold lines at 3.9 and 10.0. Same gap detection threshold: 600 seconds. When the gap is detected, the line breaks into separate segments, each coloured by the glucose range it passes through.

The timeline &mdash; previously inline in the dashboard &mdash; was extracted into a shared `TimelineView` component used by both the Dashboard and History tabs. A `TimelineActions` service centralises the CRUD operations so both views share the same confirm, reject, and delete logic.

<div class="blog-stat-row">
  <div class="blog-stat"><div class="blog-stat-num">1,166</div><div class="blog-stat-label">lines before</div></div>
  <div class="blog-stat"><div class="blog-stat-num">380</div><div class="blog-stat-label">lines after</div></div>
  <div class="blog-stat"><div class="blog-stat-num">5</div><div class="blog-stat-label">new files</div></div>
</div>

## The convergence table

Nobody planned for the two platforms to match. There was no design document, no shared component library, no cross-platform framework. The web UI was built, then the iOS app was updated to solve the same problems. The designs converged because the constraints were identical.

- **Navigation model:** The web uses hash routing (`#/dashboard`, `#/food`). iOS uses a bottom `TabView` with three tabs. Different mechanism, same information architecture.
- **Quick entry:** Both use a floating action button that reveals Food and Treatment shortcuts. Web overlays action buttons; iOS presents sheet modals.
- **Glucose chart:** Web uses Canvas 2D. iOS uses SwiftUI Charts. Both draw coloured range bands, dashed threshold lines, and break the line on gaps longer than ten minutes.
- **History:** Both offer the same four ranges &mdash; 24 hours, 3 days, 7 days, 14 days &mdash; backed by the same `sinceMs` API parameter.
- **Timeline:** Both merge meals and treatments into a single chronological feed with swipe-to-edit and swipe-to-delete actions.
- **Theme:** Dark background, warm amber accent, range colours from blue through green to red. The same palette, applied independently.

<blockquote class="blog-pullquote">The shared design language came from the problem domain, not a component library.</blockquote>

## Why convergence happens

Cross-platform design consistency is usually enforced &mdash; through shared design tokens, component libraries, or frameworks like React Native that compile to both targets. islet has none of that. The web UI is a Python string. The iOS app is SwiftUI. They don't share a single file.

The convergence happened because the constraints are the same on both platforms:

- Glucose data has gaps. Both platforms need to handle them. A ten-minute threshold is the natural choice because that's the CGM reading interval.
- The useful time ranges for diabetes management are the same regardless of platform: the last day, a few days, a week, two weeks.
- A floating action button for quick entry works on both because the primary use case is the same: you just ate something and need to log it quickly.
- Dark mode with warm amber is not a style choice repeated for consistency. It's the original iOS design, and the web UI adopted it because the same person uses both and expects the same visual language.

The design isn't shared. The problem is shared. When two implementations solve the same problem under the same constraints, they tend to arrive at the same answer.

## What changed underneath

The API grew to support both platforms:

- A `sinceMs` query parameter on the CGM, meal, and treatment endpoints lets both clients fetch exactly the data they need for a given time range, instead of requesting everything and filtering client-side.
- A proper `DELETE` endpoint for meals replaced the previous workaround of using reject-as-delete.
- The CGM entry cap increased from 2,880 to 20,160 to support 14-day history views.

None of these changes were platform-specific. They were driven by the navigation overhaul revealing what the API was missing.

## The result

Both platforms now have the same three-zone layout: a dashboard for right now, input forms for logging, and a history view for looking back. The glucose chart &mdash; the single most useful addition &mdash; gives an immediate visual read of the last 24 hours that no table of numbers can match.

The iOS app dropped from one screen doing everything to five focused components. The web UI went from a monolithic HTML string to a routed application with dedicated pages. Both are easier to extend because new features have clear places to live.

And the design language holds, not because it was enforced, but because it was inevitable.

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>
