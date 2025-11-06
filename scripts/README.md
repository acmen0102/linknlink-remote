# 触发 Release Workflow 脚本

本目录包含用于触发 `repository_dispatch` 事件的脚本。

## 前置要求

1. **生成 GitHub Personal Access Token (PAT)**
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token" → "Generate new token (classic)"
   - 权限选择：`repo` 或 `workflow`
   - 复制生成的 token

2. **设置环境变量**
   ```bash
   export GITHUB_TOKEN="your_token_here"
   ```

## 使用方法

### 方法 1: 使用 Bash 脚本

```bash
# 设置 token
export GITHUB_TOKEN="your_token_here"

# 触发 release workflow
./scripts/trigger-release.sh 1.0.1
```

### 方法 2: 使用 Python 脚本

```bash
# 设置 token
export GITHUB_TOKEN="your_token_here"

# 触发 release workflow
python3 scripts/trigger-release.py 1.0.1
```

**注意**: Python 脚本需要 `requests` 库，如果没有安装：
```bash
pip install requests
```

### 方法 3: 一行命令（使用 curl）

```bash
export GITHUB_TOKEN="your_token_here"
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/acmen0102/linknlink-remote/dispatches \
  -d '{"event_type":"release","client_payload":{"version":"1.0.1"}}'
```

## 验证

触发成功后，访问以下链接查看 workflow 运行状态：
- https://github.com/acmen0102/linknlink-remote/actions

## 其他触发方式

除了使用脚本，还可以通过以下方式触发：

1. **GitHub Actions 页面手动触发** (`workflow_dispatch`)
   - 进入 Actions 页面
   - 选择 Release workflow
   - 点击 "Run workflow"
   - 输入版本号

2. **创建 GitHub Release** (`release`)
   - 进入 Releases 页面
   - 创建新 Release
   - 输入 Tag（例如：`v1.0.1`）
   - 发布

更多详细信息请查看：[docs/trigger-release.md](../docs/trigger-release.md)

