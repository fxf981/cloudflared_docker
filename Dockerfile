# 使用官方 Alpine Linux 作为基础镜像，因为它非常小巧
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 安装必要软件包
RUN apk update && \
    apk add --no-cache curl bash && \
    rm -rf /var/cache/apk/*

# 创建 entrypoint.sh 脚本，它将负责下载 cloudflared
# 这里直接将内容写入文件，避免在构建阶段再次进行外部下载
COPY entrypoint.sh /app/entrypoint.sh
# 确保 entrypoint.sh 脚本可执行
RUN chmod +x /app/entrypoint.sh

# 设置 ENTRYPOINT 为你的脚本
ENTRYPOINT ["/app/entrypoint.sh"]

# CMD 可以作为 ENTRYPOINT 的默认参数，或用于在没有额外参数时提供默认行为
# 如果你的 entrypoint.sh 脚本能够处理参数，这里可以留空或设置默认值
CMD []