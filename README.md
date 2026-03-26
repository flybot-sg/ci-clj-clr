# ci-clj-clr

CI build image with JVM Clojure, Babashka, Mono, and [Nostrand](https://github.com/nasser/nostrand) for running tests on both JVM and CLR.

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
| Nostrand | latest | [MAGIC](https://github.com/nasser/magic) task runner, dep manager, and REPL |

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

## Platforms

Multi-arch: `linux/amd64` and `linux/arm64`.

## Releasing

```bash
# 1. Bump version in version.edn
# 2. Commit
# 3. Tag and push — GitHub Actions builds and pushes to GHCR
bb tag
```

## License

Copyright 2024 Flybot Pte. Ltd. (风林火山)
