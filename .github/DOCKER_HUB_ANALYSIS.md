# Docker Hub 依赖分析：参考项目 vs 我们的项目

## 问题

用户观察到：
- **参考项目**：本地构建时不会用到 `docker.io`（Docker Hub）
- **我们的项目**：本地构建时会依赖 Docker Hub（可能超时）

## 基础镜像对比

### 参考项目（addon-ssh, addon-wireguard）

```yaml
# build.yaml
build_from:
  aarch64: ghcr.io/hassio-addons/base:18.2.1
  amd64: ghcr.io/hassio-addons/base:18.2.1
  armv7: ghcr.io/hassio-addons/base:18.2.1
```

- ✅ 所有基础镜像来自 **GHCR**（GitHub Container Registry）
- ✅ 不依赖 Docker Hub

### 我们的项目

```yaml
# build.yaml
build_from:
  aarch64: ghcr.io/hassio-addons/base:18.2.1
  amd64: ghcr.io/hassio-addons/base:18.2.1
  armv7: ghcr.io/hassio-addons/base:18.2.1
```

- ✅ 所有基础镜像也来自 **GHCR**
- ✅ 理论上也不应该依赖 Docker Hub

## Dockerfile 依赖对比

### 参考项目（addon-ssh）

```dockerfile
FROM ghcr.io/hassio-addons/base:18.2.1

RUN \
    apk add --no-cache \
        docker=28.3.3-r3 \
        ...
```

- ✅ 通过 `apk add` 从 **Alpine 仓库**安装依赖
- ✅ `docker` 包来自 Alpine 仓库，不是 Docker Hub 镜像
- ✅ 不依赖 Docker Hub

### 我们的项目

```dockerfile
FROM ghcr.io/hassio-addons/base:18.2.1

RUN \
    apk add --no-cache --virtual .build-dependencies \
        wget \
        curl \
    ...
```

- ✅ 通过 `apk add` 从 **Alpine 仓库**安装依赖
- ✅ 不依赖 Docker Hub

## 为什么会有 Docker Hub 依赖？

### 核心问题

**参考项目（官方 addon）**：
- 没有 `image` 字段，使用本地构建
- 但在 Home Assistant 的**内部构建系统**中构建
- 该构建系统有**内部的镜像源配置**，不依赖 Docker Hub

**我们的项目（第三方 addon）**：
- 即使去除 `image` 字段，使用本地构建
- 但在**用户的本地环境**中构建
- 用户的 Docker 环境可能没有配置镜像加速，所以会尝试从 Docker Hub 拉取

### 关键差异

| 项目类型 | 构建环境 | 镜像源配置 | Docker Hub 依赖 |
|---------|---------|-----------|----------------|
| **官方 addon** | Home Assistant 内部构建系统 | 内部配置（GHCR、内部镜像仓库） | ❌ 不依赖 |
| **第三方 addon** | 用户本地环境 | 用户 Docker 配置 | ✅ 可能依赖 |

### 可能的原因

1. **构建环境差异**
   - 官方 addon 在 Home Assistant 的云端构建系统中构建
   - 该构建系统有预配置的镜像源（GHCR、内部镜像仓库等）
   - 第三方 addon 在用户的本地环境中构建，依赖用户的 Docker 配置

2. **Docker 守护进程配置**
   - 用户本地 Docker 环境可能没有配置 GHCR 镜像加速
   - 或者 Docker 客户端默认从 Docker Hub 拉取
   - 可能会尝试从 Docker Hub 拉取基础镜像（即使配置了 GHCR）

3. **Home Assistant 构建系统行为**
   - 官方 addon 可能有特殊的构建流程和配置
   - 第三方 addon 可能没有这些特殊处理

4. **网络配置问题**
   - 如果 GHCR 访问受限，Docker 可能会尝试从 Docker Hub 拉取
   - 或者 DNS 解析问题导致 GHCR 无法访问

## 用户之前遇到的错误

```
Client.Timeout exceeded while awaiting headers
docker.io/library/docker:28.3.3-cli
```

这个错误显示尝试从 Docker Hub 拉取 `docker:28.3.3-cli`。

但我们的 Dockerfile 中：
- ✅ 没有直接拉取 `docker:28.3.3-cli` 镜像
- ✅ 基础镜像来自 GHCR
- ✅ 依赖通过 `apk add` 安装

**可能的原因**：
- Home Assistant 的构建系统在尝试拉取某些依赖
- 或者 Docker 守护进程的配置问题
- 或者某些中间层依赖需要从 Docker Hub 拉取

## 解决方案

### 1. 配置 Docker 镜像加速器

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

### 2. 确保 GHCR 访问正常

```bash
# 测试 GHCR 访问
docker pull ghcr.io/hassio-addons/base:18.2.1
```

### 3. 检查 Docker 配置

```bash
# 检查 Docker 配置
cat /etc/docker/daemon.json
```

### 4. 使用预构建镜像

- 我们的项目使用预构建镜像（有 `image` 字段）
- 安装时直接拉取预构建镜像，不需要本地构建
- 这样可以避免本地构建时的 Docker Hub 依赖问题

## 总结

**参考项目和我们的项目在配置文件上是相同的**：
- ✅ 都使用 GHCR 作为基础镜像源
- ✅ 都通过 Alpine 仓库安装依赖
- ✅ 理论上都不应该依赖 Docker Hub

**但实际使用中的关键差异**：
1. **构建环境不同**
   - 官方 addon：在 Home Assistant 内部构建系统中构建（有内部镜像源配置）
   - 第三方 addon：在用户本地环境中构建（依赖用户 Docker 配置）

2. **镜像源配置不同**
   - 官方 addon：构建系统有预配置的镜像源，不依赖 Docker Hub
   - 第三方 addon：依赖用户的 Docker 配置，可能没有镜像加速

3. **网络环境不同**
   - 官方 addon：构建系统可能有优化的网络配置
   - 第三方 addon：依赖用户的网络环境

**解决方案**：
1. **使用预构建镜像**（推荐）
   - 保持 `image` 字段
   - 安装时直接拉取预构建镜像，避免本地构建
   - 不依赖用户的 Docker 配置

2. **配置 Docker 镜像加速器**（如果必须本地构建）
   - 配置国内镜像加速器（中科大、网易等）
   - 确保 GHCR 访问正常
   - 详见 `TROUBLESHOOTING.md`

3. **理解差异**
   - 官方 addon 和第三方 addon 的构建环境不同
   - 这是正常的，不是配置错误
   - 使用预构建镜像可以避免这个问题

