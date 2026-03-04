# SecDevOps Pipeline Base Image

> 供地端 GitLab CI Pipeline 使用的基礎 Docker Image，避免每次 Pipeline 重複安裝套件。

## 包含工具

| 工具 | 版本 |
|------|------|
| git / curl / jq / zip | 系統最新 |
| python3 + pip | 3.10+ |
| psycopg2-binary | 最新 |
| pyyaml | 最新 |
| requests | 最新 |

## 快速開始

### 1. Fork / 建立新 GitHub Repo

將本目錄的內容複製到一個**公開** GitHub Repository：

```
github.com/<YOUR_USERNAME>/secdevops-base-image
├── Dockerfile
└── .github/
    └── workflows/
        └── build-push.yml
```

### 2. 設為 Public 並允許 Packages

GitHub Repository → **Settings → Actions → General**
→ Workflow permissions → **Read and write permissions** ✅

### 3. 觸發首次 Build

```bash
git push origin main
```

或至 GitHub → **Actions → Build & Push Base Image → Run workflow**

Build 完成後 image 位置：

```
ghcr.io/chihualu/secdevops-base-image:latest
```

### 4. 設為 Public Package

GitHub → **Packages → secdevops-base-image → Package settings → Change visibility → Public**

### 5. 更新地端 GitLab Pipeline

在 GitLab Pipeline 所在 Repo 設定 CI/CD Variable：

| Variable | Value |
|----------|-------|
| `SECDEVOPS_BASE_IMAGE` | `ghcr.io/<YOUR_USERNAME>/secdevops-base-image:latest` |

或直接修改 `templates/gitlab-ci-template.yml` 第一行 `default.image`。

## 更新頻率

- **自動**：每月 1 日重建（更新 base packages）
- **手動**：修改 `Dockerfile` 並 push 即觸發重建

## 目錄結構

```
docker/base-image/
├── Dockerfile                        # Base image 定義
├── README.md                         # 本文件
└── .github/
    └── workflows/
        └── build-push.yml            # GitHub Actions 自動 build/push
```
