# 🚀 AutoShell

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-4EAA25.svg)](#)

**AutoShell** 是一个致力于简化服务器部署与日常运维的自动化脚本工具箱。

在日常的开发和运维中，我们经常需要进行一些重复性的环境配置工作（如配置免密登录、Git 认证等）。本项目提供了一系列开箱即用、高度交互式的 Shell 脚本，帮助开发者告别繁琐的手动敲命令环节，实现一键式的自动化配置。

---

## 🛠️ 包含的脚本 (Features)

目前项目包含以下核心自动化脚本：

| 脚本文件           | 功能描述                                                                                                 | 适用场景                   |
| :----------------- | :------------------------------------------------------------------------------------------------------- | :------------------------- |
| `setup_ssh.sh`     | **SSH 免密登录快速配置**：自动扫描或生成本地 SSH 密钥，并一键推送到远程服务器。                          | 本地电脑 -> 远程服务器     |
| `setup_git_ssh.sh` | **Git 免密认证配置**：在服务器上自动生成高安全的 `ed25519` 密钥，引导添加至 Git 平台并自动信任主机指纹。 | 远程服务器 -> Git 托管平台 |

---

## 🚀 快速开始 (Getting Started)

### 1. 克隆项目

首先，将本项目克隆到你的本地电脑或远程服务器上：

```bash
git clone https://github.com/Axingx/AutoShell.git
cd AutoShell
```

### 2. 赋予执行权限

在运行任何脚本之前，请确保它们具有可执行权限：

```bash
chmod +x *.sh
```

---

## 📖 脚本详细说明 (Usage)

### 🖥️ 1. SSH 免密登录快速配置 (`setup_ssh.sh`)

**用途**：当你在本地电脑上，想要免密码 SSH 登录到某台新服务器时使用。

**执行命令**：

```bash
./setup_ssh.sh
```

**工作流程**：

1. 询问并收集远程服务器的 `用户名`、`IP地址` 和 `端口号`。
2. 自动扫描本机 `~/.ssh/` 目录下的已有公钥，让你通过序号快速选择。
3. 如果没有密钥，脚本会引导你输入邮箱并自动执行 `ssh-keygen` 生成新密钥。
4. 调用 `ssh-copy-id` 安全地将公钥推送到远程服务器（仅需输入最后一次服务器密码即可完成配置）。

---

### 🐙 2. 服务器 Git 免密认证配置 (`setup_git_ssh.sh`)

**用途**：当你登录到远程服务器后，想要拉取 GitHub/Gitee/GitLab 上的私有仓库代码时使用。

**执行命令**：

```bash
./setup_git_ssh.sh
```

**工作流程**：

1. 自动在服务器上生成 Git 官方推荐的高强度 `ed25519` 算法的 SSH 密钥（默认无密码保护，方便拉取代码）。
2. 在控制台高亮打印公钥内容，并暂停脚本，等待你将其复制到对应的 Git 托管平台。
3. 确认添加完毕后，自动要求输入 Git 平台域名（如 `github.com` 或 `gitee.com`）。
4. 自动将域名加入 `known_hosts` 信任列表（告别恼人的 `yes/no` 提示），并执行连通性测试。

---

## 🤝 参与贡献 (Contributing)

如果你有其他日常运维中常用的自动化脚本（例如环境安装、Docker 配置、日志清理等），非常欢迎提交 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingScript`)
3. 提交你的更改 (`git commit -m 'Add some AmazingScript'`)
4. 推送到分支 (`git push origin feature/AmazingScript`)
5. 开启一个 Pull Request

---

## 📄 许可证 (License)

本项目基于 [MIT License](LICENSE) 开源，你可以自由地使用、修改和分发。
