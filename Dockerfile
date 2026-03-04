FROM ubuntu:22.04

LABEL org.opencontainers.image.description="SecDevOps Pipeline Base Image"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

ENV DEBIAN_FRONTEND=noninteractive

# ─── 基本工具 ───────────────────────────────────────────
RUN apt-get update -qq && \
    apt-get install -y -qq \
      git curl wget jq zip unzip ca-certificates gnupg apt-transport-https \
      python3 python3-pip \
      libxml2-utils \
    && rm -rf /var/lib/apt/lists/*

# ─── Eclipse Temurin JDK 8 / 11 / 17 / 21 ─────────────
# 使用 Adoptium 官方 APT repo
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
      | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] \
      https://packages.adoptium.net/artifactory/deb jammy main" \
      > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update -qq && \
    apt-get install -y -qq \
      temurin-8-jdk \
      temurin-11-jdk \
      temurin-17-jdk \
      temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# ─── Maven 3.9（與所有 JDK 相容）────────────────────────
ARG MAVEN_VERSION=3.9.9
RUN wget -qO /tmp/maven.tar.gz \
      "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/mvn && \
    rm /tmp/maven.tar.gz

ENV MAVEN_HOME=/opt/maven

# ─── 預設 JDK 17（可在 script 執行時切換）────────────────
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ─── 安全掃描工具 ─────────────────────────────────────────
# Trivy（黑箱掃描）
RUN wget -qO /tmp/trivy.deb \
      "https://github.com/aquasecurity/trivy/releases/download/v0.69.3/trivy_0.69.3_Linux-64bit.deb" && \
    dpkg -i /tmp/trivy.deb && rm /tmp/trivy.deb

# Gitleaks（Secret 掃描）
ARG GITLEAKS_VERSION=8.30.0
RUN wget -qO /tmp/gitleaks.tar.gz \
      "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" && \
    tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks && \
    rm /tmp/gitleaks.tar.gz

# Semgrep（白箱補充掃描）
RUN pip3 install --no-cache-dir semgrep==1.153.1

# OSV-Scanner（黑箱掃描）
ARG OSV_VERSION=2.3.3
RUN wget -qO /usr/local/bin/osv-scanner \
      "https://github.com/google/osv-scanner/releases/download/v${OSV_VERSION}/osv-scanner_linux_amd64" && \
    chmod +x /usr/local/bin/osv-scanner

# OWASP Dependency-Check（黑箱掃描）
ARG DC_VERSION=12.2.0
RUN wget -qO /tmp/dependency-check.zip \
      "https://github.com/dependency-check/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip" && \
    unzip -q /tmp/dependency-check.zip -d /opt && \
    ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check && \
    rm /tmp/dependency-check.zip

# ─── pip 工具 ────────────────────────────────────────────
RUN pip3 install --no-cache-dir \
    psycopg2-binary \
    pyyaml \
    requests

# ─── 共用設定 ─────────────────────────────────────────────
RUN git config --global --add safe.directory '*'

# ─── switch-java helper（供 pipeline script 使用）─────────
COPY switch-java.sh /usr/local/bin/switch-java.sh
RUN chmod +x /usr/local/bin/switch-java.sh

