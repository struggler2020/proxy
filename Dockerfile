# 使用轻量级的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装必要的包
RUN apk add --no-cache dante-server curl iputils

# 创建配置文件目录
RUN mkdir -p /etc/sockd

# 添加 dante 服务器配置
RUN echo "debug: 2" > /etc/sockd/sockd.conf && \
    echo "logoutput: stderr" >> /etc/sockd/sockd.conf && \
    echo "internal: 0.0.0.0 port=1080" >> /etc/sockd/sockd.conf && \
    echo "external: eth0" >> /etc/sockd/sockd.conf && \
    echo "socksmethod: username" >> /etc/sockd/sockd.conf && \
    echo "clientmethod: none" >> /etc/sockd/sockd.conf && \
    echo "user.privileged: root" >> /etc/sockd/sockd.conf && \
    echo "user.unprivileged: nobody" >> /etc/sockd/sockd.conf && \
    echo "timeout.negotiate: 30" >> /etc/sockd/sockd.conf && \
    echo "timeout.connect: 30" >> /etc/sockd/sockd.conf && \
    echo "timeout.io: 60" >> /etc/sockd/sockd.conf && \
    echo "" >> /etc/sockd/sockd.conf && \
    echo "client pass {" >> /etc/sockd/sockd.conf && \
    echo "    from: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    to: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    log: error" >> /etc/sockd/sockd.conf && \
    echo "}" >> /etc/sockd/sockd.conf && \
    echo "" >> /etc/sockd/sockd.conf && \
    echo "socks pass {" >> /etc/sockd/sockd.conf && \
    echo "    from: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    to: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    protocol: tcp udp" >> /etc/sockd/sockd.conf && \
    echo "    command: bind connect udpassociate" >> /etc/sockd/sockd.conf && \
    echo "    log: error" >> /etc/sockd/sockd.conf && \
    echo "}" >> /etc/sockd/sockd.conf

# 创建用户认证文件
RUN echo "username111:bcb09023f98" > /etc/sockd/passwd

# 创建健康检查脚本
COPY <<'EOF' /healthcheck.sh
#!/bin/sh
nc -z localhost 1080
EOF

RUN chmod +x /healthcheck.sh

# 暴露 SOCKS5 代理端口
EXPOSE 1080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /healthcheck.sh

# 启动 dante 服务器
CMD ["sockd", "-f", "/etc/sockd/sockd.conf", "-N", "2", "-d", "2"]
