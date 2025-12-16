#!/bin/bash
# 模块化安装包装脚本

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

show_help() {
    cat << EOF
Lazinit 模块化安装工具

用法: $0 [OPTIONS]

选项:
  --only-zsh      只安装 ZSH（包括包安装）
  --only-nvim     只安装 Neovim
  --skip-pkgs     跳过包安装（apt/brew）
  --skip-zsh      跳过 ZSH 配置
  --skip-nvim     跳过 Neovim 安装提示
  --help, -h      显示帮助

示例:
  $0                  # 完整安装
  $0 --only-zsh       # 只配置 ZSH
  $0 --only-nvim      # 只安装 Neovim
  $0 --skip-pkgs      # 不安装包，只配置

模块说明:
  1. 包安装（apt/brew）
     - 安装 init_apt_pks 中列出的所有工具
     - 逐个安装，失败不中断
  
  2. ZSH 配置
     - 创建符号链接
     - 编译配置
     - 设置工作环境（如需要）
  
  3. Neovim 安装
     - 安装 Neovim 0.11.5
     - 安装 LSP 服务器
     - 配置插件

独立使用:
  # 只安装 Neovim
  cd neovim && ./install.v2.sh
  
  # 只配置 ZSH
  cd zsh && ./install.sh
EOF
}

# 解析参数并转发给 init_env.v2.sh
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# 转发所有参数给主脚本
"$SCRIPT_DIR/init_env.v2.sh" "$@"
