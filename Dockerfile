FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/flybot-sg/ci-clj-clr"
LABEL org.opencontainers.image.description="CI build image with JVM Clojure, Babashka, Mono, and Nostrand for running tests on both JVM and CLR"
LABEL org.opencontainers.image.licenses="MIT"

# --- System packages + Temurin JDK 21 ---
# mono-devel hosts Nostrand (net471 .NET Framework target). mono-devel
# (not mono-runtime) is required because Nostrand's net471 assemblies
# reference netstandard 2.0 facade assemblies, which only mono-devel ships.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl git gpg openssh-client rlwrap unzip \
      mono-devel && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
      | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" \
      > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends temurin-21-jdk && \
    java -version && \
    rm -rf /var/lib/apt/lists/*

# --- Clojure CLI ---
RUN curl -fsSL https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
      -o /tmp/linux-install.sh && \
    chmod +x /tmp/linux-install.sh && \
    /tmp/linux-install.sh && \
    rm -f /tmp/linux-install.sh && \
    clojure -version

# --- Babashka ---
ARG BB_VERSION=1.12.216
RUN ARCH=$(dpkg --print-architecture) && \
    case ${ARCH} in \
      amd64) BB_ARCH="amd64" ;; \
      arm64) BB_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/babashka/babashka/releases/download/v${BB_VERSION}/babashka-${BB_VERSION}-linux-${BB_ARCH}-static.tar.gz" \
      -o /tmp/babashka.tar.gz && \
    tar -zxf /tmp/babashka.tar.gz -C /usr/local/bin bb && \
    rm -f /tmp/babashka.tar.gz && \
    bb --version

# --- Node.js 24 (for shadow-cljs support in dependent projects) ---
RUN curl -fsSL https://deb.nodesource.com/setup_24.x -o /tmp/nodesource-setup.sh && \
    bash /tmp/nodesource-setup.sh && \
    rm -f /tmp/nodesource-setup.sh && \
    apt-get install -y --no-install-recommends nodejs && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/* && \
    node --version && npm --version

# --- Nostrand (MAGIC task runner / dependency manager) ---
# Installed from the flybot-sg/magic release tarball.
ARG MAGIC_VERSION=v0.1.0
RUN curl -fsSL "https://raw.githubusercontent.com/flybot-sg/magic/main/install/nos.sh" \
      | MAGIC_VERSION="${MAGIC_VERSION}" \
        INSTALL_DIR=/opt/nostrand \
        INSTALL_LINK=/usr/local/bin/nos \
        bash

# --- SSH config for CI jobs that clone private deps via SSH_PRIVATE_KEY ---
COPY .ssh/config /root/.ssh/config
RUN chmod 700 /root/.ssh && \
    chmod 644 /root/.ssh/config

COPY entry-point.sh /entry-point.sh
RUN chmod +x /entry-point.sh

ENTRYPOINT ["/entry-point.sh"]
CMD ["/bin/bash"]
