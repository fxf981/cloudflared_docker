# 使用官方 Alpine Linux 作为基础镜像，因为它非常小巧
FROM alpine:latest

# 设置工作目录
WORKDIR /usr/local/bin

# 下载并安装 Cloudflared
# 这个 RUN 命令会根据构建时的架构（TARGETARCH）自动下载对应的 Cloudflared 版本。
# TARGETARCH 是 Docker 内置的一个构建参数，会自动识别当前构建目标架构。
RUN set -x && \
    echo "--- 开始执行 apk update ---" && \
    apk update || { echo "错误: apk update 失败！" >&2; exit 1; } && \
    echo "--- apk update 完成 ---" && \
    echo "--- 开始安装 curl ---" && \
    apk add --no-cache curl || { echo "错误: 安装 curl 失败！" >&2; exit 1; } && \
    echo "--- curl 安装完成 ---" && \
    \
    CURRENT_TARGETARCH="$(TARGETARCH)" && \
    echo "检测到的构建架构 TARGETARCH: ${CURRENT_TARGETARCH}" && \
    case "${CURRENT_TARGETARCH}" in \
        "amd64") \
            CLOUD_FLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" ;; \
        "arm64") \
            CLOUD_FLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" ;; \
        *) \
            echo "错误: 不支持的构建架构 ${CURRENT_TARGETARCH}。仅支持 amd64 和 arm64。" >&2 && exit 1 ;; \
    esac && \
    echo "正在下载 Cloudflared for ${CURRENT_TARGETARCH} from ${CLOUD_FLARED_URL}" && \
    curl -sSL "${CLOUD_FLARED_URL}" -o cloudflared || { echo "错误: curl 下载 Cloudflared 失败！" >&2; exit 1; } && \
    echo "--- Cloudflared 下载完成 ---" && \
    \
    echo "--- 正在添加执行权限 ---" && \
    chmod +x cloudflared || { echo "错误: 添加执行权限失败！" >&2; exit 1; } && \
    echo "--- 执行权限添加完成 ---" && \
    \
    echo "--- 清理不必要的软件包和缓存 ---" && \
    apk del curl || { echo "警告: 删除 curl 失败。" >&2; } && \
    rm -rf /var/cache/apk/* || { echo "警告: 清理缓存失败。" >&2; } && \
    echo "--- 清理完成 ---" && \
    set +x # 关闭调试模式
    
# 定义默认的 ENTRYPOINT，这样在运行容器时可以直接执行 cloudflared 命令
ENTRYPOINT ["cloudflared"]

# 定义默认的 CMD，例如启动一个 tunnel
CMD ["--help"]