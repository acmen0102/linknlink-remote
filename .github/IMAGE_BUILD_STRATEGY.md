# 镜像构建策略：官方 addon vs 第三方 addon

## 关键发现

### 官方 addon（addon-ssh）的实际情况

**在 Home Assistant 中使用的镜像**：
```
ghcr.io/hassio-addons/ssh/amd64:21.0.4
```

- ✅ 这是**预构建镜像**，存储在 GHCR 上
- ✅ 可以 `docker pull` 下来
- ✅ 虽然 `config.yaml` 中**没有 `image` 字段**，但 HA 会自动使用这个镜像

### 镜像名称格式

**官方 addon**：
- 格式：`ghcr.io/hassio-addons/{slug}/{arch}:{version}`
- 示例：`ghcr.io/hassio-addons/ssh/amd64:21.0.4`
- `config.yaml` 中**没有 `image` 字段**

**我们的项目（第三方 addon）**：
- 格式：`ghcr.io/{owner}/{image-name}:{arch}`
- 示例：`ghcr.io/acmen0102/linknlink-remote-frpc:aarch64`
- `config.yaml` 中**有 `image` 字段**

## 构建流程对比

### 官方 addon（addon-ssh）

1. **GitHub Actions 构建**：
   - `deploy.yaml` 使用官方可重用工作流
   - 自动构建多架构镜像
   - 推送到 `ghcr.io/hassio-addons/ssh/{arch}:{version}`

2. **Home Assistant 识别**：
   - HA 检测到是官方 addon（来自 `hassio-addons` 仓库）
   - 自动识别镜像名称格式
   - 即使 `config.yaml` 中没有 `image` 字段，也会使用预构建镜像

3. **安装流程**：
   - 用户安装 addon
   - HA 自动从 GHCR 拉取预构建镜像
   - 不需要本地构建

### 第三方 addon（我们的项目）

1. **GitHub Actions 构建**：
   - `build-and-push.yml` 自定义工作流
   - 构建多架构镜像
   - 推送到 `ghcr.io/acmen0102/linknlink-remote-frpc:{arch}`

2. **Home Assistant 识别**：
   - HA 检测到是第三方 addon
   - **需要 `config.yaml` 中有 `image` 字段**来指定镜像位置
   - 使用 `image` 字段指定的镜像

3. **安装流程**：
   - 用户安装 addon
   - HA 从 `image` 字段指定的位置拉取预构建镜像
   - 不需要本地构建

## 为什么会有这个差异？

### 官方 addon

- **优势**：
  - `config.yaml` 更简洁（没有 `image` 字段）
  - HA 自动识别镜像位置
  - 统一的镜像命名规范

- **限制**：
  - 必须使用 `ghcr.io/hassio-addons/` 命名空间
  - 必须符合官方 addon 的规范
  - 镜像名称格式固定

### 第三方 addon

- **优势**：
  - 可以自定义镜像名称和位置
  - 更灵活，可以使用自己的 GitHub 组织
  - 明确的镜像位置（通过 `image` 字段）

- **要求**：
  - 必须在 `config.yaml` 中指定 `image` 字段
  - 镜像名称需要符合规范

## 总结

### 关键结论

1. **官方 addon 和第三方 addon 都使用预构建镜像**
   - 都不是本地构建的
   - 都存储在 GHCR 上
   - 都可以 `docker pull` 下来

2. **区别在于镜像名称和配置方式**：
   - 官方 addon：`config.yaml` 中没有 `image` 字段，HA 自动识别
   - 第三方 addon：`config.yaml` 中有 `image` 字段，明确指定镜像位置

3. **为什么参考项目没有 `image` 字段？**
   - 因为它们是官方 addon
   - HA 会自动识别并使用预构建镜像
   - 镜像名称格式：`ghcr.io/hassio-addons/{slug}/{arch}:{version}`

4. **为什么我们的项目需要 `image` 字段？**
   - 因为我们是第三方 addon
   - HA 需要 `image` 字段来知道从哪里拉取镜像
   - 镜像名称格式：`ghcr.io/{owner}/{image-name}:{arch}`

### 关于 Docker Hub 依赖的问题

**为什么参考项目（官方 addon）本地构建时不依赖 Docker Hub？**

答案：**官方 addon 实际上不使用本地构建**！

- 官方 addon 在 HA 中安装时，直接使用预构建镜像（`ghcr.io/hassio-addons/ssh/amd64:21.0.4`）
- 不需要本地构建，所以不会遇到 Docker Hub 依赖问题
- 即使 `config.yaml` 中没有 `image` 字段，HA 也会自动使用预构建镜像

**为什么我们的项目本地构建时会依赖 Docker Hub？**

- 如果去除 `image` 字段，HA 会尝试本地构建
- 本地构建时，用户的 Docker 环境可能没有配置镜像加速
- 所以会尝试从 Docker Hub 拉取基础镜像

**解决方案**：
- 保持 `image` 字段，使用预构建镜像（推荐）
- 这样 HA 会直接拉取预构建镜像，不需要本地构建
- 避免 Docker Hub 依赖问题

## 参考

- 官方 addon 镜像示例：`ghcr.io/hassio-addons/ssh/amd64:21.0.4`
- 我们的项目镜像：`ghcr.io/acmen0102/linknlink-remote-frpc:aarch64`

