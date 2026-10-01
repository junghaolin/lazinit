#!/bin/bash
# Tmux 配置安裝腳本

set -e

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

info "備份現有 tmux 配置..."
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
    success "備份完成"
fi

info "建立 tmux 符號連結..."
ln -sf "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"

success "Tmux 配置完成！"
echo "  ~/.tmux.conf -> $SCRIPT_DIR/tmux.conf"
echo "請在終端機內輸入 'tmux source ~/.tmux.conf' 來立即套用設定。"
