# A small, disposable Debian box for Module 5 — APIs, contracts & the
# client/server boundary. Runs a deliberately-flawed orders API (Python stdlib)
# on :8080 plus a demo websocket on :8081, and the guided `lesson` runner. You
# harden the server by editing files in a mounted ~/workspace folder.
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils procps grep less vim curl jq ca-certificates \
        python3 python3-yaml python3-websockets \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dev

COPY lesson/ /opt/lesson/
COPY app/    /opt/app/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN ln -sf /opt/lesson/run.sh /usr/local/bin/lesson \
    && chmod +x /opt/lesson/run.sh /usr/local/bin/entrypoint.sh

RUN printf '\n# Module 5 sandbox greeting\nif [ -z "${LESSON_BANNER_SHOWN:-}" ]; then\n  export LESSON_BANNER_SHOWN=1\n  lesson welcome\nfi\n' >> /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc

EXPOSE 8080 8081
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
