#!/bin/bash

# 定义颜色输出，提升交互体验
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== SSH 免密登录快速配置脚本 ===${NC}\n"

# 1. 收集服务器信息
read -p "请输入远程服务器的用户名 (默认: root): " REMOTE_USER
REMOTE_USER=${REMOTE_USER:-root}

read -p "请输入远程服务器的 IP 地址或域名: " REMOTE_HOST
# 注意：这里 [ 和 ] 两边必须要有空格
while [ -z "$REMOTE_HOST" ]; do
    read -p "IP 地址不能为空，请重新输入: " REMOTE_HOST
done

read -p "请输入远程服务器的 SSH 端口 (默认: 22): " REMOTE_PORT
REMOTE_PORT=${REMOTE_PORT:-22}

# 确保 ~/.ssh 目录存在
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 2. 查找本地现有的公钥 (.pub)
shopt -s nullglob
PUB_KEYS=("$SSH_DIR"/*.pub)
shopt -u nullglob

SELECTED_PUB_KEY=""

# 3. 交互式选择或生成新密钥
if [ ${#PUB_KEYS[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}在您的 $SSH_DIR 目录中发现以下公钥：${NC}"
    for i in "${!PUB_KEYS[@]}"; do
        echo "$((i+1)). ${PUB_KEYS[$i]}"
    done
    echo "$(( ${#PUB_KEYS[@]} + 1 )). ➕ 生成一个新的 SSH 密钥"

    while true; do
        read -p "请选择一个操作序号 (1-$(( ${#PUB_KEYS[@]} + 1 ))): " CHOICE
        # 校验输入是否为合法数字
        if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] &&[ "$CHOICE" -le "$(( ${#PUB_KEYS[@]} + 1 ))" ]; then
            break
        else
            echo -e "${RED}无效的选择，请重新输入合法序号。${NC}"
        fi
    done

    # 如果用户选择的是已有密钥
    if [ "$CHOICE" -le "${#PUB_KEYS[@]}" ]; then
        SELECTED_PUB_KEY="${PUB_KEYS[$((CHOICE-1))]}"
    fi
fi

# 4. 生成新密钥逻辑（没有现存公钥，或者用户选择了“生成新密钥”）
if [ -z "$SELECTED_PUB_KEY" ]; then
    echo -e "\n${YELLOW}>>> 开始生成新的 SSH 密钥...${NC}"
    read -p "请输入您的邮箱 (用于密钥注释, 默认: your_email@example.com): " EMAIL
    EMAIL=${EMAIL:-"your_email@example.com"}

    read -p "请输入密钥文件的名称 (默认: id_rsa): " KEY_NAME
    KEY_NAME=${KEY_NAME:-"id_rsa"}

    KEY_PATH="$SSH_DIR/$KEY_NAME"

    # 执行生成命令，如果文件已存在 ssh-keygen 会自动询问是否覆盖
    ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$KEY_PATH"

    if [ $? -ne 0 ]; then
        echo -e "${RED}密钥生成失败，脚本终止！${NC}"
        exit 1
    fi
    SELECTED_PUB_KEY="${KEY_PATH}.pub"
fi

# 5. 将选中的公钥拷贝到远程服务器
echo -e "\n${YELLOW}>>> 准备将公钥 ($SELECTED_PUB_KEY) 推送至远程服务器...${NC}"
echo "注意：接下来可能需要您输入一次远程服务器的密码！"

# 使用 ssh-copy-id 将公钥传输到服务器
ssh-copy-id -i "$SELECTED_PUB_KEY" -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}🎉 配置成功！${NC}"
    echo -e "您现在可以尝试使用以下命令免密登录服务器："
    if [ "$REMOTE_PORT" == "22" ]; then
        echo -e "${GREEN}ssh $REMOTE_USER@$REMOTE_HOST${NC}"
    else
        echo -e "${GREEN}ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST${NC}"
    fi
else
    echo -e "\n${RED}❌ 推送公钥失败，请检查网络、IP地址、端口和密码是否正确。${NC}"
fi