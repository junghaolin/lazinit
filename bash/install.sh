#!/bin/bash
# Bash 強化配置安裝腳本 (修復版 - 確保 ble.sh 成功安裝)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. 安裝 ble.sh (改用更穩定的預編譯下載方式)
if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
    info "正在安裝 ble.sh (穩定版)..."
    # 下載官方預編譯穩定包
    wget -qO- https://github.com/akinomyoga/ble.sh/releases/download/v0.4.0-devel3/ble-0.4.0-devel3.tar.xz | tar xJ -C /tmp
    mkdir -p "$HOME/.local/share/blesh"
    cp -rf /tmp/ble-0.4.0-devel3/* "$HOME/.local/share/blesh/"
    rm -rf /tmp/ble-0.4.0-devel3
    success "ble.sh 安裝成功"
else
    info "ble.sh 已存在"
fi

# 2. 注入 ~/.bashrc (採用更激進的頂部注入)
if ! grep -q "bashrc_extra" ~/.bashrc; then
    info "正在將配置注入 ~/.bashrc 最頂部..."
    TEMP_FILE=$(mktemp)
    echo "# === Lazinit Bash 強化配置 (必須在最上方以啟動 ble.sh) ===" > "$TEMP_FILE"
    echo "[ -f $SCRIPT_DIR/bashrc_extra ] && . $SCRIPT_DIR/bashrc_extra" >> "$TEMP_FILE"
    echo "# ======================================================" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    cat ~/.bashrc >> "$TEMP_FILE"
    mv "$TEMP_FILE" ~/.bashrc
    success "注入完成"
fi

success "Bash 強化環境已就緒！"
echo "請執行 'exec bash' 來立即體驗灰色補全。"
