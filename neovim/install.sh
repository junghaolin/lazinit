#!/bin/bash
# Neovim + LSP 環境安裝腳本（增強版）
# 支援跨平台、可選安裝、環境檢測、極簡模式、ARM64 適配

set -e  # 遇到錯誤立即停止

# ==================== 顏色定義 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==================== 輸出函數 ====================
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

# ==================== 參數解析 ====================
REINSTALL_DEEP=false
INSTALL_MINIMAL=false

for arg in "$@"; do
    case $arg in
        --reinstall)
            REINSTALL_DEEP=true
            warning "啟動深度重裝模式 (--reinstall)"
            ;;
        --minimal)
            INSTALL_MINIMAL=true
            warning "啟動極簡安裝模式 (--minimal)"
            info "這將只安裝核心工具與極簡版配置，不安裝 LSP 或 NVM"
            ;;
    esac
done

# ==================== 環境檢測 ====================
section "環境檢測"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    info "檢測到 macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    info "檢測到 Linux"
else
    error "不支援的操作系統: $OSTYPE"
    exit 1
fi

SUDO="sudo"
if [ "$(id -u)" == "0" ]; then
    SUDO=""
    warning "以 root 運行，不使用 sudo"
fi

# ==================== 深度清理 (Reinstall Mode) ====================
if [ "$REINSTALL_DEEP" = true ]; then
    section "執行深度清理"
    rm -rf "$HOME/.local/share/nvim/lazy"
    rm -rf "$HOME/.local/share/nvim/site/parser"
    rm -rf "$HOME/.cache/nvim/luac"
    rm -rf "$HOME/.local/share/nvim/mason"
    rm -rf "$HOME/.local/state/nvim"
    success "深度清理完成"
fi

# ==================== Neovim 安裝 ====================
section "安裝 Neovim (最新版)"

install_neovim() {
    local ARCH=$(uname -m)
    if command -v nvim >/dev/null 2>&1; then
        local current_version=$(nvim --version | head -n1 | awk '{print $2}')
        info "檢測到 Neovim: $current_version ($ARCH)"
        
        # 如果版本太舊 (< v0.10)，強制安裝/更新
        if [[ "$current_version" < "v0.10" ]]; then
            warning "版本太舊 ($current_version)，需要更新到 0.10+ 以上版本。"
        elif [ "$INSTALL_MINIMAL" = true ]; then
            info "極簡模式：現有版本已足夠，跳過安裝"
            return
        else
            read -p "是否重新安裝/更新到最新版本? [y/N]: " reinstall
            if [[ ! $reinstall =~ ^[Yy]$ ]]; then
                info "跳過 Neovim 安裝"
                return
            fi
        fi
    fi
    
    if [ "$OS" = "macos" ]; then
        brew install neovim
    else
        if [ "$ARCH" = "x86_64" ]; then
            info "下載 Neovim x86_64 AppImage..."
            wget -q --show-progress -O /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
            chmod +x /tmp/nvim.appimage
            $SUDO mv /tmp/nvim.appimage /usr/local/bin/nvim
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            info "檢測到 ARM64 架構 (Orange Pi/Raspberry Pi)..."
            info "下載 Neovim ARM64 預編譯包..."
            wget -q --show-progress -O /tmp/nvim-linux-arm64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
            cd /tmp
            tar -xzf nvim-linux-arm64.tar.gz
            $SUDO cp -rf nvim-linux-arm64/bin/* /usr/local/bin/
            $SUDO cp -rf nvim-linux-arm64/lib/* /usr/local/lib/
            $SUDO cp -rf nvim-linux-arm64/share/* /usr/local/share/
            rm -rf nvim-linux-arm64 nvim-linux-arm64.tar.gz
            cd - > /dev/null
        else
            error "不支援的架構: $ARCH"; exit 1
        fi
    fi
    success "Neovim 安裝完成: $(nvim --version | head -n1)"
}

install_neovim

# ==================== 基礎工具安裝 ====================
section "安裝基礎工具"

install_base_tools() {
    if [ "$OS" = "macos" ]; then
        brew install git curl wget fd lazygit ripgrep
    else
        $SUDO apt update
        if [ "$INSTALL_MINIMAL" = true ]; then
            $SUDO apt install -y git curl wget fd-find ripgrep
        else
            $SUDO apt install -y git curl wget fd-find python3-pynvim ripgrep
        fi
        
        if command -v fdfind >/dev/null 2>&1; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        fi
        
        if [ "$INSTALL_MINIMAL" = false ] && ! command -v lazygit >/dev/null 2>&1; then
            info "安裝 lazygit..."
            local LG_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            local LG_ARCH="x86_64"
            [ "$(uname -m)" = "aarch64" ] && LG_ARCH="arm64"
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz"
            tar xf lazygit.tar.gz lazygit && $SUDO install lazygit /usr/local/bin && rm lazygit.tar.gz lazygit
        fi
    fi
    success "基礎工具安裝完成"
}

install_base_tools

# ==================== 配置符號連結 ====================
section "配置 Neovim"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NVIM_CONFIG="$SCRIPT_DIR/nvim"

if [ "$INSTALL_MINIMAL" = true ]; then
    info "極簡模式：套用 init.minimal.lua"
    [ -f "$NVIM_CONFIG/init.lua" ] && ! grep -q "Minimal Mode" "$NVIM_CONFIG/init.lua" && mv "$NVIM_CONFIG/init.lua" "$NVIM_CONFIG/init.lua.full.backup"
    cp "$NVIM_CONFIG/init.minimal.lua" "$NVIM_CONFIG/init.lua"
else
    [ -f "$NVIM_CONFIG/init.lua.full.backup" ] && mv "$NVIM_CONFIG/init.lua.full.backup" "$NVIM_CONFIG/init.lua"
fi

mkdir -p "$HOME/.config"
ln -sf "$NVIM_CONFIG" "$HOME/.config/nvim"
success "配置完成: ~/.config/nvim -> $NVIM_CONFIG"

# ==================== 預防性修復 ====================
section "預防性修復"
git config --global core.autocrlf false
git config --global core.fileMode false
rm -f "$HOME/.config/nvim/lazy-lock.json"
success "修復完成"

echo -e "\n${GREEN}🎉 Neovim 安裝完成！${NC}"
