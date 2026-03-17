---
title: "Teaching glucore to look ahead"
date: 2026-03-07T01:00:00+00:00
description: "glucore gained forward prediction, parameter tuning, and calibration — the first steps toward a system that learns from its own data rather than relying on fixed assumptions."
tags: ["islet", "glucore", "analytics"]
---

<p class="blog-lead">Until this week, glucore could describe what had happened. IOB and COB curves modelled insulin and carbs in progress. Trend analysis showed which direction glucose was heading. But it could not answer the question that actually matters: where will glucose be in an hour?</p>

## The prediction problem

Predicting blood glucose is harder than it looks. The obvious approach — extrapolate the current trend — fails quickly. A falling trend after a meal correction does not mean glucose will keep falling at the same rate. Insulin activity peaks and then decays. Carbs absorb at different speeds depending on composition. Momentum from a rapid rise can persist for minutes after the underlying cause has passed.

A useful prediction has to simulate these overlapping effects forward through time, not just draw a straight line.

## Forward simulation

glucore's forward engine works in 5-minute steps. At each step it calculates the insulin activity (how much glucose is being lowered right now), the carb absorption rate (how much is being raised), and the residual momentum from the current trend. It advances the predicted glucose value by the net effect, then moves to the next step.

The result is a predicted trajectory at 30, 60, and 120 minute horizons. Each prediction includes an uncertainty band that widens with time — a 30-minute prediction is inherently more trustworthy than a 120-minute one. The uncertainty is not decorative; it reflects real factors like data freshness, CGM reading density, and whether momentum data is available.

When historical prediction error data exists, the uncertainty bands are calibrated against actual RMSE rather than theoretical assumptions. The system gets more accurate about its own accuracy over time.

## Parameter tuning

The forward engine depends on therapy parameters — duration of insulin action (DIA), insulin peak time, insulin sensitivity factor (ISF), and carb ratio. Most systems use fixed values entered by the user or their clinician. These are approximations. They change with time of day, activity, stress, illness, and a dozen other factors.

glucore's tuning module searches a grid of candidate parameter sets, scores each against historical meal and bolus events, and finds the combination that minimises prediction error. The grid is deliberately coarse — around 50 candidates — to keep runtime reasonable on a Raspberry Pi. The goal is not to find globally optimal parameters but to find parameters that explain this person's actual data better than the defaults.

The search requires at least three scored events to produce a result. With fewer, the system does not tune — it acknowledges that it does not have enough information.

## Calibration

Separate from tuning, the calibration module fits the insulin activity curve itself. It extracts isolated bolus events — injections with no nearby meals to confound the signal — and compares the observed post-bolus glucose decay against candidate curves with different DIA and peak values.

The isolation criteria are strict: no meal within 90 minutes, stable pre-bolus glucose (less than 2 mmol/L variation over 30 minutes), at least 8 CGM readings in the post-bolus window. Most boluses do not qualify. That is intentional — a smaller set of clean events produces better fits than a larger set of noisy ones.

<blockquote class="blog-pullquote">The system learns from its cleanest data, not its most abundant data.</blockquote>

## What this changes

Before this week, glucore's outputs were reactive. Now they are projective. The iOS app gained prediction charts that show where glucose is heading, with uncertainty bands and accuracy scores drawn from historical performance. The food response module can model how a specific meal is likely to affect glucose based on observed patterns, not just textbook absorption rates.

None of this produces dosing advice. The safety contract has not changed — predictions are informational, uncertainty is always shown, and the system never suggests insulin adjustments. But the gap between "here is your current glucose" and "here is what your glucose is likely to do" is a meaningful one. It is the difference between a recording tool and a system that is beginning to understand the data it collects.

## Current state

The forward prediction engine, parameter tuner, and calibration module add roughly 2,400 Python SLOC across 8 modules, with 1,400 lines of tests. The scoring engine validates predictions against actual outcomes using RMSE, MAE, and directional accuracy. The iOS app renders predictions as overlay lines on the glucose chart with colour-coded confidence indicators.

It is early. The parameter grid is coarse. The calibration requires bolus isolation criteria that exclude most real-world events. The uncertainty bands are wider than I would like. But the architecture is right — a system that measures its own accuracy, fits its own parameters, and gets better as it accumulates data. The hard part was not the maths. The hard part was building the infrastructure to do it safely.
