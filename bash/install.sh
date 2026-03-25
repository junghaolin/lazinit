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

# 徹底重整 ~/.bashrc (保證置頂)
info "正在重整 ~/.bashrc 確保配置生效..."

# 移除舊的注入，避免重複 (包含之前的 ble.sh 痕跡)
sed -i '/Lazinit Bash/d' ~/.bashrc
sed -i '/bashrc_extra/d' ~/.bashrc
sed -i '/====================================/d' ~/.bashrc

# 建立新檔案，先串接原有的 .bashrc，再把我們的配置放在最底部 (以覆蓋系統預設的 PS1 與 alias)
TEMP_RC=$(mktemp)
cat ~/.bashrc > "$TEMP_RC"
echo "" >> "$TEMP_RC"
echo "# === Lazinit Bash 強化配置 ===" >> "$TEMP_RC"
echo "[ -f $SCRIPT_DIR/bashrc_extra ] && . $SCRIPT_DIR/bashrc_extra" >> "$TEMP_RC"
echo "# ======================================================" >> "$TEMP_RC"

# 覆蓋原檔
mv "$TEMP_RC" ~/.bashrc

success "Bash 強化環境安裝完成！"
echo "請務必執行指令: exec bash"
