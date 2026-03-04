FROM ubuntu:22.04

LABEL org.opencontainers.image.description="SecDevOps Pipeline Base Image"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y -qq \
      # 基本工具
      git curl jq zip unzip ca-certificates gnupg \
      # Python
      python3 python3-pip \
      # XML/YAML 處理
      libxml2-utils \
    && rm -rf /var/lib/apt/lists/*

# pip 工具
RUN pip3 install --no-cache-dir \
    psycopg2-binary \
    pyyaml \
    requests

RUN git config --global --add safe.directory '*'
