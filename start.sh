#!/bin/bash
set -e

# 读取环境变量
UUID=${UUID:-00000000-0000-0000-0000-000000000000}
SNI=${SNI:-modal.com}

echo "[Railway] Starting Vless service..."
echo "[Railway] UUID: $UUID"
echo "[Railway] SNI: $SNI"
echo "[Railway] HTTP Domain: $RAILWAY_PUBLIC_DOMAIN"
echo "[Railway] TCP Domain: $RAILWAY_TCP_PROXY_DOMAIN"
echo "[Railway] TCP Port: $RAILWAY_TCP_PROXY_PORT"

# 生成 REALITY 密钥
echo "[Railway] Generating REALITY keys..."
PRIVATE_KEY=$(/usr/local/bin/xray x25519 | grep "Private key:" | awk '{print $3}')
PUBLIC_KEY=$(/usr/local/bin/xray x25519 -i "$PRIVATE_KEY" | grep "Public key:" | awk '{print $3}')

echo "[Railway] Private key: $PRIVATE_KEY"
echo "[Railway] Public key: $PUBLIC_KEY"

# 保存公钥供 API 使用
echo "$PUBLIC_KEY" > /tmp/reality_public_key

# 生成 xray 配置
cat > /tmp/xray.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "port": 10000,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {"path": "/ws"}
      }
    },
    {
      "port": 10001,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {"path": "/xhttp", "mode": "auto"}
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$SNI:443",
          "xver": 0,
          "serverNames": ["$SNI"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": [""]
        }
      }
    }
  ],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

echo "[Railway] Starting services..."

# 启动 xray
/usr/local/bin/xray run -c /tmp/xray.json &

# 启动订阅 API
python3 /sub_api.py &

# 启动 nginx（前台运行）
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf
