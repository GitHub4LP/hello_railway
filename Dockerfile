FROM debian:bookworm-slim

# 安装依赖
RUN apt-get update && apt-get install -y \
    wget unzip nginx-light python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 安装 xray
RUN wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip

# 安装 Python 依赖
RUN pip3 install --no-cache-dir flask --break-system-packages

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
COPY sub_api.py /sub_api.py

RUN chmod +x /start.sh

EXPOSE 80 8443

CMD ["/start.sh"]
