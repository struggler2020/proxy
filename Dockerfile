# 使用轻量级的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装 dante-server (socks5 代理服务器)
RUN apk add --no-cache dante-server

# 创建配置文件目录
RUN mkdir -p /etc/sockd

# 添加 dante 服务器配置
RUN echo "logoutput: stderr" > /etc/sockd/sockd.conf && \
    echo "internal: 0.0.0.0 port=1080" >> /etc/sockd/sockd.conf && \
    echo "external: eth0" >> /etc/sockd/sockd.conf && \
    echo "socksmethod: username none" >> /etc/sockd/sockd.conf && \
    echo "clientmethod: none" >> /etc/sockd/sockd.conf && \
    echo "user.privileged: root" >> /etc/sockd/sockd.conf && \
    echo "user.unprivileged: nobody" >> /etc/sockd/sockd.conf && \
    echo "client pass {" >> /etc/sockd/sockd.conf && \
    echo "    from: 0.0.0.0/0 to: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    log: error connect disconnect" >> /etc/sockd/sockd.conf && \
    echo "}" >> /etc/sockd/sockd.conf && \
    echo "pass {" >> /etc/sockd/sockd.conf && \
    echo "    from: 0.0.0.0/0 to: 0.0.0.0/0" >> /etc/sockd/sockd.conf && \
    echo "    log: error connect disconnect" >> /etc/sockd/sockd.conf && \
    echo "}" >> /etc/sockd/sockd.conf

# 创建用户认证文件
RUN echo "username:password" > /etc/sockd/passwd

# 暴露 SOCKS5 代理端口
EXPOSE 1080

# 启动 dante 服务器
CMD ["sockd", "-f", "/etc/sockd/sockd.conf"]
