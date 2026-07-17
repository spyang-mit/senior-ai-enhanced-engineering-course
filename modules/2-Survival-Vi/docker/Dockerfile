# A small, disposable Debian box for Module 2 — Survival vi.
# Real vim, a throwaway home, and the guided `lesson` runner.
FROM debian:stable-slim

# vim (full, not vim-tiny) plus the everyday tools. Make `vi` resolve to vim.
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils procps grep less vim ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/vi vi /usr/bin/vim 60

# The learner account.
RUN useradd -m -s /bin/bash dev

# Lesson engine baked in; entrypoint prepares a fresh playground each run.
COPY lesson/ /opt/lesson/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=dev:dev docker/vimrc /home/dev/.vimrc
RUN ln -sf /opt/lesson/run.sh /usr/local/bin/lesson \
    && chmod +x /opt/lesson/run.sh /usr/local/bin/entrypoint.sh

# Default editor is vim (as it will be for git in Module 3), and show the
# welcome banner once per sandbox shell.
RUN printf '\n# Module 2 sandbox\nexport EDITOR=vim\nif [ -z "${LESSON_BANNER_SHOWN:-}" ]; then\n  export LESSON_BANNER_SHOWN=1\n  lesson welcome\nfi\n' >> /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
