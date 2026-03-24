#!/bin/bash
# Neovim + LSP 環境安裝腳本（完全修復版）
# 支援 ARM64 (Orange Pi), 穩定版本偵測, 極簡模式

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

# 參數解析
REINSTALL_DEEP=false
INSTALL_MINIMAL=false
for arg in "$@"; do
    case $arg in
        --reinstall) REINSTALL_DEEP=true ;;
        --minimal) INSTALL_MINIMAL=true ;;
    esac
done

# 環境檢測
if [[ "$OSTYPE" == "darwin"* ]]; then OS="macos"; else OS="linux"; fi
SUDO="sudo"; [ "$(id -u)" == "0" ] && SUDO=""

# 深度清理
if [ "$REINSTALL_DEEP" = true ]; then
    section "執行深度清理"
    rm -rf "$HOME/.local/share/nvim" "$HOME/.cache/nvim" "$HOME/.local/state/nvim"
    success "清理完成"
fi

# Neovim 安裝與版本校驗
section "檢查 Neovim 版本"
install_neovim() {
    local ARCH=$(uname -m)
    local NEEDS_UPDATE=false
    
    if command -v nvim >/dev/null 2>&1; then
        # 強健的版本提取邏輯：只拿數字 (例如 NVIM v0.7.2 -> 0.7.2)
        local ver_str=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        local major=$(echo $ver_str | cut -d. -f1)
        local minor=$(echo $ver_str | cut -d. -f2)
        
        info "檢測到現有版本: $ver_str ($ARCH)"
        
        if [ "$major" -eq 0 ] && [ "$minor" -lt 10 ]; then
            warning "版本太舊 ($ver_str)，必須更新到 0.10.0+ 才能執行現代配置。"
            NEEDS_UPDATE=true
        elif [ "$INSTALL_MINIMAL" = true ]; then
            info "極簡模式：版本足夠，跳過安裝"
            return
        else
            NEEDS_UPDATE=false
        fi
    else
        info "未檢測到 Neovim，準備開始安裝..."
        NEEDS_UPDATE=true
    fi

    if [ "$NEEDS_UPDATE" = true ]; then
        if [ "$OS" = "macos" ]; then
            brew install neovim
        else
            # 針對 Linux (x86_64 或 ARM64)
            if [ "$ARCH" = "x86_64" ]; then
                info "下載 Neovim x86_64 AppImage..."
                wget -q --show-progress -O /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
                chmod +x /tmp/nvim.appimage
                $SUDO mv /tmp/nvim.appimage /usr/local/bin/nvim
            elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
                info "檢測到 ARM64 架構，下載預編譯包..."
                wget -q --show-progress -O /tmp/nvim-linux-arm64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
                cd /tmp && tar -xzf nvim-linux-arm64.tar.gz
                $SUDO cp -rf nvim-linux-arm64/bin/* /usr/local/bin/
                $SUDO cp -rf nvim-linux-arm64/lib/* /usr/local/lib/
                $SUDO cp -rf nvim-linux-arm64/share/* /usr/local/share/
                rm -rf nvim-linux-arm64 nvim-linux-arm64.tar.gz
                cd - > /dev/null
            fi
        fi
        success "Neovim 更新完成！"
    fi
}
install_neovim

# 基礎工具安裝
section "安裝基礎工具"
$SUDO apt update
if [ "$INSTALL_MINIMAL" = true ]; then
    $SUDO apt install -y git curl wget fd-find ripgrep
else
    $SUDO apt install -y git curl wget fd-find python3-pynvim ripgrep
fi
[ -x "$(command -v fdfind)" ] && mkdir -p "$HOME/.local/bin" && ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"

# 配置符號連結
section "配置 Neovim"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NVIM_CONFIG="$SCRIPT_DIR/nvim"
mkdir -p "$HOME/.config"

if [ "$INSTALL_MINIMAL" = true ]; then
    info "套用極簡配置 (Minimal Mode)..."
    cp "$NVIM_CONFIG/init.minimal.lua" "$NVIM_CONFIG/init.lua"
fi
ln -sf "$NVIM_CONFIG" "$HOME/.config/nvim"

# 最後修復
git config --global core.autocrlf false
git config --global core.fileMode false
rm -f "$HOME/.config/nvim/lazy-lock.json"

success "🎉 Neovim 安裝與配置完成！"
