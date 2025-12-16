#!/bin/bash
# Lazinit 環境初始化腳本（增強版）
# 自動檢測環境並適配配置
# 
# 使用方式：
#   ./init_env.v2.sh         # 互動模式
#   ./init_env.v2.sh --all   # 自動安裝所有組件（無需確認）

set -e  # 遇到錯誤立即停止

# ==================== 參數處理 ====================
AUTO_INSTALL_ALL=false
if [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    AUTO_INSTALL_ALL=true
    echo "🚀 自動安裝模式：將安裝所有組件"
    echo ""
fi

# ==================== 顏色定義 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== 輸出函數 ====================
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

# ==================== 腳本目錄 ====================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ==================== 環境檢測 ====================
section "環境檢測"

# 檢測操作系統
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PKG_MANAGER="brew"
    info "檢測到 macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    PKG_MANAGER="apt"
    info "檢測到 Linux"
else
    error "不支援的操作系統: $OSTYPE"
    exit 1
fi

# 檢測是否為 VM
IS_VM=false
HOSTNAME=$(hostname)
if [[ "$HOSTNAME" =~ ^vm- ]] || [[ "$HOSTNAME" =~ -vm$ ]]; then
    IS_VM=true
    info "檢測到 VM 環境: $HOSTNAME"
elif [ "$OS" = "linux" ]; then
    # 檢查是否在虛擬化環境中
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        VIRT=$(systemd-detect-virt)
        if [ "$VIRT" != "none" ]; then
            IS_VM=true
            info "檢測到虛擬化環境: $VIRT"
        fi
    fi
    # 檢查記憶體（< 4GB 視為 VM）
    if [ -f /proc/meminfo ]; then
        TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        if [ "$TOTAL_MEM" -lt 4000000 ]; then
            IS_VM=true
            info "檢測到低記憶體環境 (< 4GB)"
        fi
    fi
fi

# 檢測用途（基於 hostname）
IS_WORK=false
if [[ "$HOSTNAME" =~ work ]] || [[ "$HOSTNAME" =~ office ]]; then
    IS_WORK=true
    warning "檢測到工作環境"
fi

# 總結環境
echo ""
info "環境摘要:"
echo "  OS: $OS"
echo "  Package Manager: $PKG_MANAGER"
echo "  VM: $IS_VM"
echo "  Work: $IS_WORK"
echo "  Hostname: $HOSTNAME"
echo ""

# ==================== 安裝必需工具 ====================
section "安裝必需工具"

# 確定是否需要 sudo
SUDO="sudo"
if [ "$(id -u)" == "0" ]; then
    SUDO=""
    warning "以 root 運行，不使用 sudo"
fi

# 安裝 zsh 和 git（必需）
REQUIRED_TOOLS=""
if ! command -v zsh >/dev/null 2>&1; then
    REQUIRED_TOOLS="$REQUIRED_TOOLS zsh"
fi
if ! command -v git >/dev/null 2>&1; then
    REQUIRED_TOOLS="$REQUIRED_TOOLS git"
fi

if [ -n "$REQUIRED_TOOLS" ]; then
    warning "缺少必需工具:$REQUIRED_TOOLS"
    info "正在自動安裝..."
    
    if [ "$OS" = "macos" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            error "未安裝 Homebrew，請先安裝: https://brew.sh"
            exit 1
        fi
        brew install$REQUIRED_TOOLS
    else
        $SUDO apt update
        $SUDO apt install -y$REQUIRED_TOOLS
    fi
    
    success "必需工具安裝完成"
    hash -r  # 刷新命令哈希表
else
    success "必需工具已安裝"
fi

# 再次確認 zsh 已安裝
if ! command -v zsh >/dev/null 2>&1; then
    error "zsh 安裝失敗，無法繼續"
    exit 1
fi

echo ""

# ==================== 選擇包列表 ====================
section "選擇安裝包列表"

if [ "$IS_VM" = true ]; then
    PKG_LIST_FILE="init_apt_pks.vm"
    info "使用 VM 精簡版包列表"
    
    # 如果不存在，創建精簡版
    if [ ! -f "$PKG_LIST_FILE" ]; then
        warning "VM 包列表不存在，從完整版創建精簡版..."
        # 去掉重量級工具
        grep -v -E 'btop|nvtop|glances|fastfetch|neofetch' init_apt_pks > "$PKG_LIST_FILE" || true
        success "已創建 $PKG_LIST_FILE"
    fi
elif [ "$OS" = "macos" ]; then
    PKG_LIST_FILE="init_brew_pks"
    info "使用 macOS brew 包列表"
    
    # 如果不存在，創建 macOS 版本
    if [ ! -f "$PKG_LIST_FILE" ]; then
        warning "macOS 包列表不存在，從 Linux 版本轉換..."
        # 轉換包名（Linux → macOS）
        cat init_apt_pks | sed \
            -e 's/batcat/bat/g' \
            -e 's/fd-find/fd/g' \
            -e 's/openssh-server/openssh/g' \
            > "$PKG_LIST_FILE"
        success "已創建 $PKG_LIST_FILE"
    fi
else
    PKG_LIST_FILE="init_apt_pks"
    info "使用完整版包列表"
fi

if [ ! -f "$PKG_LIST_FILE" ]; then
    error "找不到包列表文件: $PKG_LIST_FILE"
    exit 1
fi

success "包列表: $PKG_LIST_FILE"

# ==================== 過濾可用的包 ====================
section "檢查包可用性"

rm -rf actual_apt_pks 2>/dev/null || true

if [ "$OS" = "macos" ]; then
    # macOS: 直接使用，brew 會處理不存在的包
    cat "$PKG_LIST_FILE" > actual_apt_pks
    success "macOS: 將使用所有列出的包"
else
    # Linux: 檢查 apt 可用性並過濾已安裝的包
    info "檢查 apt 包可用性..."
    
    PACKAGES_TO_INSTALL=""
    
    for pkg in $(cat "$PKG_LIST_FILE" | tr ' ' '\n'); do
        if [ -z "$pkg" ]; then continue; fi
        
        # 檢查包是否存在於倉庫
        if ! apt-cache show "$pkg" >/dev/null 2>&1; then
            warning "跳過 $pkg (倉庫中不存在)"
            continue
        fi
        
        # 檢查包是否已安裝
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            info "跳過 $pkg (已安裝)"
            continue
        fi
        
        # 檢查是否有安裝候選
        if apt-cache policy "$pkg" | grep -q 'Candidate: (none)'; then
            warning "跳過 $pkg (無安裝候選)"
            continue
        fi
        
        # 添加到安裝列表
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    done
    
    # 寫入文件
    echo "$PACKAGES_TO_INSTALL" | tr -s ' ' > actual_apt_pks
    
    if [ -n "$PACKAGES_TO_INSTALL" ]; then
        success "待安裝的包:$PACKAGES_TO_INSTALL"
    else
        success "所有包都已安裝"
    fi
fi

# ==================== 安裝包 ====================
section "安裝其他軟件包"

if [ "$OS" = "macos" ]; then
    # macOS 使用 brew
    if ! command -v brew >/dev/null 2>&1; then
        error "未安裝 Homebrew，請先安裝: https://brew.sh"
        exit 1
    fi
    
    info "更新 Homebrew..."
    brew update
    
    info "安裝包..."
    brew install $(cat actual_apt_pks)
    
    success "macOS 包安裝完成"
else
    # Linux 使用 apt
    info "更新 apt..."
    $SUDO apt update
    
    info "升級系統..."
    $SUDO apt upgrade -y
    
    # 檢查是否有包需要安裝
    PACKAGES=$(cat actual_apt_pks | tr -s ' ')
    if [ -n "$PACKAGES" ]; then
        info "安裝包..."
        $SUDO apt install $PACKAGES -y
        success "Linux 包安裝完成"
    else
        success "沒有新包需要安裝"
    fi
    
    # 刷新命令哈希表，确保新安装的命令可用
    hash -r
fi

# ==================== 配置 ZSH ====================
section "配置 ZSH"

ZSHP="$SCRIPT_DIR/zsh"

if [ ! -d "$ZSHP" ]; then
    error "找不到 zsh 目录: $ZSHP"
    exit 1
fi

cd ~

# 備份現有配置
if [ -f .zshrc ] && [ ! -L .zshrc ]; then
    BACKUP=".zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    info "備份現有 .zshrc → $BACKUP"
    mv .zshrc "$BACKUP"
fi

if [ -d .zsh ] && [ ! -L .zsh ]; then
    BACKUP=".zsh.backup.$(date +%Y%m%d_%H%M%S)"
    info "備份現有 .zsh → $BACKUP"
    mv .zsh "$BACKUP"
fi

# 修改前 (原本的樣子):
# ZP=$(realpath --relative-to="$HOME" "$ZSHP" 2>/dev/null || python3 -c "import os.path; print(os.path.relpath('$ZSHP', '$HOME'))")

# 修改後 (加入防呆):
if [ -n "$ZSHP" ]; then
    ZP=$(realpath --relative-to="$HOME" "$ZSHP" 2>/dev/null || python3 -c "import os.path; print(os.path.relpath('$ZSHP', '$HOME'))")
else
    echo "Warning: ZSHP variable is empty, skipping path calculation."
    ZP=""
fi

info "創建符號連結..."
ln -sf "$ZP/zshrc" .zshrc
ln -sf "$ZP/zsh" .zsh

success "ZSH 配置完成"
echo "  ~/.zshrc -> $ZP/zshrc"
echo "  ~/.zsh   -> $ZP/zsh"

# ==================== 編譯 ZSH 配置 ====================
section "編譯 ZSH 配置"

if command -v zsh >/dev/null 2>&1; then
    if [ -x "$ZSHP/utils/recompile.sh" ]; then
        info "運行編譯腳本..."
        "$ZSHP/utils/recompile.sh"
    else
        info "手動編譯配置..."
        zsh -c "zcompile ~/.zshrc"
        success "配置編譯完成"
    fi
else
    warning "zsh 未安裝，跳過編譯"
fi

# ==================== 工作環境特殊處理 ====================
if [ "$IS_WORK" = true ]; then
    section "工作環境配置"
    
    if [ ! -f ~/.zshrc.local ]; then
        info "創建工作環境配置 ~/.zshrc.local"
        cat > ~/.zshrc.local << 'EOF'
# 工作環境配置
# Proxy 設置（請根據實際情況修改）
# export http_proxy="http://proxy.company.com:8080"
# export https_proxy="http://proxy.company.com:8080"
# export no_proxy="localhost,127.0.0.1,.company.local"

# 工作專用工具路徑
# export PATH=$PATH:/opt/company-tools/bin

EOF
        success "已創建 ~/.zshrc.local，請根據需要編輯"
    else
        info "~/.zshrc.local 已存在"
    fi
fi

# ==================== 個人化配置提示 ====================
if [ ! -f ~/.zshrc.local ]; then
    section "個人化配置"
    info "創建個人化配置文件 ~/.zshrc.local"
    cat > ~/.zshrc.local << 'EOF'
# ~/.zshrc.local - 機器特定的配置
# 此文件不會被 git 追蹤

# 範例：個人 alias
# alias myproject='cd ~/projects/myproject'

# 範例：機器特定的 PATH
# export PATH=$PATH:/opt/local/bin

# 範例：環境變數
# export EDITOR=nvim

EOF
    success "已創建 ~/.zshrc.local"
fi

# ==================== 設置預設 shell ====================
section "設置預設 Shell"

if ! command -v zsh >/dev/null 2>&1; then
    warning "zsh 未安裝，跳過設置預設 shell"
    if [ "$AUTO_INSTALL_ALL" = true ]; then
        error "自動模式需要先安裝 zsh，請檢查包安裝是否成功"
    fi
elif [ "$SHELL" != "$(command -v zsh)" ]; then
    warning "當前預設 shell 不是 zsh"
    echo ""
    
    # 自動模式或互動模式
    if [ "$AUTO_INSTALL_ALL" = true ]; then
        info "自動設置 zsh 為預設 shell..."
        REPLY="y"
    else
        read -p "是否將 zsh 設為預設 shell? [y/N] " -n 1 -r
        echo
    fi
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ "$OS" = "macos" ]; then
            if chsh -s "$(command -v zsh)"; then
                success "預設 shell 已設為 zsh（需要重新登入生效）"
            else
                error "設置失敗"
            fi
        else
            if $SUDO chsh -s "$(command -v zsh)" "$USER"; then
                success "預設 shell 已設為 zsh（需要重新登入生效）"
            else
                error "設置失敗，請手動執行: sudo chsh -s $(command -v zsh) $USER"
            fi
        fi
    fi
else
    success "預設 shell 已經是 zsh"
fi

# ==================== 完成 ====================
echo ""
echo "════════════════════════════════════════════════════"
success "🎉 Lazinit 初始化完成！"
echo "════════════════════════════════════════════════════"
echo ""
echo "📋 環境信息："
echo "  OS: $OS"
echo "  VM: $IS_VM"
echo "  Work: $IS_WORK"
echo ""
echo "📦 已安裝包列表: actual_apt_pks"
echo ""
echo "🚀 下一步："
echo ""
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "1. 重新登入以使用 zsh"
else
    echo "1. 啟動新的 shell："
    echo "   exec zsh"
fi
echo ""
echo "2. 編輯個人化配置（可選）："
echo "   vim ~/.zshrc.local"
echo ""
if [ "$IS_WORK" = true ]; then
    echo "3. 設置工作環境 proxy（如需要）："
    echo "   vim ~/.zshrc.local  # 取消註釋 proxy 設置"
    echo ""
fi
echo "3. 安裝其他組件（可選）："
echo "   Neovim + LSP 環境："
echo "     cd $SCRIPT_DIR/neovim && ./install.v2.sh"
echo ""
echo "   或直接運行："
echo "     $SCRIPT_DIR/neovim/install.v2.sh"
echo ""
echo "4. 其他可用組件："
echo "   - Docker:    $SCRIPT_DIR/install_docker_apt.sh"
echo "   - Fcitx5:    $SCRIPT_DIR/fcitx5.install.sh"
echo ""
echo "════════════════════════════════════════════════════"
echo ""
info "提示：首次啟動 zsh 可能需要下載插件，請稍等片刻"

# 提供快速安裝選項
if [ -t 0 ] || [ "$AUTO_INSTALL_ALL" = true ]; then
    echo ""
    
    # 自動模式或互動模式
    if [ "$AUTO_INSTALL_ALL" = true ]; then
        info "自動安裝 Neovim + LSP 環境..."
        REPLY="y"
    else
        read -p "是否現在安裝 Neovim + LSP 環境? [y/N] " -n 1 -r
        echo
    fi
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        section "安裝 Neovim 環境"
        if [ -x "$SCRIPT_DIR/neovim/install.v2.sh" ]; then
            "$SCRIPT_DIR/neovim/install.v2.sh"
        else
            error "找不到 neovim/install.v2.sh 或無執行權限"
        fi
    fi
fi

echo ""
