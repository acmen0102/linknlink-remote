# 仓库添加故障排除

## SSL 连接错误

如果遇到类似以下错误：
```
fatal: unable to access 'https://github.com/...': OpenSSL SSL_read: OpenSSL/3.5.4: error:0A000126:SSL routines: unexpected eof while reading
```

这是 SSL/TLS 连接问题，不是仓库配置问题。

## 解决方案

### 方案 1：重试
- 可能是临时性的网络问题
- 等待几分钟后重试
- 检查 GitHub 状态：https://www.githubstatus.com/

### 方案 2：检查网络连接
在 Home Assistant 服务器上测试连接：

```bash
# SSH 到 Home Assistant 服务器后执行
curl -I https://github.com/Acmen0102/linknlink-remote

# 测试 Git 克隆
git clone --depth=1 https://github.com/Acmen0102/linknlink-remote /tmp/test-repo
```

### 方案 3：使用不同的 URL 格式
尝试使用 `.git` 后缀：
```
https://github.com/Acmen0102/linknlink-remote.git
```

### 方案 4：重启 Supervisor
在 Home Assistant 中：
1. 进入 **Supervisor** → **系统**
2. 点击 **重新启动 Supervisor**

### 方案 5：检查代理设置
如果 Home Assistant 服务器使用代理：
- 确保代理可以访问 GitHub
- 检查代理的 SSL 证书配置

### 方案 6：更新 Home Assistant
确保 Home Assistant 和 Supervisor 都是最新版本：
1. 进入 **Supervisor** → **系统**
2. 检查更新并安装

## 仓库 URL 验证

当前仓库 URL：`https://github.com/Acmen0102/linknlink-remote`

确认：
- ✅ 仓库是公开的
- ✅ URL 格式正确
- ✅ `repository.json` 文件格式正确

## 如果问题持续存在

1. 检查 Home Assistant 日志：
   - **Supervisor** → **系统** → **日志**
   - 查找更详细的错误信息

2. 在 GitHub 上确认仓库：
   - 访问：https://github.com/Acmen0102/linknlink-remote
   - 确认仓库存在且为公开

3. 尝试从其他网络环境添加仓库

4. 查看 Home Assistant 社区论坛或创建 Issue
