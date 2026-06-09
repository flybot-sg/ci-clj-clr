# ci-clj-clr

<div align="center">
    <a href="https://github.com/flybot-sg/ci-clj-clr/actions/workflows/build-and-push.yml"><img src="https://github.com/flybot-sg/ci-clj-clr/actions/workflows/build-and-push.yml/badge.svg" alt="Build"></a>
    <a href="https://github.com/flybot-sg/ci-clj-clr/pkgs/container/ci-clj-clr"><img src="https://img.shields.io/badge/ghcr.io-ci--clj--clr-blue" alt="GHCR"></a>
    <img src="https://img.shields.io/badge/platform-amd64%20%7C%20arm64-lightgrey" alt="Platforms">
</div>

<br>

CI build image with JVM Clojure, Babashka, Mono, and [Nostrand](https://github.com/flybot-sg/magic) for running tests on both JVM and CLR.

```bash
docker pull ghcr.io/flybot-sg/ci-clj-clr:<version>
```

## What's inside

| Tool | Version | Purpose |
|------|---------|---------|
| Temurin JDK | 21 | JVM Clojure runtime |
| Clojure CLI | latest | Dependency management and REPL |
| Babashka | 1.12.216 | Task runner and scripting |
| Node.js | 24.x | shadow-cljs support |
| Mono | 6.x | Hosts Nostrand (net471 target) |
| Nostrand | pinned via `MAGIC_VERSION` ARG | [MAGIC](https://github.com/flybot-sg/magic) task runner, dep manager, and REPL |

> The image version is independent of the bundled MAGIC version (the image also tracks JDK / Clojure / Node / Mono / Babashka); each MAGIC release ships a new image. The exact MAGIC pin lives in the `MAGIC_VERSION` ARG in the `Dockerfile`, the single source of truth.

## Usage

Use as a CI base image for projects that need both JVM and CLR test runs:

```yaml
# GitHub Actions
container:
  image: ghcr.io/flybot-sg/ci-clj-clr:<version>
```

```yaml
# GitLab CI
image: ghcr.io/flybot-sg/ci-clj-clr:<version>
```

The image supports an optional `SSH_PRIVATE_KEY` environment variable. When set, the entrypoint loads it into `ssh-agent` so CI jobs can clone private git dependencies.

## Releasing

```bash
# 1. Bump version in version.edn
# 2. Commit
# 3. Tag and push — GitHub Actions builds and pushes to GHCR
bb tag
```
