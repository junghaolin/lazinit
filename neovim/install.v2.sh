#!/bin/bash
# Neovim + LSP 環境安裝腳本（增強版）
# 支援跨平台、可選安裝、環境檢測

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

# ==================== 環境檢測 ====================
section "環境檢測"

# 檢測操作系統
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

# 檢測是否為 VM（簡單檢測）
IS_VM=false
if [ -f /proc/meminfo ]; then
    TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [ "$TOTAL_MEM" -lt 4000000 ]; then
        IS_VM=true
        info "檢測到低記憶體環境 (< 4GB)，將使用精簡安裝"
    fi
fi

# 確定是否需要 sudo
SUDO="sudo"
if [ "$(id -u)" == "0" ]; then
    SUDO=""
    warning "以 root 運行，不使用 sudo"
fi

echo ""
info "環境摘要:"
echo "  OS: $OS"
echo "  VM/低記憶體: $IS_VM"
echo ""

# ==================== 安裝模式選擇 ====================
section "安裝模式選擇"

if [ "$IS_VM" = true ]; then
    INSTALL_MODE="minimal"
    info "自動選擇精簡模式（VM 環境）"
else
    echo "請選擇安裝模式："
    echo "  1) 完整安裝（所有 LSP + 圖片處理）"
    echo "  2) 基礎安裝（常用 LSP：Lua, Python, Bash, JSON, YAML）"
    echo "  3) 精簡安裝（僅 Lazy.nvim + 配置）"
    echo ""
    read -p "選擇 [1-3] (預設: 1): " choice
    choice=${choice:-1}
    
    case $choice in
        1) INSTALL_MODE="full" ;;
        2) INSTALL_MODE="basic" ;;
        3) INSTALL_MODE="minimal" ;;
        *) 
            error "無效選擇"
            exit 1
            ;;
    esac
fi

success "安裝模式: $INSTALL_MODE"

# ==================== Neovim 安裝 ====================
section "安裝 Neovim 0.11.5"

install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        local current_version=$(nvim --version | head -n1 | awk '{print $2}')
        info "檢測到 Neovim: $current_version"
        
        read -p "是否重新安裝/更新到 0.11.5? [y/N]: " reinstall
        if [[ ! $reinstall =~ ^[Yy]$ ]]; then
            info "跳過 Neovim 安裝"
            return
        fi
    fi
    
    if [ "$OS" = "macos" ]; then
        info "使用 Homebrew 安裝 Neovim..."
        brew install neovim
        success "Neovim 安裝完成"
    else
        info "下載 Neovim 0.11.5 AppImage..."
        
        # 下載 AppImage
        wget -q --show-progress -O /tmp/nvim.appimage \
            https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
        
        # 安裝依賴（AppImage 需要 FUSE）
        if ! command -v fusermount >/dev/null 2>&1; then
            info "安裝 FUSE 依賴..."
            $SUDO apt update
            $SUDO apt install -y fuse libfuse2
        fi
        
        # 設置執行權限並移動到 /usr/local/bin
        chmod +x /tmp/nvim.appimage
        $SUDO mv /tmp/nvim.appimage /usr/local/bin/nvim
        
        success "Neovim 0.11.5 安裝完成"
        
        # 驗證安裝
        if command -v nvim >/dev/null 2>&1; then
            info "版本確認: $(nvim --version | head -n1)"
        else
            error "Neovim 安裝失敗"
            exit 1
        fi
    fi
}

install_neovim

# ==================== 基礎工具安裝 ====================
section "安裝基礎工具"

install_base_tools() {
    if [ "$OS" = "macos" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            error "未安裝 Homebrew，請先安裝: https://brew.sh"
            exit 1
        fi
        info "使用 Homebrew 安裝基礎工具..."
        brew install git curl wget
    else
        info "使用 apt 安裝基礎工具..."
        $SUDO apt update
        $SUDO apt install -y git curl wget
    fi
    success "基礎工具安裝完成"
}

install_base_tools

# ==================== Lazy.nvim 安裝 ====================
section "安裝 Lazy.nvim"

install_lazy() {
    local lazypath="$HOME/.local/share/nvim/lazy/lazy.nvim"
    
    if [ -d "$lazypath" ]; then
        info "Lazy.nvim 已安裝"
    else
        info "克隆 Lazy.nvim..."
        git clone --filter=blob:none \
            https://github.com/folke/lazy.nvim.git \
            --branch=stable "$lazypath"
        success "Lazy.nvim 安裝完成"
    fi
}

install_lazy

# ==================== NVM + Node.js ====================
section "安裝 NVM 和 Node.js"

install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        info "NVM 已安裝"
    else
        info "安裝 NVM..."
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        success "NVM 安裝完成"
    fi
    
    # 載入 NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # 安裝 Node.js
    if ! command -v node >/dev/null 2>&1; then
        info "安裝 Node.js LTS..."
        nvm install --lts
        success "Node.js 安裝完成"
    else
        info "Node.js 已安裝: $(node --version)"
    fi
}

if [ "$INSTALL_MODE" != "minimal" ]; then
    install_nvm
fi

# ==================== LSP 安裝函數 ====================

# Markdown LSP
install_lsp_markdown() {
    section "安裝 Markdown LSP (marksman)"
    
    if command -v marksman >/dev/null 2>&1; then
        info "marksman 已安裝"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        curl -L -o /tmp/marksman.tar.gz \
            https://github.com/artempyanykh/marksman/releases/latest/download/marksman-macos-x64.tar.gz
    else
        curl -L -o /tmp/marksman.tar.gz \
            https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64.tar.gz
    fi
    
    tar -xzf /tmp/marksman.tar.gz -C /tmp
    $SUDO mv /tmp/marksman /usr/local/bin/
    rm -f /tmp/marksman.tar.gz
    success "Markdown LSP 安裝完成"
}

# Lua LSP
install_lsp_lua() {
    section "安裝 Lua LSP (lua-language-server)"
    
    if command -v lua-language-server >/dev/null 2>&1; then
        info "lua-language-server 已安裝"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        brew install lua-language-server
    else
        info "從源碼編譯 lua-language-server..."
        $SUDO apt install -y ninja-build git build-essential
        
        cd /tmp
        rm -rf lua-language-server
        git clone https://github.com/LuaLS/lua-language-server.git
        cd lua-language-server
        git submodule update --init --recursive
        cd 3rd/luamake
        ./compile/install.sh
        cd ../..
        ./3rd/luamake/luamake rebuild
        
        $SUDO mkdir -p /opt/lua-language-server
        $SUDO cp -r build/bin/* /opt/lua-language-server/
        $SUDO ln -sf /opt/lua-language-server/lua-language-server /usr/local/bin/lua-language-server
    fi
    success "Lua LSP 安裝完成"
}

# Python LSP
install_lsp_python() {
    info "安裝 Python LSP (pyright)..."
    npm install -g pyright
    success "Python LSP 安裝完成"
}

# Bash LSP
install_lsp_bash() {
    info "安裝 Bash LSP..."
    npm install -g bash-language-server
    success "Bash LSP 安裝完成"
}

# YAML LSP
install_lsp_yaml() {
    info "安裝 YAML LSP..."
    npm install -g yaml-language-server
    success "YAML LSP 安裝完成"
}

# JSON LSP
install_lsp_json() {
    info "安裝 JSON LSP..."
    npm install -g vscode-langservers-extracted
    success "JSON LSP 安裝完成"
}

# Go LSP
install_lsp_go() {
    section "安裝 Go LSP (gopls)"
    
    if [ "$OS" = "macos" ]; then
        brew install go
    else
        $SUDO apt install -y golang
    fi
    
    go install golang.org/x/tools/gopls@latest
    success "Go LSP 安裝完成"
}

# C/C++ LSP
install_lsp_c() {
    section "安裝 C/C++ LSP (clangd)"
    
    if [ "$OS" = "macos" ]; then
        brew install llvm
    else
        $SUDO apt install -y clangd
    fi
    success "C/C++ LSP 安裝完成"
}

# Dockerfile LSP
install_lsp_dockerfile() {
    info "安裝 Dockerfile LSP..."
    npm install -g dockerfile-language-server-nodejs
    success "Dockerfile LSP 安裝完成"
}

# 圖片處理庫（可選）
install_image_libs() {
    section "安裝圖片處理庫"
    
    if [ "$OS" = "macos" ]; then
        brew install imagemagick luajit luarocks
    else
        $SUDO apt install -y luajit libmagickwand-dev libgraphicsmagick1-dev luarocks
    fi
    
    $SUDO luarocks install magick
    success "圖片處理庫安裝完成"
}

# ==================== 根據模式安裝 ====================
section "安裝 LSP 服務器"

case $INSTALL_MODE in
    "full")
        info "完整安裝模式：安裝所有 LSP"
        install_lsp_markdown
        install_lsp_lua
        install_lsp_python
        install_lsp_bash
        install_lsp_yaml
        install_lsp_json
        install_lsp_go
        install_lsp_c
        install_lsp_dockerfile
        install_image_libs
        ;;
    "basic")
        info "基礎安裝模式：安裝常用 LSP"
        install_lsp_markdown
        install_lsp_lua
        install_lsp_python
        install_lsp_bash
        install_lsp_yaml
        install_lsp_json
        ;;
    "minimal")
        info "精簡安裝模式：跳過 LSP 安裝"
        ;;
esac

# ==================== 配置符號連結 ====================
section "配置 Neovim"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NVIM_CONFIG="$SCRIPT_DIR/nvim"

if [ ! -d "$NVIM_CONFIG" ]; then
    error "找不到 nvim 配置目錄: $NVIM_CONFIG"
    exit 1
fi

# 備份現有配置
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    info "備份現有配置 → $BACKUP"
    mv "$HOME/.config/nvim" "$BACKUP"
fi

# 創建符號連結
mkdir -p "$HOME/.config"
info "創建符號連結..."
ln -sf "$NVIM_CONFIG" "$HOME/.config/nvim"
success "Neovim 配置完成"
echo "  ~/.config/nvim -> $NVIM_CONFIG"

# ==================== 預防性修復 ====================
section "預防性修復（避免常見問題）"

# 1. 清理可能存在的問題鎖文件
if [ -f "$HOME/.config/nvim/lazy-lock.json" ]; then
    warning "發現 lazy-lock.json，備份並刪除以確保使用最新版本..."
    cp "$HOME/.config/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json.backup.$(date +%Y%m%d_%H%M%S)"
    rm "$HOME/.config/nvim/lazy-lock.json"
    success "已清理鎖文件"
fi

# 2. 清理 Neo-tree 狀態（避免狀態丟失錯誤）
if [ -d "$HOME/.local/share/nvim/neo-tree" ]; then
    info "清理 Neo-tree 舊狀態..."
    rm -rf "$HOME/.local/share/nvim/neo-tree"
    success "已清理 Neo-tree 狀態"
fi

# 3. 確保數據目錄權限正確
info "檢查目錄權限..."
mkdir -p "$HOME/.local/share/nvim"
mkdir -p "$HOME/.cache/nvim"
chmod -R 755 "$HOME/.local/share/nvim" 2>/dev/null || true
chmod -R 755 "$HOME/.cache/nvim" 2>/dev/null || true
success "權限檢查完成"

# 4. 驗證 bootstrap 代碼（檢查 init.lua）
if [ -f "$NVIM_CONFIG/init.lua" ]; then
    if grep -q "vim.uv or vim.loop" "$NVIM_CONFIG/init.lua"; then
        success "Bootstrap 代碼已是最新版本（兼容 0.10+/0.11+）"
    else
        warning "Bootstrap 代碼可能需要更新"
        info "如遇問題，請參考 MACOS_FIXES.md"
    fi
fi

success "預防性修復完成"

# ==================== 完成 ====================
echo ""
echo "════════════════════════════════════════════════════"
success "🎉 Neovim 環境安裝完成！"
echo "════════════════════════════════════════════════════"
echo ""
echo "📋 安裝摘要："
echo "  模式: $INSTALL_MODE"
echo "  OS: $OS"
echo "  已執行預防性修復：清理鎖文件、Neo-tree 狀態、權限檢查"
echo ""
echo "🚀 下一步："
echo ""
echo "1. 啟動 Neovim："
echo "   nvim"
echo ""
echo "2. 首次啟動會自動安裝插件，請等待完成"
echo "   - lazy.nvim 會自動 bootstrap"
echo "   - 所有插件會自動下載"
echo "   - LSP 服務器已預先安裝"
echo ""
echo "3. 如果遇到問題，檢查健康狀況："
echo "   :checkhealth"
echo "   :Lazy health"
echo ""
echo "4. 查看已安裝的 LSP："
echo "   :LspInfo"
if [ "$INSTALL_MODE" != "minimal" ]; then
    echo ""
    command -v marksman >/dev/null 2>&1 && echo "   ✓ Markdown (marksman)"
    command -v lua-language-server >/dev/null 2>&1 && echo "   ✓ Lua (lua-language-server)"
    command -v pyright >/dev/null 2>&1 && echo "   ✓ Python (pyright)"
    command -v bash-language-server >/dev/null 2>&1 && echo "   ✓ Bash (bash-language-server)"
    command -v yaml-language-server >/dev/null 2>&1 && echo "   ✓ YAML (yaml-language-server)"
    command -v gopls >/dev/null 2>&1 && echo "   ✓ Go (gopls)"
    command -v clangd >/dev/null 2>&1 && echo "   ✓ C/C++ (clangd)"
fi
echo ""
echo "════════════════════════════════════════════════════"
echo ""
