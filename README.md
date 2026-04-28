# DjSwiftServer

Swift Hummingbird server package for the DJ workspace.

## Table of Contents

- [Overview](#overview)
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
