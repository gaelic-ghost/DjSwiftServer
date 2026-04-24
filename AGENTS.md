# AGENTS.md

Use this file for durable repo-local guidance that Codex should follow before changing code, docs, or project workflow surfaces in this repository.

## Repository Scope

This root guidance covers the whole `DjSwiftServer` Swift package.

### What This File Covers

This repo is a Swift Package Manager executable package for a macOS 15+ Hummingbird HTTP server. Treat `Package.swift`, `Sources/DjSwiftServer/`, `Tests/DjSwiftServerTests/`, `README.md`, and `ROADMAP.md` as the main working surfaces.

### Where To Look First

- `Package.swift` for platform, language mode, products, targets, and package dependencies.
- `Sources/DjSwiftServer/DjSwiftServer.swift` for the current Hummingbird app entry point and routes.
- `Tests/DjSwiftServerTests/DjSwiftServerTests.swift` for route coverage.
- `README.md` for current run, usage, and validation notes.
- `ROADMAP.md` for planned server shape and milestone scope.

## Working Rules

### Change Scope

Keep changes focused on the server behavior, package manifest, tests, and nearby docs required by the task. If a route starts needing configuration, storage, telemetry, or a broader module split, surface that scope change before widening the design.

### Source of Truth

Use Swift Package Manager as the source of truth for package structure and dependencies. Prefer `swift package` commands for dependency and target changes when SwiftPM provides a suitable command; edit `Package.swift` intentionally when the manifest needs a shape the CLI cannot express cleanly.

Keep the package explicit about Swift 6 by preserving `swiftLanguageModes: [.v6]`. Swift 6 language mode is the strict-concurrency baseline for this package.

### Communication and Escalation

Call out changes that affect the server's bind address, port, route names, operator-facing output, dependency graph, or release process. Ask before introducing persistent storage, background services, launchd integration, external network dependencies, or a compatibility shim.

## Commands

### Setup

```bash
swift package resolve
scripts/repo-maintenance/sync-shared.sh
scripts/repo-maintenance/release.sh --help
```

### Validation

```bash
swift build
swift test
scripts/repo-maintenance/validate-all.sh
```

### Optional Project Commands

```bash
swift run DjSwiftServer
curl http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/health
```

## Review and Delivery

### Review Expectations

Review route behavior, package graph changes, strict-concurrency issues, operator-facing strings, and docs drift together. For Hummingbird changes, prefer request/response tests through `HummingbirdTesting` over only checking that the target compiles.

### Definition of Done

Work is done when the relevant SwiftPM checks pass, route behavior has focused test coverage when behavior changed, and README or roadmap details are updated for any changed commands, routes, ports, validation steps, or milestones.

## Safety Boundaries

### Never Do

- Do not hand-edit `Package.resolved`.
- Do not remove `swiftLanguageModes: [.v6]` unless Gale explicitly changes the language-mode contract.
- Do not introduce launchd, daemon installation, or local service management from this repo without explicit approval.
- Do not leave placeholder README, roadmap, or AGENTS text in committed docs.

### Ask Before

- Ask before changing the bind host or port from `127.0.0.1:8080`.
- Ask before adding persistent storage, authentication, external services, or long-running background workers.
- Ask before creating release tags, GitHub releases, or publishing repository visibility changes.

## Local Overrides

There are no nested `AGENTS.md` files at bootstrap time. If more specific guidance is added under a subdirectory later, that closer file refines this root guidance for work in that subtree.

## Swift Package Baseline

- Use Swift Testing (`import Testing`) as the default test framework.
- Prefer the simplest correct Swift that is easiest to read, reason about, and maintain.
- Prefer small focused types and explicit data flow over broad managers or mixed-responsibility files.
- For server-side Swift, prefer Swift Logging as the primary logging API when this repo needs explicit logging beyond framework defaults.
- Keep package resources under the owning target tree and declare them intentionally if resources are added later.
- Treat `scripts/repo-maintenance/validate-all.sh` as the maintainer validation entry point when checking the full repo baseline.
