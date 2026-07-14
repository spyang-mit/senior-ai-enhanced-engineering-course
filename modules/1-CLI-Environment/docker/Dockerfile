# A small, disposable Debian box for Module 1. Real bash, real permissions,
# a real ssh server — everything the lesson teaches actually happens here.
FROM debian:stable-slim

# Tools the lesson uses. openssh-server gives us a genuine ssh/scp target
# (backup@localhost); the rest are the everyday coreutils/tar/grep/less.
# The Debian slim image strips man pages via a dpkg exclude, so we remove that
# exclude and reinstall coreutils — otherwise the `man ls` task has no manual.
RUN rm -f /etc/dpkg/dpkg.cfg.d/docker* \
    && apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils procps grep gzip tar less nano man-db manpages \
        openssh-server openssh-client ca-certificates \
    && apt-get install -y --reinstall --no-install-recommends coreutils \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# Two accounts: 'dev' is the learner; 'backup' is the scp/ssh destination.
# The 'teammates' group makes the chgrp task a real, hands-on operation.
# NOTE: Debian already ships a system user named 'backup', so we repurpose it
# (real home + shell) rather than create it, and it stays our scp/ssh target.
RUN useradd -m -s /bin/bash dev \
    && usermod -d /home/backup -m -s /bin/bash backup \
    && groupadd teammates \
    && usermod -aG teammates dev

# Lesson engine + seed content baked into the image. The entrypoint copies the
# playground fresh into the learner's home on every run, so it's disposable.
COPY lesson/       /opt/lesson/
COPY playground/   /opt/playground-seed/
COPY oldlogs-src/  /opt/oldlogs-src/
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# `lesson` is the guided runner, on PATH for the learner.
RUN ln -sf /opt/lesson/run.sh /usr/local/bin/lesson \
    && chmod +x /opt/lesson/run.sh /usr/local/bin/entrypoint.sh

# Flush each command to ~/.bash_history immediately, so `lesson check` can tell
# which commands the learner has run this session (used by the `man` task).
# Then show the welcome banner once per sandbox shell.
RUN printf '\n# Module 1 sandbox: record history as we go\nshopt -s histappend\nPROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-}"\n' >> /home/dev/.bashrc \
    && printf '\n# Module 1 sandbox greeting\nif [ -z "${LESSON_BANNER_SHOWN:-}" ]; then\n  export LESSON_BANNER_SHOWN=1\n  lesson welcome\nfi\n' >> /home/dev/.bashrc \
    && chown dev:dev /home/dev/.bashrc

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
