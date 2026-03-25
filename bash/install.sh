#!/bin/bash
# Bash 強化配置安裝腳本 (含 ble.sh 灰色補全)

set -e

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. 安裝 ble.sh (提供灰色補全)
if [ ! -d "$HOME/.local/share/blesh" ]; then
    info "正在安裝 ble.sh (這將提供類似 Zsh 的灰色補全功能)..."
    # 下載並編譯 (純 bash 編譯，不需要額外工具)
    git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
    make -C /tmp/ble.sh install PREFIX="$HOME/.local"
    rm -rf /tmp/ble.sh
    success "ble.sh 安裝完成！"
else
    info "ble.sh 已存在，跳過安裝。"
fi

# 2. 在 ~/.bashrc 結尾注入載入語句
# 註：ble.sh 必須在 .bashrc 的最上方載入以獲得最佳相容性
if ! grep -q "bashrc_extra" ~/.bashrc; then
    info "正在將強化配置注入 ~/.bashrc..."
    
    # 建立一個臨時檔案來重組 .bashrc
    TMP_RC=$(mktemp)
    echo "# 載入 Lazinit Bash 強化配置 (ble.sh 建議放在最上方)" > "$TMP_RC"
    echo "[ -f $SCRIPT_DIR/bashrc_extra ] && . $SCRIPT_DIR/bashrc_extra" >> "$TMP_RC"
    echo "" >> "$TMP_RC"
    cat ~/.bashrc >> "$TMP_RC"
    mv "$TMP_RC" ~/.bashrc
    
    success "注入完成！"
else
    success "強化配置已經存在於 ~/.bashrc 中。"
fi

success "Bash 強化配置與 ble.sh 安裝完成！"
echo "請重新啟動終端機，或輸入 'exec bash' 來體驗灰色補全。"
