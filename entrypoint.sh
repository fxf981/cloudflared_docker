#!/usr/bin/env bash

# 定义颜色常量用于输出 (可选，但对于日志清晰很有用)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 定义一个错误处理函数
error() {
    echo -e "${RED}错误: $1${NC}" >&2
    # 退出容器时使用非零代码表示失败
    exit 1
}

# Cloudflared 将被下载到此目录
INSTALL_DIR="/usr/local/bin"
CLOUDFLARED_BIN="${INSTALL_DIR}/cloudflared"

echo -e "${YELLOW}正在检查 Cloudflared 是否已存在...${NC}"
if [ -f "${CLOUDFLARED_BIN}" ]; then
    echo -e "${GREEN}Cloudflared 已存在于 ${CLOUDFLARED_BIN}，跳过下载。${NC}"
    # 如果已经存在，直接执行并传入所有命令行参数
    exec "${CLOUDFLARED_BIN}" "$@"
fi

echo -e "${YELLOW}Cloudflared 不存在，正在检测系统架构以下载...${NC}"

# 判断处理器架构
ARCH=""
case "$(uname -m)" in
    aarch64|arm64 )
        ARCH="arm64"
        echo -e "${GREEN}检测到架构: ARM64 (aarch64)${NC}"
        ;;
    x86_64|amd64 )
        ARCH="amd64"
        echo -e "${GREEN}检测到架构: AMD64 (x86_64)${NC}"
        ;;
    * )
        error "不支持的处理器架构: $(uname -m)。当前仅支持 aarch64/arm64 和 x86_64/amd64。"
        ;;
esac

# Cloudflared 下载地址的基础 URL
BASE_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux"

# 根据架构确定完整的下载文件名
DOWNLOAD_FILE=""
case "${ARCH}" in
    amd64)
        DOWNLOAD_FILE="${BASE_URL}-amd64"
        ;;
    arm64)
        DOWNLOAD_FILE="${BASE_URL}-arm64"
        ;;
esac

# 检查下载文件路径是否为空
if [ -z "${DOWNLOAD_FILE}" ]; then
    error "无法为 ${ARCH} 架构确定 Cloudflared 下载路径。"
fi

# 确保安装目录存在
mkdir -p "${INSTALL_DIR}" || error "无法创建安装目录 ${INSTALL_DIR}"

echo -e "${YELLOW}正在下载 Cloudflared (${ARCH})...${NC}"
echo -e "下载地址: ${DOWNLOAD_FILE}"

# 下载 cloudflared
# curl -sSL：静默模式，跟随重定向
# -o：指定输出文件名
if ! curl -sSL "${DOWNLOAD_FILE}" -o "${CLOUDFLARED_BIN}"; then
    error "下载 Cloudflared 失败。请检查网络连接或 Cloudflared 发布页面的最新下载链接。"
fi

echo -e "${GREEN}下载完成！${NC}"

# 添加执行权限
echo -e "${YELLOW}正在添加执行权限...${NC}"
if ! chmod +x "${CLOUDFLARED_BIN}"; then
    error "添加执行权限失败。"
fi

echo -e "${GREEN}Cloudflared 已成功安装到 ${CLOUDFLARED_BIN} 并已添加执行权限。${NC}"

# 最后，执行 Cloudflared，并把所有传入容器的参数传递给它
echo -e "${GREEN}正在启动 Cloudflared...${NC}"
exec "${CLOUDFLARED_BIN}" "$@"