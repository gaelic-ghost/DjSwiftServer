# Project Roadmap

Use this roadmap to track milestone-level delivery through checklist sections.

## Table of Contents

- [Vision](#vision)
- [Product Principles](#product-principles)
- [Milestone Progress](#milestone-progress)
- [Milestone 0: Foundation](#milestone-0-foundation)
- [Milestone 1: Server Shape](#milestone-1-server-shape)
- [Milestone 2: Provider Resolution](#milestone-2-provider-resolution)
- [Backlog Candidates](#backlog-candidates)
- [History](#history)

## Vision

- Build a small, reliable Swift-native server for the DJ workspace that can grow through explicit Hummingbird routes, focused tests, and documented operational behavior.

## Product Principles

- Keep the server runnable and understandable from SwiftPM alone.
- Prefer small route surfaces with direct request/response tests before adding broader server structure.
- Document operator-facing behavior as soon as routes, ports, configuration, or validation commands change.

## Milestone Progress

Use this section as a concise rollup of milestone names and statuses, not as a second task list.

- Milestone 0: Foundation - Completed
- Milestone 1: Server Shape - Completed
- Milestone 2: Provider Resolution - In Progress

## Milestone 0: Foundation

### Status

Completed

### Scope

- [x] Establish a macOS 15+ SwiftPM executable package with Swift language mode `.v6`.
- [x] Add Hummingbird as the HTTP server dependency.
- [x] Add a minimal runnable server with root and health routes.
- [x] Add route tests through Hummingbird's test framework.

### Tickets

- [x] Bootstrap the package with repo-maintenance tooling.
- [x] Resolve Hummingbird through SwiftPM.
- [x] Validate with `swift build` and `swift test`.

### Exit Criteria

- [x] `swift build` succeeds.
- [x] `swift test` succeeds with route coverage.
- [x] README, roadmap, and AGENTS guidance exist at the repo root.

## Milestone 1: Server Shape

### Status

Completed

### Scope

- [x] Define the first public listening API responsibilities and keep route ownership explicit.
- [x] Capture the schedule-authority model in a durable planning doc.
- [x] Add static JSON endpoints for manifest, current schedule, show metadata, and break metadata.
- [x] Keep configuration hard-coded for local development while the first route contract settles.

### Tickets

- [x] Add `docs/initial-data-model-and-api-plan.md`.
- [x] Split app bootstrap from route registration.
- [x] Add Codable response models for the initial public contract.
- [x] Add request/response tests for public JSON routes.
- [x] Make schedule-window queries parse explicit ISO 8601 `from` and `to` values.

### Exit Criteria

- [x] The server exposes the first read-only listener API under `/v1`.
- [x] Public response models are covered by Swift Testing route tests.
- [x] README, roadmap, and planning docs match the implemented behavior.

## Milestone 2: Provider Resolution

### Status

In Progress

### Scope

- [ ] Add Apple Music catalog resolution rules without handling listener Music User Tokens on the server.
- [x] Preserve provider-neutral schedule data while making Apple Music IDs first-class provider references.
- [x] Prepare the same provider-reference shape for Spotify IDs or URIs later.

### Tickets

- [x] Decide whether provider resolution data is authored manually, imported from playlists, or reconciled through a server-side catalog job.
- [x] Add storefront and ISRC fallback behavior to the sample provider-reference model.
- [ ] Document client-side MusicKit responsibilities in the future app repo when that repo exists.

### Exit Criteria

- [x] Scheduled tracks carry enough provider data for the listener app to resolve Apple Music playback.
- [x] Server docs clearly state that listener account authorization remains client-owned.
- [x] The model can add Spotify provider references without changing segment identity.

## Backlog Candidates

- [ ] Add structured logging once startup and request diagnostics need more than Hummingbird defaults.
- [ ] Add OpenAPI documentation if the endpoint surface grows beyond a handful of routes.
- [ ] Add release automation notes before the first tag.
- [ ] Consider Server-Sent Events or WebSockets if live schedule corrections need faster delivery than polling.

## History

- Initial roadmap scaffold created.
- 2026-04-24: Bootstrapped the Swift 6 Hummingbird server foundation for macOS 15+.
- 2026-04-24: Captured the initial internet-radio data model and public API plan.
- 2026-04-24: Started provider-resolution scope with manual provider references, Apple Music storefront data, and ISRC fallback coverage.
