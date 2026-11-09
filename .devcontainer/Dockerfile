FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

USER root

COPY scripts/ /opt/cloudpc/scripts/
COPY config/ /opt/cloudpc/config/

RUN bash /opt/cloudpc/scripts/setup-desktop.sh --packages-only \
    && rm -rf /var/lib/apt/lists/*

USER vscode
