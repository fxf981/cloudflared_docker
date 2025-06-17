# 使用官方 Alpine Linux 作为基础镜像，因为它非常小巧
FROM alpine:latest

# 设置工作目录
WORKDIR /usr/local/bin

# 下载并安装 Cloudflared
# 这里我们直接使用 /latest URL，并让 curl 处理重定向以获取实际下载链接
# 注意：这假设 GitHub Pages 的 /latest 重定向后会提供一个可下载的链接
RUN apk update && \
    apk add --no-cache curl && \
    curl -sSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared && \
    chmod +x cloudflared && \
    apk del curl && \
    rm -rf /var/cache/apk/*

# 定义默认的 ENTRYPOINT，这样在运行容器时可以直接执行 cloudflared 命令
ENTRYPOINT ["cloudflared"]

# 定义默认的 CMD，例如启动一个 tunnel
CMD ["--help"]