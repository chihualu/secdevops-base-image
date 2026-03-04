#!/usr/bin/env bash
# =============================================================
# switch-java.sh — 執行時切換 JDK 版本
# 用法：source /usr/local/bin/switch-java.sh <version>
#   version: 8 | 11 | 17 | 21（預設 17）
#
# 範例：
#   source switch-java.sh 21
#   java -version  # → openjdk 21
# =============================================================

_switch_java() {
  local version="${1:-17}"

  # 正規化：1.8 → 8
  version="${version#1.}"

  local jvm_dir
  jvm_dir=$(ls -d /usr/lib/jvm/temurin-${version}-jdk-* 2>/dev/null | head -1)

  if [[ -z "${jvm_dir}" ]]; then
    echo "[switch-java] ERROR: 找不到 JDK ${version}（/usr/lib/jvm/temurin-${version}-jdk-*）" >&2
    echo "[switch-java] 可用版本：$(ls /usr/lib/jvm/ | grep temurin | sed 's/temurin-//;s/-jdk-.*//' | sort -u | tr '\n' ' ')" >&2
    return 1
  fi

  export JAVA_HOME="${jvm_dir}"
  export PATH="${JAVA_HOME}/bin:$(echo $PATH | sed "s|[^:]*temurin[^:]*:||g")"

  echo "[switch-java] JDK 已切換為 ${version}（${JAVA_HOME}）"
  java -version 2>&1 | head -1 >&2
}

_switch_java "${1:-17}"
