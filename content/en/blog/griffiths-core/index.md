---
title: "One toolkit, every project"
date: 2026-03-01T18:00:00+00:00
description: "How griffiths-core replaced per-project deployment scripts with a shared submodule for build, test, deploy and release across islet, ira and gwefan."
tags: ["infrastructure", "tooling"]
---

<p class="blog-lead">Every project had its own deployment script. islet had deploy_pi.sh. gwefan had a bespoke scp chain. ira had nothing. Each script did roughly the same thing — build, upload, restart — but each did it differently enough that copying between projects meant editing half the lines. On Saturday, all three projects switched to a single shared toolkit.</p>

## The duplication problem

islet's deploy script was the most mature. It rsynced Python source and config files to the Pi, restarted two systemd services, ran a smoke test against the health endpoint, and printed a status summary. It worked well. It had also been rewritten twice as the project grew, and the third version was 80 lines of bash that nobody would want to port to another project.

gwefan's deploy was simpler: run Hugo, scp the output, sudo copy to the web root. But it had the same structure — build locally, transfer, swap into place — just with different verbs.

ira had no deployment at all. It builds and runs on Windows. But it still needed a test runner, and the pattern of "detect project type, run the right command, format the output" was the same.

Three projects, three scripts (or two scripts and a gap), one pattern.

## griffiths-core

The solution is a git submodule that lives at `tools/griffiths-core/` in every project. It provides four commands:

- **gc-test** — detect the project's test runner (pytest, meson, cargo, xcodebuild) from a config file, set up the environment, run tests, report results
- **gc-deploy** — build locally if needed, transfer to the target host, swap into place, restart services, run smoke tests
- **gc-release** — bump version (CalVer or SemVer), generate changelog from git log, create a signed tag
- **gc-status** — cross-project health dashboard showing versions, test results, service status

Each project provides a small config file (`test.conf`, `deploy.conf`) that declares project-specific values — which test runner to use, where to deploy, which services to restart. The toolkit reads the config and does the rest.

## What the config looks like

gwefan's deploy config is seven lines:

```ini
target=griffpi-static
ssh_key=~/.ssh/claude_pi
ssh_user=chris
ssh_host=griffpi
build_cmd=hugo --minify
build_output=public/
remote_path=/var/www/gwefan/
```

islet's is longer because it deploys a systemd service with two units, syncs multiple directories, and runs a smoke test. But the format is the same. The complexity lives in the config, not in per-project scripts.

## What changed in each project

**gwefan** — `deploy.sh` became a two-line shim that calls `tools/griffiths-core/bin/gc-deploy.sh`. The previous inline script was deleted.

**islet** — `deploy_pi.sh` was replaced by the same pattern. Test running moved from a custom `run_pytest.ps1` to `gc-test`, which also handles clearing environment variables and setting up the virtualenv.

**ira** — gained a test runner for the first time. `gc-test` detects the Meson build system from `test.conf` and runs `meson test` with the right flags.

## Why a submodule

The alternative was a package manager, a shared repo with copy-paste, or a monorepo. Each has trade-offs:

- **Package manager** — bash scripts don't have one. Making this a pip/npm/cargo package adds dependency machinery for something that is four shell scripts.
- **Copy-paste** — the original problem. Divergence is immediate and invisible.
- **Monorepo** — the projects are genuinely independent. Coupling their git history for shared tooling is not worth it.

A git submodule pins to a specific commit. Each project can update independently. The toolkit evolves in one place. `git submodule update` pulls the latest version. There is no build step, no package registry, no version resolution. It is the simplest mechanism that actually works for shared shell tooling.

<blockquote class="blog-pullquote">The right amount of infrastructure is the least amount that eliminates duplication.</blockquote>

## What it enables

The immediate benefit is consistency. `bash deploy.sh` works the same way in every project. The deploy output has the same format. Errors are reported the same way. A new project gets deployment by writing a config file, not a script.

The longer-term benefit is composability. `gc-status` can query all projects at once — show which services are running on the Pi, which projects have uncommitted changes, which test suites are passing. That is only possible because every project reports status through the same interface.

It is not a framework. It is a shared vocabulary for operations that every project needs and none of them should implement independently.
