# Module 5 — APIs, contracts & the client/server boundary.
# A disposable Debian box with Python3 + websocat + the `lesson` runner.
# The orders API reference server is baked in (read-only). Handler code lives
# in the mounted workspace/ (host-side, persists across container restarts).
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils procps grep less vim curl jq python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# websocat — tiny WebSocket client for the real-time tasks.
# Download a prebuilt static binary (no .deb package in this release).
RUN curl -sL "https://github.com/vi/websocat/releases/download/v1.13.0/websocat.x86_64-unknown-linux-musl" \
        -o /usr/local/bin/websocat \
    && chmod 755 /usr/local/bin/websocat \
    && websocat --version

RUN useradd -m -s /bin/bash dev

# Lesson engine baked in.
COPY lesson/ /opt/lesson/
# Reference server baked in (read-only — learner edits handlers in workspace).
COPY server/ /opt/server/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN ln -sf /opt/lesson/run.sh /usr/local/bin/lesson \
    && chmod +x /opt/lesson/run.sh /usr/local/bin/entrypoint.sh

RUN printf '\n# Module 5 sandbox greeting\nif [ -z "${LESSON_BANNER_SHOWN:-}" ]; then\n  export LESSON_BANNER_SHOWN=1\n  lesson welcome\nfi\n' >> /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
