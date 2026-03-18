#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== 服务器 Git 免密登录配置脚本 ===${NC}\n"

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 推荐使用 Git 官方建议的 ed25519 算法
KEY_PATH="$SSH_DIR/id_ed25519"

# 1. 生成密钥
if [ ! -f "$KEY_PATH" ]; then
    echo -e "${YELLOW}未发现默认的 ed25519 密钥，准备生成...${NC}"
    read -p "请输入您的邮箱 (用于密钥注释，直接回车使用默认值): " GIT_EMAIL
    GIT_EMAIL=${GIT_EMAIL:-"your_email@example.com"}

    # 生成密钥，-N "" 表示默认不设置密码，避免每次拉代码还要输密码
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N ""
    echo -e "${GREEN}✅ 密钥生成完毕！${NC}"
else
    echo -e "${GREEN}✅ 发现已存在的 SSH 密钥: $KEY_PATH${NC}"
fi

# 2. 打印公钥并引导用户添加
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${YELLOW}请复制下方虚线框内的所有内容（公钥）：${NC}"
echo "----------------------------------------------------"
cat "${KEY_PATH}.pub"
echo "----------------------------------------------------"
echo -e "${YELLOW}操作指引：${NC}"
echo "1. 登录您的 Git 托管平台 (GitHub / Gitee / GitLab 等)"
echo "2. 找到 设置(Settings) -> SSH Keys -> 添加 SSH Key"
echo "3. 将上面虚线框内的内容完整粘贴进去并保存"
echo -e "${CYAN}====================================================${NC}\n"

read -p "👉 确认已在 Git 平台添加好公钥后，请按【回车键】继续..."

# 3. 添加主机信任并测试连接
echo -e "\n${YELLOW}>>> 配置主机信任并测试连接...${NC}"
read -p "请输入您的 Git 平台域名 (默认: github.com，如使用码云可输入 gitee.com): " GIT_HOST
GIT_HOST=${GIT_HOST:-"github.com"}

# 将 Git 平台加入 known_hosts，防止首次 git clone 时卡在 yes/no 询问
echo "正在将 $GIT_HOST 加入信任列表..."
ssh-keyscan -H "$GIT_HOST" >> "$SSH_DIR/known_hosts" 2>/dev/null

echo -e "\n正在尝试连接 $GIT_HOST 测试认证..."
# 使用 ssh -T 测试连接
ssh -T git@"$GIT_HOST"

echo -e "\n${GREEN}🎉 Git 免密配置流程结束！${NC}"
echo -e "只要上方测试连接提示类似于 'Hi xxx! You've successfully authenticated'，您就可以直接运行 git clone 自由拉取代码了。"
