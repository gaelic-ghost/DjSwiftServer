# DjSwiftServer

Swift Hummingbird server package for the DJ workspace.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Development](#development)
- [Repo Structure](#repo-structure)
- [Release Notes](#release-notes)
- [License](#license)

## Overview

### Status

This project is just starting out with a validated Hummingbird server baseline.

### What This Project Is

DjSwiftServer is a macOS 15+ Swift Package Manager executable that runs a small Hummingbird HTTP server. The current server listens on `127.0.0.1:8080`, exposes `/` for a startup response, and exposes `/health` for a simple health check.

### Motivation

This repo exists to give the DJ workspace a Swift-native server surface that can grow from a small, testable Hummingbird foundation instead of starting from an unstructured executable stub.

## Quick Start

```bash
swift run DjSwiftServer
```

Then check the server from another terminal:

```bash
curl http://127.0.0.1:8080/
curl -i http://127.0.0.1:8080/health
```

## Usage

The executable starts a local Hummingbird application on `127.0.0.1:8080`.

```text
GET /        -> DjSwiftServer is running.
GET /health  -> HTTP 200 OK
```

## Development

### Setup

Use the checked-in SwiftPM manifest as the package source of truth.

```bash
swift package resolve
```

### Workflow

Keep server behavior in `Sources/DjSwiftServer/`, and keep route coverage in `Tests/DjSwiftServerTests/`. Prefer `swift package` commands for dependency and target changes when SwiftPM provides one.

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

## Release Notes

There are no tagged releases yet. Record notable shipped changes here or in GitHub release notes once the package starts publishing versioned releases.

## License

No license has been declared yet.
