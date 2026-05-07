#!/usr/bin/env python3
"""Railway Vless 订阅 API"""
import os
import base64
from flask import Flask, Response

app = Flask(__name__)

# 读取配置
UUID = os.environ.get('UUID', '00000000-0000-0000-0000-000000000000')
SNI = os.environ.get('SNI', 'railway.com')
HTTP_DOMAIN = os.environ.get('RAILWAY_PUBLIC_DOMAIN', 'localhost')
TCP_DOMAIN = os.environ.get('RAILWAY_TCP_PROXY_DOMAIN')
TCP_PORT = os.environ.get('RAILWAY_TCP_PROXY_PORT')

# 读取 REALITY 公钥
try:
    with open('/tmp/reality_public_key') as f:
        PUBLIC_KEY = f.read().strip()
except FileNotFoundError:
    PUBLIC_KEY = None

@app.route('/')
def subscription():
    """返回订阅链接"""
    links = []
    
    # 调试信息
    print(f"[API] HTTP_DOMAIN: {HTTP_DOMAIN}")
    print(f"[API] TCP_DOMAIN: {TCP_DOMAIN}")
    print(f"[API] TCP_PORT: {TCP_PORT}")
    print(f"[API] PUBLIC_KEY exists: {PUBLIC_KEY is not None}")
    
    # WS 链接
    ws_link = f"vless://{UUID}@{HTTP_DOMAIN}:443?type=ws&path=/ws&security=tls#{HTTP_DOMAIN}-WS"
    links.append(ws_link)
    
    # XHTTP 链接
    xhttp_link = f"vless://{UUID}@{HTTP_DOMAIN}:443?type=xhttp&mode=packet-up&path=/xhttp&security=tls#{HTTP_DOMAIN}-XHTTP"
    links.append(xhttp_link)
    
    # REALITY 链接（如果 TCP Proxy 已配置）
    if TCP_DOMAIN and TCP_PORT and PUBLIC_KEY:
        reality_link = f"vless://{UUID}@{TCP_DOMAIN}:{TCP_PORT}?type=tcp&security=reality&pbk={PUBLIC_KEY}&sni={SNI}&sid=&flow=xtls-rprx-vision&encryption=none#{TCP_DOMAIN}-REALITY"
        links.append(reality_link)
        print(f"[API] REALITY link added")
    else:
        print(f"[API] REALITY link skipped (TCP_DOMAIN={TCP_DOMAIN}, TCP_PORT={TCP_PORT}, PUBLIC_KEY={PUBLIC_KEY is not None})")
    
    # 返回订阅
    content = '\n'.join(links) + '\n'
    
    # Base64 编码（可选）
    if 'base64' in os.environ.get('SUB_FORMAT', ''):
        content = base64.b64encode(content.encode()).decode()
    
    return Response(content, mimetype='text/plain')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
