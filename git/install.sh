#!/bin/bash
# Git 配置安裝腳本

set -e

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 備份現有配置
backup_if_exists() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        info "備份現有檔案: $file"
        mv "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        success "備份完成"
    fi
}

backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.gitignore_global"

info "建立 Git 符號連結..."
ln -sf "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
ln -sf "$SCRIPT_DIR/gitignore_global" "$HOME/.gitignore_global"

success "Git 配置完成！"
echo "  ~/.gitconfig        -> $SCRIPT_DIR/gitconfig"
echo "  ~/.gitignore_global -> $SCRIPT_DIR/gitignore_global"

# 提示使用者設定個人資訊 (如果尚未設定)
if [ -z "$(git config --global user.name)" ]; then
    echo ""
    info "提示：你尚未設定 Git 使用者名稱，可以使用以下指令設定："
    echo "  git config --global user.name \"Your Name\""
fi

if [ -z "$(git config --global user.email)" ]; then
    info "提示：你尚未設定 Git 電子郵件，可以使用以下指令設定："
    echo "  git config --global user.email \"your@email.com\""
fi
