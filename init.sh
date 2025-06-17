#!/usr/bin/env bash

# 定义颜色常量用于输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 定义一个错误处理函数
error() {
    echo -e "${RED}错误: $1${NC}" >&2
    exit 1
}

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   error "此脚本需要以root权限运行。请使用 'sudo bash init.sh' 或 'su -c bash init.sh' 运行。"
fi

echo -e "${YELLOW}正在检测系统架构...${NC}"

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

# 检查下载文件路径是否为空（理论上这里不会为空，因为不支持的架构已经在上面处理了）
if [ -z "${DOWNLOAD_FILE}" ]; then
    error "无法为 ${ARCH} 架构确定 Cloudflared 下载路径。"
fi

echo -e "${YELLOW}正在下载 Cloudflared (${ARCH})...${NC}"
echo -e "下载地址: ${DOWNLOAD_FILE}"

# 下载 cloudflared
# -sL：静默模式，跟随重定向
# -o：指定输出文件名
if ! curl -sSL "${DOWNLOAD_FILE}" -o /usr/local/bin/cloudflared; then
    error "下载 Cloudflared 失败。请检查网络连接或 Cloudflared 发布页面的最新下载链接。"
fi

echo -e "${GREEN}下载完成！${NC}"

# 添加执行权限
echo -e "${YELLOW}正在添加执行权限...${NC}"
if ! chmod +x /usr/local/bin/cloudflared; then
    error "添加执行权限失败。"
fi

echo -e "${GREEN}Cloudflared 已成功安装到 /usr/local/bin/cloudflared 并已添加执行权限。${NC}"

echo -e "${GREEN}你可以运行以下命令测试 Cloudflared:${NC}"
echo -e "${GREEN}  /usr/local/bin/cloudflared --version${NC}"
echo -e "${GREEN}或${NC}"
echo -e "${GREEN}  cloudflared --version${NC} (如果 /usr/local/bin 在你的 PATH 中)${NC}"