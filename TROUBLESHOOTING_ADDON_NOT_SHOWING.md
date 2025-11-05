# Add-on 在商店中不显示的故障排除

## 问题：添加仓库后，在加载项商店找不到 Add-on

### 可能的原因和解决方案

#### 1. 镜像还未构建完成（最常见，如果使用预构建镜像）

**问题：** 如果您的 Add-on 使用预构建镜像（`image` 字段），镜像必须先在 GitHub Container Registry 中构建完成。

**检查方法：**
1. 访问 GitHub Actions：https://github.com/acmen0102/linknlink-remote/actions
2. 确认 `build-and-push.yml` 工作流已成功完成
3. 检查镜像是否存在：https://github.com/acmen0102/linknlink-remote/pkgs/container/linknlink-remote-frpc
4. 确认有您系统架构的镜像（aarch64, amd64, 或 armv7）

**解决方案：**
- 等待 GitHub Actions 构建完成（通常需要 10-20 分钟）
- 如果构建失败，检查构建日志并修复问题
- 构建完成后，在 Home Assistant 中刷新仓库

#### 2. Home Assistant 需要刷新仓库

**解决方案：**
1. 在 Home Assistant Web 界面
2. 进入 **Supervisor** → **系统**
3. 点击 **重新加载 Supervisor**
4. 等待几秒钟
5. 返回 **加载项商店**，应该能看到 Add-on

**或者：**
1. 删除仓库（在仓库管理界面点击垃圾桶图标）
2. 重新添加仓库
3. 等待同步完成

#### 3. 检查 Supervisor 日志

**步骤：**
1. 在 Home Assistant Web 界面
2. 进入 **Supervisor** → **系统** → **日志**
3. 查找与仓库相关的错误信息
4. 常见错误：
   - 无法访问仓库 URL
   - 无法解析 repository.json
   - 无法访问镜像
   - 架构不匹配

#### 4. 验证仓库结构

**检查清单：**
- [ ] `repository.json` 在仓库根目录
- [ ] `frpc/config.json` 存在
- [ ] `frpc/Dockerfile` 存在（如果使用本地构建）
- [ ] `frpc/run.sh` 存在

**验证命令（在仓库中）：**
```bash
# 检查文件结构
ls -la repository.json
ls -la frpc/config.json
ls -la frpc/Dockerfile
ls -la frpc/run.sh

# 验证 JSON 格式
python3 -m json.tool repository.json
python3 -m json.tool frpc/config.json
```

#### 5. 检查架构匹配

**问题：** Add-on 的架构列表必须包含您系统的架构。

**检查方法：**
1. 在 Home Assistant 中查看系统架构：
   - **Supervisor** → **系统** → **硬件**
   - 查看 "架构" 信息
2. 检查 `frpc/config.json` 中的 `arch` 字段：
   ```json
   "arch": ["aarch64", "amd64", "armv7"]
   ```
3. 确保您的系统架构在列表中

#### 6. 检查网络连接

**问题：** Home Assistant 无法访问 GitHub 或镜像仓库。

**检查方法：**
1. 在 Home Assistant 系统中测试网络连接
2. 检查是否能访问：
   - https://github.com/acmen0102/linknlink-remote
   - https://ghcr.io

#### 7. 使用预构建镜像时的特殊要求

**如果使用预构建镜像（`image` 字段）：**
- 镜像必须在 GitHub Container Registry 中存在
- 镜像必须包含您系统架构的版本
- 镜像标签格式必须正确：`{arch}` 会被替换为实际架构

**检查镜像是否存在：**
```bash
# 在 Home Assistant 系统中（如果有 Docker 访问权限）
docker pull ghcr.io/acmen0102/linknlink-remote-frpc:amd64
# 或
docker pull ghcr.io/acmen0102/linknlink-remote-frpc:aarch64
# 或
docker pull ghcr.io/acmen0102/linknlink-remote-frpc:armv7
```

### 快速诊断步骤

1. **检查 GitHub Actions**
   - 访问：https://github.com/acmen0102/linknlink-remote/actions
   - 确认构建工作流已成功完成

2. **检查镜像**
   - 访问：https://github.com/acmen0102/linknlink-remote/pkgs/container/linknlink-remote-frpc
   - 确认镜像存在

3. **刷新 Home Assistant**
   - Supervisor → 系统 → 重新加载 Supervisor

4. **检查日志**
   - Supervisor → 系统 → 日志
   - 查找错误信息

5. **重新添加仓库**
   - 删除现有仓库
   - 重新添加：https://github.com/acmen0102/linknlink-remote

### 如果仍然无法解决

1. **检查仓库是否公开**
   - 确保 GitHub 仓库是公开的（Public）
   - 或者确保 Home Assistant 有访问权限

2. **检查 URL 是否正确**
   - 仓库 URL：https://github.com/acmen0102/linknlink-remote
   - 确保没有拼写错误

3. **查看 Home Assistant 社区论坛**
   - https://community.home-assistant.io/
   - 搜索相关问题或提问

4. **提交 Issue**
   - 在 GitHub 仓库中提交 Issue
   - 提供详细的错误信息和日志
