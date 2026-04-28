# DjSwiftServer

Swift Hummingbird server package for the DJ workspace.

## Table of Contents

- [Overview](#overview)
- [Long-Term Direction](#long-term-direction)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Development](#development)
- [Repo Structure](#repo-structure)
- [Planning Docs](#planning-docs)
- [Release Notes](#release-notes)
- [License](#license)

## Overview

### Status

This project has a validated Hummingbird server baseline and source-of-truth catalog record models that project into the current read-only listener API. Runtime catalog storage is not implemented yet; the checked-in JSON catalog is a test fixture only.

### What This Project Is

DjSwiftServer is a macOS 15+ Swift Package Manager executable that runs a Hummingbird HTTP server for an internet radio platform. The server publishes station metadata, schedules, show metadata, provider references, and voice break metadata so listener apps can play scheduled music through the listener's own Apple Music account and interleave server-hosted breaks.

### Motivation

This repo exists to give the DJ workspace a Swift-native schedule authority. It should coordinate what plays and when without acting as an Apple Music streaming proxy or receiving listener account credentials.

## Long-Term Direction

DjSwiftServer should become a self-hostable personal radio station server that someone can run on their own Mac. The Mac app or command-line package should own the station database, publish schedules and manifests, serve voice breaks, and expose clear operator controls without requiring a hosted SaaS account.

The public listener API should support both local-only testing and open-internet access. Local operators should be able to run the server on their Mac and optionally publish it through a gateway such as [Cloudflare Tunnel](https://developers.cloudflare.com/tunnel/) so listener apps can fetch manifests, schedules, and audio metadata from a stable HTTPS URL. A hosted server deployment path should remain possible for users who want their station running away from their personal machine.

The project should also grow an MCP surface for station operation. That surface should let tools such as ChatGPT or Codex inspect station state, draft schedules, prepare playlist imports, validate provider references, manage voice-break metadata, and publish schedule revisions through explicit user-approved actions.

Future distribution should include a [Codex plugin](https://developers.openai.com/codex/plugins/build) and/or [ChatGPT App](https://developers.openai.com/apps-sdk/) packaging path. The plugin/app should bundle setup guidance, MCP configuration, and app metadata so users can connect their personal station to AI tools. The goal is for users to combine this server with music-service integrations where available, create or refine playlists with assistance, and publish those playlists into their personal internet radio station.

## Quick Start

```bash
swift run DjSwiftServer
```

Then check the server from another terminal:

```bash
curl http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/v1/manifest
curl http://127.0.0.1:8080/v1/schedule/current
```

## Usage

The executable starts a local Hummingbird application on `127.0.0.1:8080`. Public listener data lives under `/v1`.

```text
GET /                     -> DjSwiftServer is running.
GET /health               -> HTTP 200 OK
GET /v1/health            -> JSON health payload
GET /v1/manifest          -> station manifest
GET /v1/schedule/current  -> current schedule window
GET /v1/schedule          -> schedule window filtered by ISO 8601 `from` and `to` query values
GET /v1/shows/{showID}    -> show metadata
GET /v1/breaks/{breakID}  -> voice break metadata
```

The current executable is still a local development server. It does not yet configure persistent storage, an MCP endpoint, tunneling, hosted deployment, or plugin/app packaging.

## Development

### Setup

Use the checked-in SwiftPM manifest as the package source of truth.

```bash
swift package resolve
```

### Workflow

Keep server behavior in `Sources/DjSwiftServer/`, authored catalog test fixtures in `Tests/DjSwiftServerTests/Resources/`, and route coverage in `Tests/DjSwiftServerTests/`. Prefer `swift package` commands for dependency and target changes when SwiftPM provides one.

### Validation

```bash
swift build
swift test
scripts/repo-maintenance/validate-all.sh
```

## Repo Structure

```text
.
|-- Package.swift
|-- docs/
|-- Sources/
|   `-- DjSwiftServer/
|-- Tests/
|   `-- DjSwiftServerTests/
|-- scripts/
|   `-- repo-maintenance/
|-- AGENTS.md
|-- README.md
`-- ROADMAP.md
```

## Planning Docs

- [Initial Data Model and API Plan](docs/initial-data-model-and-api-plan.md)
- [Full Data Model Plan](docs/full-data-model-plan.md)

## Release Notes

There are no tagged releases yet. Record notable shipped changes here or in GitHub release notes once the package starts publishing versioned releases.

## License

No license has been declared yet.
