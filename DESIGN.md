# Design System — casectl

## Product Context
- **What this is:** A headless-first controller for the Freenove FNK0107B Raspberry Pi case — manages fans, LEDs, and OLED via CLI, web dashboard, or plugins
- **Who it's for:** Raspberry Pi tinkerers who want proper hardware control
- **Space/industry:** Maker/hardware, open source Pi accessories
- **Project type:** Documentation/project site (Hugo, custom theme)

## Aesthetic Direction
- **Direction:** Retro-Industrial Hybrid — retro-futuristic structure (grid borders, monospace UI labels, system-call naming) with understated mechanical warmth
- **Decoration level:** Intentional — 1px grid-gap features, accent-tinted borders, subtle radial glow behind hero. No rounded cards, no noise/grain.
- **Mood:** Brushed aluminium and circuit boards. Technical, mechanical, quietly confident. Not "hacker terminal" cosplay, not corporate dark mode.
- **Reference:** The hybrid preview at `casectl-hybrid-preview.html` defines the layout and component language.

## Typography
- **Display/Hero:** Satoshi 700 — geometric, modern, creates hierarchy contrast with monospace UI elements
- **Body:** DM Sans 400/500 — clean, readable at body sizes, good for docs. Optical sizing works from 12px to 18px.
- **UI/Labels:** IBM Plex Mono 500 — uppercase, letter-spaced, for nav links, feature labels (FAN_CTRL, LED_FX), badges
- **Data/Tables:** JetBrains Mono (tabular-nums supported)
- **Code:** JetBrains Mono 400
- **Loading:** Google Fonts CDN (`https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500&family=JetBrains+Mono:wght@400;500&display=swap`) + Fontshare (`https://api.fontshare.com/v2/css?f[]=satoshi@400,500,700&display=swap`)
- **Scale:** (1.25 ratio) xs: 0.75rem (12px), sm: 0.875rem (14px), base: 1rem (16px), lg: 1.125rem (18px), xl: 1.25rem (20px), 2xl: 1.5rem (24px), 3xl: 1.875rem (30px), 4xl: 2.25rem (36px), 5xl: 3rem (48px)

## Color
- **Approach:** Restrained — desaturated cool accent + neutral dark backgrounds. Colour is rare and meaningful.
- **Primary (accent):** #8aaac4 (arctic steel) — like brushed aluminium, understated, mechanical
- **Accent hover:** #a4c4de
- **Accent muted:** rgba(138, 170, 196, 0.12)
- **Accent border:** rgba(138, 170, 196, 0.16)
- **Accent glow:** rgba(138, 170, 196, 0.25) — used for brand text-shadow and hero radial gradient
- **Background:** #111315 (cool near-black)
- **Surface:** #171a1d (nav, sidebar)
- **Elevated:** #1e2124 (dropdowns, modals)
- **Code bg:** #0d0f11
- **Text primary:** #dce0e4 (cool off-white)
- **Text secondary (dim):** #6a7a8a
- **Text muted:** #4a5560
- **Text inverse:** #111315 (for text on accent backgrounds)
- **Border:** rgba(138, 170, 196, 0.1)
- **Border strong:** rgba(138, 170, 196, 0.16)
- **Grid line:** rgba(138, 170, 196, 0.06) — for 1px gap feature grids
- **Semantic:** success #4a9e6b, warning #c4943a, error #c45a4a, info #5a8fc4
- **Dark mode:** Default. Dark is primary.
- **Light mode:** bg #f0f2f4, surface #e4e8ec, elevated #d8dce0, code #f4f6f8, text #1a1e22, secondary #5a6a7a

## Spacing
- **Base unit:** 8px
- **Density:** Comfortable
- **Scale:** 2xs(2px) xs(4px) sm(8px) md(16px) lg(24px) xl(32px) 2xl(48px) 3xl(64px)

## Layout
- **Approach:** Grid-disciplined with retro grid-border structure
- **Home hero:** Centred, single column, radial accent glow behind headline
- **Feature grid:** 3-column, 1px gap (no cards with rounded corners — grid borders separate items)
- **Docs pages:** 180px sidebar + fluid content
- **Max content width:** 960px
- **Border radius:** 0 for feature grid items, 2px for code blocks, none for buttons (sharp edges). Only badges/pills use full radius.
- **Brand element:** `casectl_` with blinking cursor animation in nav

## Motion
- **Approach:** Minimal-functional — hover transitions only, plus blinking cursor on brand
- **Easing:** enter(ease-out) exit(ease-in) move(cubic-bezier(0.16, 1, 0.3, 1))
- **Duration:** fast(100ms) normal(200ms)
- **Brand cursor:** `animation: blink 1.2s step-end infinite`

## UI Patterns
- **Nav links:** IBM Plex Mono, uppercase, 0.05em letter-spacing, hover to accent colour
- **Feature labels:** IBM Plex Mono, uppercase, 0.06em letter-spacing, accent colour (e.g. FAN_CTRL, LED_FX, OLED_OUT)
- **Install command:** Monospace in a code-bg box with accent-border, prompt symbol in muted text
- **Buttons:** Sharp corners (no radius). Primary: accent bg + inverse text. Outline: transparent bg + accent-border + accent text. Both uppercase with 0.04em tracking.
- **Alerts:** 1px border + faint tinted bg. Success green, warning gold, error red, info blue.
- **Sidebar nav:** Active item gets left border (2px accent) + accent-faint background

## Decisions Log
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-26 | Initial design system created | Created by /design-consultation. Retro-industrial hybrid aesthetic. |
| 2026-03-26 | Satoshi for display, IBM Plex Mono for UI labels | Satoshi gives readable headlines. IBM Plex Mono for nav/feature labels creates the retro-technical identity. |
| 2026-03-26 | Arctic Steel #8aaac4 over 7 alternatives | Compared amber, blue, purple, copper, teal, vermillion, brass gold, steel. User chose steel for its understated mechanical quality — like brushed aluminium. |
| 2026-03-26 | Grid-border layout over rounded cards | Retro-futuristic structure: 1px gap grids instead of cards with border-radius. Sharper, more technical feel. |
| 2026-03-26 | Blinking cursor on brand name | `casectl_` with blinking underscore cursor. Small touch that signals "this is a CLI-first project." |
| 2026-03-26 | System-call feature names | FAN_CTRL, LED_FX, OLED_OUT, WEB_UI, PLUGINS, METRICS — uppercase monospace, evokes the codebase's actual module names. |
