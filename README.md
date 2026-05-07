# Railway Vless 部署

基于 Xray 的 Vless 代理服务，支持 WS/XHTTP/REALITY 三种传输协议。

## 部署

### 1. 创建 Railway 项目

```bash
# 安装 Railway CLI
npm install -g @railway/cli

# 登录
railway login

# 初始化项目
railway init
```

### 2. 配置环境变量

在 Railway 项目设置中添加：

```bash
UUID=your-uuid-here  # 可选，默认全零
SNI=railway.com      # 可选，REALITY SNI 域名，默认 railway.com
```

### 3. 配置 TCP Proxy

1. 进入 Service Settings → Networking
2. 点击 TCP Proxy
3. 输入端口：`8443`
4. Railway 会生成 TCP 域名和端口

### 4. 部署

```bash
railway up
```

## 使用

### 订阅地址

```
https://your-app.railway.app/sub
```

### 返回链接

- **WS**: `vless://...@your-app.railway.app:443?type=ws&path=/ws&security=tls`
- **XHTTP**: `vless://...@your-app.railway.app:443?type=xhttp&path=/xhttp&security=tls`
- **REALITY**: `vless://...@xxx.proxy.rlwy.net:xxxxx?type=tcp&security=reality&...`

## 注意事项

1. **TCP 端口随机**：每次部署 TCP 端口可能变化，需重新获取订阅
2. **REALITY 密钥**：每次启动重新生成，订阅链接会变化
3. **推荐使用 WS/XHTTP**：固定域名，链接稳定

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `UUID` | 用户 UUID | `00000000-0000-0000-0000-000000000000` |
| `SNI` | REALITY SNI 域名 | `railway.com` |
| `RAILWAY_PUBLIC_DOMAIN` | HTTP 域名（自动） | - |
| `RAILWAY_TCP_PROXY_DOMAIN` | TCP 域名（自动） | - |
| `RAILWAY_TCP_PROXY_PORT` | TCP 端口（自动） | - |
