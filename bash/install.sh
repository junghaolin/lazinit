#!/bin/bash
# Bash 強化配置安裝腳本

set -e

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 在 ~/.bashrc 結尾注入載入語句
if ! grep -q "bashrc_extra" ~/.bashrc; then
    info "正在將強化配置注入 ~/.bashrc..."
    echo "" >> ~/.bashrc
    echo "# 載入 Lazinit Bash 強化配置" >> ~/.bashrc
    echo "[ -f $SCRIPT_DIR/bashrc_extra ] && . $SCRIPT_DIR/bashrc_extra" >> ~/.bashrc
    success "注入完成！"
else
    success "強化配置已經存在於 ~/.bashrc 中。"
fi

success "Bash 強化配置安裝完成！"
echo "請輸入 'source ~/.bashrc' 來立即套用。"
