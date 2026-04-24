# Project Roadmap

Use this roadmap to track milestone-level delivery through checklist sections.

## Table of Contents

- [Vision](#vision)
- [Product Principles](#product-principles)
- [Milestone Progress](#milestone-progress)
- [Milestone 0: Foundation](#milestone-0-foundation)
- [Milestone 1: Server Shape](#milestone-1-server-shape)
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
- Milestone 1: Server Shape - Planned

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

Planned

### Scope

- [ ] Define the first real DJ-facing API responsibilities and keep route ownership explicit.
- [ ] Decide whether configuration stays hard-coded for local development or moves into a typed config source.
- [ ] Add logging that makes startup, bind address, and request failures clear to an operator.

### Tickets

- [ ] Replace placeholder root behavior with the first real endpoint set.
- [ ] Add configuration notes once the bind address or port becomes user-controlled.
- [ ] Add error-path tests for the first route that can fail.

### Exit Criteria

- [ ] The server has a documented first real use case beyond health checks.
- [ ] New route behavior has Swift Testing coverage.
- [ ] Operator-facing messages and docs match the implemented behavior.

## Backlog Candidates

- [ ] Add structured logging once startup and request diagnostics need more than Hummingbird defaults.
- [ ] Add OpenAPI documentation if the endpoint surface grows beyond a handful of routes.
- [ ] Add release automation notes before the first tag.

## History

- Initial roadmap scaffold created.
- 2026-04-24: Bootstrapped the Swift 6 Hummingbird server foundation for macOS 15+.
