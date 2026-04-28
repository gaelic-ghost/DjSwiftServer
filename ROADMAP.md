# Project Roadmap

Use this roadmap to track milestone-level delivery through checklist sections.

## Table of Contents

- [Vision](#vision)
- [Product Principles](#product-principles)
- [Milestone Progress](#milestone-progress)
- [Milestone 0: Foundation](#milestone-0-foundation)
- [Milestone 1: Server Shape](#milestone-1-server-shape)
- [Milestone 2: Provider Resolution](#milestone-2-provider-resolution)
- [Milestone 3: Authored Catalog](#milestone-3-authored-catalog)
- [Milestone 4: Storage and Station Ownership](#milestone-4-storage-and-station-ownership)
- [Milestone 5: Self-Hosting and Public Gateway](#milestone-5-self-hosting-and-public-gateway)
- [Milestone 6: MCP Surface](#milestone-6-mcp-surface)
- [Milestone 7: Plugin and App Distribution](#milestone-7-plugin-and-app-distribution)
- [Backlog Candidates](#backlog-candidates)
- [Reference Links](#reference-links)
- [History](#history)

## Vision

- Build a self-hostable Swift-native personal radio station server that anyone can run on their Mac.
- Let station operators publish schedules, manifests, voice-break metadata, and provider references without proxying listener music streams or collecting listener account credentials.
- Support local-only development, open-internet self-hosting through a tunnel or gateway, and hosted deployments for users who do not want their station tied to a personal machine.
- Expose an MCP control surface so ChatGPT, Codex, and other MCP clients can help operators plan playlists, validate station data, manage schedule revisions, and operate their station through explicit user-approved actions.
- Package the operator experience as a Codex plugin and/or ChatGPT App so setup guidance, MCP configuration, station tools, and app metadata can travel together.

## Product Principles

- Keep the server runnable and understandable from SwiftPM alone.
- Prefer small route surfaces with direct request/response tests before adding broader server structure.
- Document operator-facing behavior as soon as routes, ports, configuration, or validation commands change.
- Keep listener playback authorization client-owned. The server should publish schedule authority and metadata, not become a music streaming proxy.
- Treat public exposure as an explicit operator choice. Local self-hosting, public tunneling, and hosted deployment should have clear setup, logging, and security expectations.
- Keep AI-assisted operations reviewable. MCP tools that change station state should make their inputs and consequences clear before publishing or mutating data.

## Milestone Progress

Use this section as a concise rollup of milestone names and statuses, not as a second task list.

- Milestone 0: Foundation - Completed
- Milestone 1: Server Shape - Completed
- Milestone 2: Provider Resolution - In Progress
- Milestone 3: Authored Catalog - Completed
- Milestone 4: Storage and Station Ownership - Planned
- Milestone 5: Self-Hosting and Public Gateway - Planned
- Milestone 6: MCP Surface - Planned
- Milestone 7: Plugin and App Distribution - Planned

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

## Milestone 3: Authored Catalog

### Status

Completed

### Scope

- [x] Move route tests onto an authored catalog fixture without making that fixture a runtime data source.
- [x] Add source-of-truth record types that are separate from public response models.
- [x] Add validation for catalog IDs, references, schedule windows, segment timing, provider references, and voice-break media metadata.
- [x] Add explicit projection from authored records to listener API responses.

### Tickets

- [x] Add `docs/full-data-model-plan.md`.
- [x] Add a JSON catalog fixture under the test target.
- [x] Add catalog record types and loader.
- [x] Add validation errors that name the record type, record ID, field, and likely fix.
- [x] Add projection tests from catalog records to public responses.

### Exit Criteria

- [x] Route tests load from authored records instead of constructing response data directly in Swift.
- [x] Invalid catalog fixtures fail with descriptive operator-facing errors.
- [x] Public route behavior remains covered by Swift Testing tests.
- [x] README, roadmap, and planning docs clearly distinguish source-of-truth records from public response models.

## Milestone 4: Storage and Station Ownership

### Status

Planned

### Scope

- [ ] Choose the runtime database and migration strategy for station-owned data.
- [ ] Model persistent station identity, playback policy, hosts, shows, tracks, provider references, voice breaks, schedule publications, and schedule segments.
- [ ] Add repository or store APIs that make read paths, write paths, validation, and publication boundaries explicit.
- [ ] Preserve the current test JSON only as a fixture, not as runtime storage.

### Exit Criteria

- [ ] The server boots from a configured persistent data source instead of static runtime data.
- [ ] Database constraints match the catalog validation rules where practical.
- [ ] Operators can inspect and back up the station database using documented commands.

## Milestone 5: Self-Hosting and Public Gateway

### Status

Planned

### Scope

- [ ] Document local Mac self-hosting for the SwiftPM executable.
- [ ] Add configuration for bind host, port, public base URL, station database path, and media storage path.
- [ ] Plan a public gateway path for local self-hosting through a tunnel such as Cloudflare Tunnel.
- [ ] Plan a hosted deployment path for operators who want the server running on a cloud host.
- [ ] Add health, diagnostics, logs, and operator-facing startup errors that make local and public hosting problems understandable.

### Exit Criteria

- [ ] A Mac user can run the server locally and verify listener routes from another device on the network.
- [ ] A Mac user can publish the listener API through a documented HTTPS gateway without opening inbound router ports.
- [ ] Hosted deployment requirements are documented, including TLS, persistence, logs, and long-running process expectations.

## Milestone 6: MCP Surface

### Status

Planned

### Scope

- [ ] Add an MCP endpoint that can be reached locally and, when configured, through the public gateway.
- [ ] Define read tools for station status, catalog inspection, schedule lookup, provider-reference inspection, and validation reports.
- [ ] Define write tools for playlist import, schedule draft creation, voice-break metadata updates, provider-reference updates, and schedule publication.
- [ ] Require explicit review for tools that mutate station state or publish a schedule revision.
- [ ] Keep tool descriptions, inputs, outputs, and errors descriptive enough for ChatGPT, Codex, and human operators to understand the consequence of each action.

### Exit Criteria

- [ ] MCP clients can inspect station state through read-only tools.
- [ ] Mutating tools are separated from read tools and make publication consequences explicit.
- [ ] The MCP surface can run against both local and publicly reachable deployments.

## Milestone 7: Plugin and App Distribution

### Status

Planned

### Scope

- [ ] Package station-operation guidance, setup checks, and MCP configuration as a Codex plugin.
- [ ] Evaluate a ChatGPT App surface for operators who want a guided station dashboard or playlist-publishing workflow in ChatGPT.
- [ ] Include metadata, icons, screenshots, privacy notes, and setup prompts needed for distribution.
- [ ] Plan how users can combine this station server with music-service integrations where available to create, refine, and publish playlists into their personal radio station.
- [ ] Document app/plugin setup for local tunnel deployments and hosted deployments.

### Exit Criteria

- [ ] A Codex user can install the plugin and connect it to their station MCP endpoint.
- [ ] A ChatGPT user can connect the app to a reachable station MCP endpoint.
- [ ] Plugin/app docs clearly explain what station data is read, what actions can mutate station state, and what stays on the user's machine or server.

## Backlog Candidates

- [ ] Add structured logging once startup and request diagnostics need more than Hummingbird defaults.
- [ ] Add OpenAPI documentation if the endpoint surface grows beyond a handful of routes.
- [ ] Add release automation notes before the first tag.
- [ ] Consider Server-Sent Events or WebSockets if live schedule corrections need faster delivery than polling.
- [ ] Evaluate whether the local Mac distribution should be a plain SwiftPM executable, signed app bundle, LaunchAgent-managed service, or a combination.
- [ ] Decide how station data export/import should work so self-hosted operators can back up and migrate their stations.

## Reference Links

- [OpenAI MCP server guide](https://developers.openai.com/api/docs/mcp)
- [OpenAI Apps SDK](https://developers.openai.com/apps-sdk/)
- [OpenAI Apps SDK deployment guide](https://developers.openai.com/apps-sdk/deploy)
- [OpenAI Codex plugin structure](https://developers.openai.com/codex/plugins/build#plugin-structure)
- [Cloudflare Tunnel](https://developers.cloudflare.com/tunnel/)

## History

- Initial roadmap scaffold created.
- 2026-04-24: Bootstrapped the Swift 6 Hummingbird server foundation for macOS 15+.
- 2026-04-24: Captured the initial internet-radio data model and public API plan.
- 2026-04-24: Started provider-resolution scope with manual provider references, Apple Music storefront data, and ISRC fallback coverage.
- 2026-04-28: Planned the full authored catalog, validation, and projection model.
- 2026-04-28: Added authored catalog records, validation, explicit public response projection, and a JSON fixture scoped to tests only.
- 2026-04-28: Captured the self-hosted Mac server, public gateway, MCP, Codex plugin, and ChatGPT App product direction.
