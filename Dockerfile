# 使用官方 Alpine Linux 作为基础镜像，因为它非常小巧
FROM alpine:latest

# 设置工作目录
WORKDIR /usr/local/bin

# 下载并安装 Cloudflared
# 这个 RUN 命令会根据构建时的架构（TARGETARCH）自动下载对应的 Cloudflared 版本。
# TARGETARCH 是 Docker 内置的一个构建参数，会自动识别当前构建目标架构。
RUN apk update && \
    apk add --no-cache curl && \
    case "$(TARGETARCH)" in \
        "amd64") \
            CLOUD_FLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" ;; \
        "arm64") \
            CLOUD_FLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" ;; \
        *) \
            echo "错误: 不支持的构建架构 $(TARGETARCH)。仅支持 amd64 和 arm64。" && exit 1 ;; \
    esac && \
    echo "正在下载 Cloudflared for $(TARGETARCH) from ${CLOUD_FLARED_URL}" && \
    curl -sSL "${CLOUD_FLARED_URL}" -o cloudflared && \
    chmod +x cloudflared && \
    apk del curl && \
    rm -rf /var/cache/apk/*

# 定义默认的 ENTRYPOINT，这样在运行容器时可以直接执行 cloudflared 命令
ENTRYPOINT ["cloudflared"]

# 定义默认的 CMD，例如启动一个 tunnel
CMD ["--help"]