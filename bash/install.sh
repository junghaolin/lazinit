#!/bin/bash
# Bash 強化配置安裝腳本 (精簡版 - 無 ble.sh)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 系統化重整 ~/.bashrc (採用軟連結取代不穩定的注入)
info "正在備份並建立 ~/.bashrc 軟連結..."

if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    BACKUP="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    info "備份現有的 ~/.bashrc 到 $BACKUP"
    mv "$HOME/.bashrc" "$BACKUP"
fi

ln -sf "$SCRIPT_DIR/bashrc" "$HOME/.bashrc"

success "Bash 強化環境安裝完成！"
echo "  ~/.bashrc -> $SCRIPT_DIR/bashrc"
echo "請務必執行指令: exec bash"
