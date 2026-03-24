#!/bin/bash
# Neovim + LSP 環境安裝腳本（增強版）
# 支援跨平台、可選安裝、環境檢測、極簡模式

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

# ==================== 深度清理 (Reinstall Mode) ====================
if [ "$REINSTALL_DEEP" = true ]; then
    section "執行深度清理"
    
    info "清理 Lazy.nvim 插件目錄..."
    rm -rf "$HOME/.local/share/nvim/lazy"
    
    info "清理 Treesitter 解析器..."
    rm -rf "$HOME/.local/share/nvim/site/parser"
    
    info "清理 Lua 快取..."
    rm -rf "$HOME/.cache/nvim/luac"
    rm -rf "$HOME/.cache/nvim/luac.mac"
    
    info "清理 Mason 安裝的二進位檔與狀態..."
    rm -rf "$HOME/.local/share/nvim/mason"
    
    info "清理 Neovim 狀態紀錄 (Shada, Logs)..."
    rm -rf "$HOME/.local/state/nvim"
    
    success "深度清理完成"
fi

# ==================== 安裝模式選擇 ====================
if [ "$INSTALL_MINIMAL" = true ]; then
    INSTALL_MODE="minimal"
elif [ "$IS_VM" = true ]; then
    INSTALL_MODE="minimal"
    info "自動選擇精簡模式（VM 環境）"
else
    section "安裝模式選擇"
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
        
        if [ "$INSTALL_MINIMAL" = false ]; then
            read -p "是否重新安裝/更新到 0.11.5? [y/N]: " reinstall
            if [[ ! $reinstall =~ ^[Yy]$ ]]; then
                info "跳過 Neovim 安裝"
                return
            fi
        else
            info "極簡模式：保留現有 Neovim"
            return
        fi
    fi
    
    if [ "$OS" = "macos" ]; then
        info "使用 Homebrew 安裝 Neovim..."
        brew install neovim
        success "Neovim 安裝完成"
    else
        info "下載 Neovim 0.11.5 AppImage..."
        wget -q --show-progress -O /tmp/nvim.appimage \
            https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
        if ! command -v fusermount >/dev/null 2>&1; then
            info "安裝 FUSE 依賴..."
            $SUDO apt update
            $SUDO apt install -y fuse libfuse2
        fi
        chmod +x /tmp/nvim.appimage
        $SUDO mv /tmp/nvim.appimage /usr/local/bin/nvim
        success "Neovim 0.11.5 安裝完成"
    fi
}

install_neovim

# ==================== 基礎工具安裝 ====================
section "安裝基礎工具"

install_base_tools() {
    if [ "$OS" = "macos" ]; then
        info "使用 Homebrew 安裝基礎工具..."
        brew install git curl wget fd lazygit ripgrep
    else
        info "使用 apt 安裝基礎工具..."
        $SUDO apt update
        
        if [ "$INSTALL_MINIMAL" = true ]; then
            # 極簡模式：只裝最核心的二進位工具，不裝 python 支援
            $SUDO apt install -y git curl wget fd-find ripgrep
        else
            # 完整模式：包含 python 支援
            $SUDO apt install -y git curl wget fd-find python3-pynvim ripgrep
        fi
        
        if command -v fdfind >/dev/null 2>&1; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        fi
        
        # 只有在非極簡模式下才主動裝 lazygit (因為它體積較大且需要從網路下載)
        if [ "$INSTALL_MINIMAL" = false ] && ! command -v lazygit >/dev/null 2>&1; then
            info "安裝 lazygit..."
            local LAZYGIT_VERSION
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            if [ -n "$LAZYGIT_VERSION" ]; then
                curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                tar xf lazygit.tar.gz lazygit
                $SUDO install lazygit /usr/local/bin
                rm lazygit.tar.gz lazygit
            fi
        fi
    fi
    success "基礎工具安裝完成"
}

install_base_tools

# ==================== NVM + Node.js ====================
install_nvm() {
    section "安裝 NVM 和 Node.js"
    if [ -d "$HOME/.nvm" ]; then
        info "NVM 已安裝"
    else
        info "安裝 NVM..."
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        success "NVM 安裝完成"
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if ! command -v node >/dev/null 2>&1; then
        info "安裝 Node.js LTS..."
        nvm install --lts
        success "Node.js 安裝完成"
    fi
}

if [ "$INSTALL_MINIMAL" = false ] && [ "$INSTALL_MODE" != "minimal" ]; then
    install_nvm
fi

# ==================== LSP 安裝函數 (省略內容以保持腳本可讀性) ====================
# [這些函數如 install_lsp_lua, install_lsp_python 等保持不變]
install_lsp_markdown() {
    if command -v marksman >/dev/null 2>&1; then return; fi
    local DOWNLOAD_URL
    if [ "$OS" = "macos" ]; then
        DOWNLOAD_URL="https://github.com/artempyanykh/marksman/releases/latest/download/marksman-macos-x64"
    else
        DOWNLOAD_URL="https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64"
    fi
    curl -fsSL -o /tmp/marksman "$DOWNLOAD_URL" && chmod +x /tmp/marksman && $SUDO mv /tmp/marksman /usr/local/bin/
}
install_lsp_lua() {
    if command -v lua-language-server >/dev/null 2>&1; then return; fi
    if [ "$OS" = "macos" ]; then brew install lua-language-server; else
        $SUDO apt install -y ninja-build git build-essential
        cd /tmp && rm -rf lua-language-server && git clone https://github.com/LuaLS/lua-language-server.git
        cd lua-language-server && git submodule update --init --recursive
        cd 3rd/luamake && ./compile/install.sh && cd ../.. && ./3rd/luamake/luamake rebuild
        $SUDO mkdir -p /opt/lua-language-server && $SUDO cp -r build/bin/* /opt/lua-language-server/
        $SUDO ln -sf /opt/lua-language-server/lua-language-server /usr/local/bin/lua-language-server
    fi
}
install_lsp_python() { npm install -g pyright; }
install_lsp_bash() { npm install -g bash-language-server; }
install_lsp_yaml() { npm install -g yaml-language-server; }
install_lsp_json() { npm install -g vscode-langservers-extracted; }
install_lsp_go() { if [ "$OS" != "macos" ]; then $SUDO apt install -y golang; fi; go install golang.org/x/tools/gopls@latest; }
install_lsp_c() { if [ "$OS" != "macos" ]; then $SUDO apt install -y clangd; fi; }
install_lsp_dockerfile() { npm install -g dockerfile-language-server-nodejs; }
install_image_libs() {
    if [ "$OS" = "macos" ]; then brew install imagemagick luajit luarocks; else
        $SUDO apt install -y luajit libmagickwand-dev libgraphicsmagick1-dev luarocks; fi
    $SUDO luarocks install magick
}

# ==================== 根據模式安裝 LSP ====================
section "安裝組件"

if [ "$INSTALL_MINIMAL" = true ]; then
    success "極簡模式：跳過 LSP 與圖片庫安裝"
else
    case $INSTALL_MODE in
        "full")
            install_lsp_markdown; install_lsp_lua; install_lsp_python; install_lsp_bash; install_lsp_yaml
            install_lsp_json; install_lsp_go; install_lsp_c; install_lsp_dockerfile; install_image_libs ;;
        "basic")
            install_lsp_markdown; install_lsp_lua; install_lsp_python; install_lsp_bash; install_lsp_yaml; install_lsp_json ;;
    esac
fi

# ==================== 配置符號連結 ====================
section "配置 Neovim"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NVIM_CONFIG="$SCRIPT_DIR/nvim"

# 決定使用哪份 init.lua
if [ "$INSTALL_MINIMAL" = true ]; then
    info "極簡模式：套用 init.minimal.lua"
    # 備份原本的 init.lua (如果是完整版)
    if [ -f "$NVIM_CONFIG/init.lua" ] && ! grep -q "Minimal Mode" "$NVIM_CONFIG/init.lua"; then
        mv "$NVIM_CONFIG/init.lua" "$NVIM_CONFIG/init.lua.full.backup"
    fi
    cp "$NVIM_CONFIG/init.minimal.lua" "$NVIM_CONFIG/init.lua"
else
    # 完整模式：還原 init.lua
    if [ -f "$NVIM_CONFIG/init.lua.full.backup" ]; then
        mv "$NVIM_CONFIG/init.lua.full.backup" "$NVIM_CONFIG/init.lua"
    fi
fi

# 建立符號連結
mkdir -p "$HOME/.config"
ln -sf "$NVIM_CONFIG" "$HOME/.config/nvim"
success "配置完成: ~/.config/nvim -> $NVIM_CONFIG"

# ==================== 預防性修復 ====================
section "預防性修復"
git config --global core.autocrlf false
git config --global core.fileMode false
rm -f "$HOME/.config/nvim/lazy-lock.json"
rm -rf "$HOME/.local/share/nvim/neo-tree"
success "修復完成"

echo -e "\n${GREEN}🎉 Neovim 安裝完成！${NC}"
[ "$INSTALL_MINIMAL" = true ] && info "目前處於【極簡模式】，僅包含 fzf 導航與基礎語法高亮。"
