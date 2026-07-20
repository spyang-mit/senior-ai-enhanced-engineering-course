# A small, disposable Debian box for Module 4 — the web & frontend.
# Runs a local contacts API + demo app (Python stdlib) and the guided `lesson`
# runner. The API is exposed on :8080 so you can curl it here and open it in
# your real browser's DevTools.
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils procps grep less vim curl jq python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dev

COPY lesson/ /opt/lesson/
COPY app/    /opt/app/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN ln -sf /opt/lesson/run.sh /usr/local/bin/lesson \
    && chmod +x /opt/lesson/run.sh /usr/local/bin/entrypoint.sh

RUN printf '\n# Module 4 sandbox greeting\nif [ -z "${LESSON_BANNER_SHOWN:-}" ]; then\n  export LESSON_BANNER_SHOWN=1\n  lesson welcome\nfi\n' >> /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
