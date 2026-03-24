#!/bin/bash
# Lazinit 環境初始化腳本（函數式架構 - 穩定版）
# 自動檢測環境並適配配置

set -e  # 遇到錯誤立即停止

# ==================== 全局變量 ====================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AUTO_INSTALL_ALL=false
INSTALL_ZSH=false
INSTALL_NEOVIM=false
INSTALL_DOCKER=false
INSTALL_GENERAL=false
INSTALL_TMUX=false
INSTALL_GIT=false
INSTALL_MINIMAL=false

# 環境變量
OS=""
PKG_MANAGER=""
IS_VM=false
IS_WORK=false
SUDO="sudo"
HOSTNAME=""

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

# ==================== 參數處理 ====================
parse_args() {
    if [ $# -eq 0 ]; then return; fi
    
    for arg in "$@"; do
        case $arg in
            --all|-a)
                AUTO_INSTALL_ALL=true
                INSTALL_ZSH=true; INSTALL_NEOVIM=true; INSTALL_DOCKER=true
                INSTALL_GENERAL=true; INSTALL_TMUX=true; INSTALL_GIT=true
                ;;
            --minimal)
                INSTALL_MINIMAL=true
                INSTALL_TMUX=true; INSTALL_NEOVIM=true; INSTALL_GIT=true; INSTALL_GENERAL=true
                ;;
            --zsh) INSTALL_ZSH=true ;;
            --neovim) INSTALL_NEOVIM=true ;;
            --tmux) INSTALL_TMUX=true ;;
            --git) INSTALL_GIT=true ;;
            --docker) INSTALL_DOCKER=true ;;
            --general) INSTALL_GENERAL=true ;;
            --help|-h)
                echo "使用方式："
                echo "  $0           # 互動模式"
                echo "  $0 --all     # 安裝所有組件"
                echo "  $0 --minimal # 極簡開發環境 (Tmux + Minimal Neovim)"
                echo "  $0 --zsh     # 只安裝 ZSH"
                echo "  $0 --neovim  # 只安裝 Neovim"
                echo "  $0 --tmux    # 只安裝 Tmux 配置"
                echo "  $0 --git     # 只安裝 Git 配置"
                echo "  $0 --docker  # 只安裝 Docker"
                echo "  $0 --general # 只安裝通用軟件包"
                exit 0 ;;
            *) error "未知參數: $arg"; exit 1 ;;
        esac
    done
}

# ==================== 環境檢測 ====================
detect_environment() {
    section "環境檢測"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"; PKG_MANAGER="brew"; info "檢測到 macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"; PKG_MANAGER="apt"; info "檢測到 Linux"
    else
        error "不支援的操作系統: $OSTYPE"; exit 1
    fi
    
    IS_VM=false
    HOSTNAME=$(hostname)
    if [[ "$HOSTNAME" =~ ^vm- ]] || [[ "$HOSTNAME" =~ -vm$ ]]; then
        IS_VM=true; info "檢測到 VM 環境: $HOSTNAME"
    elif [ "$OS" = "linux" ]; then
        if command -v systemd-detect-virt >/dev/null 2>&1; then
            VIRT=$(systemd-detect-virt 2>/dev/null || echo "none")
            if [ "$VIRT" != "none" ] && [ -n "$VIRT" ]; then
                IS_VM=true; info "檢測到虛擬化環境: $VIRT"
            fi
        fi
        if [ -f /proc/meminfo ]; then
            TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}') || TOTAL_MEM=999999999
            if [ "$TOTAL_MEM" -lt 4000000 ]; then
                IS_VM=true; info "檢測到低記憶體環境 (< 4GB)"
            fi
        fi
    fi
    
    IS_WORK=false
    if [[ "$HOSTNAME" =~ work ]] || [[ "$HOSTNAME" =~ office ]]; then
        IS_WORK=true; warning "檢測到工作環境"
    fi
    
    SUDO="sudo"
    if [ "$(id -u)" == "0" ]; then
        SUDO=""; warning "以 root 運行，不使用 sudo"
    fi
}

# ==================== 安裝 ZSH ====================
install_zsh() {
    section "安裝和配置 ZSH"
    local REQUIRED_TOOLS=""
    if ! command -v zsh >/dev/null 2>&1; then REQUIRED_TOOLS="$REQUIRED_TOOLS zsh"; fi
    if ! command -v git >/dev/null 2>&1; then REQUIRED_TOOLS="$REQUIRED_TOOLS git"; fi
    
    if [ -n "$REQUIRED_TOOLS" ]; then
        info "正在安裝必需工具: $REQUIRED_TOOLS"
        if [ "$OS" = "macos" ]; then
            brew install $REQUIRED_TOOLS
        else
            $SUDO apt update && $SUDO apt install -y $REQUIRED_TOOLS
        fi
    fi
    
    local ZSHP="$SCRIPT_DIR/zsh"
    if [ ! -d "$ZSHP" ]; then error "找不到 zsh 配置目錄"; return 1; fi
    
    cd ~
    if [ -f .zshrc ] && [ ! -L .zshrc ]; then mv .zshrc ".zshrc.backup.$(date +%Y%m%d_%H%M%S)"; fi
    if [ -d .zsh ] && [ ! -L .zsh ]; then mv .zsh ".zsh.backup.$(date +%Y%m%d_%H%M%S)"; fi
    
    ln -sf "$ZSHP/zshrc" ~/.zshrc
    ln -sf "$ZSHP/zsh" ~/.zsh
    success "ZSH 配置完成"
    
    if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
        git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" 2>/dev/null || true
    fi
    
    if command -v zsh >/dev/null 2>&1; then
        if [ -x "$ZSHP/utils/recompile.sh" ]; then
            "$ZSHP/utils/recompile.sh" || true
        else
            zsh -c "zcompile ~/.zshrc" 2>/dev/null || true
        fi
    fi
}

# ==================== 安裝通用軟件包 ====================
install_general() {
    section "安裝通用軟件包"
    local PKG_LIST_FILE="$SCRIPT_DIR/init_apt_pks"
    if [ "$IS_VM" = true ]; then PKG_LIST_FILE="$SCRIPT_DIR/init_apt_pks.vm"; fi
    if [ "$INSTALL_MINIMAL" = true ]; then PKG_LIST_FILE="$SCRIPT_DIR/init_apt_pks.minimal"; fi
    
    info "使用包列表: $(basename $PKG_LIST_FILE)"
    info "檢查包可用性..."
    local PACKAGES_TO_INSTALL=""
    for pkg in $(cat "$PKG_LIST_FILE" | tr ' ' '\n'); do
        [ -z "$pkg" ] && continue
        if [ "$OS" = "linux" ]; then
            if ! apt-cache show "$pkg" >/dev/null 2>&1; then continue; fi
            if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then continue; fi
        fi
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    done
    
    if [ -n "$PACKAGES_TO_INSTALL" ]; then
        if [ "$OS" = "macos" ]; then
            brew update && brew install $PACKAGES_TO_INSTALL
        else
            $SUDO apt update && $SUDO apt upgrade -y && $SUDO apt install -y $PACKAGES_TO_INSTALL
        fi
    fi
}

# ==================== 安裝 Neovim ====================
install_neovim() {
    section "安裝 Neovim 環境"
    local NEOVIM_INSTALLER="$SCRIPT_DIR/neovim/install.sh"
    local ARGS=""
    if [ "$INSTALL_MINIMAL" = true ]; then ARGS="--minimal"; fi
    
    if [ -x "$NEOVIM_INSTALLER" ]; then
        "$NEOVIM_INSTALLER" $ARGS
    else
        error "找不到 Neovim 安裝腳本"
    fi
}

# ==================== 安裝 Tmux ====================
install_tmux() {
    section "安裝 Tmux 配置"
    local TMUX_INSTALLER="$SCRIPT_DIR/tmux/install.sh"
    if [ -x "$TMUX_INSTALLER" ]; then
        "$TMUX_INSTALLER"
    else
        error "找不到 Tmux 安裝腳本"
    fi
}

# ==================== 安裝 Git ====================
install_git() {
    section "安裝 Git 配置"
    local GIT_INSTALLER="$SCRIPT_DIR/git/install.sh"
    if [ -x "$GIT_INSTALLER" ]; then
        "$GIT_INSTALLER"
    else
        error "找不到 Git 安裝腳本"
    fi
}

# ==================== 安裝 Docker ====================
install_docker() {
    section "安裝 Docker"
    local DOCKER_INSTALLER="$SCRIPT_DIR/install_docker_apt.sh"
    if [ -x "$DOCKER_INSTALLER" ]; then
        "$DOCKER_INSTALLER"
    else
        error "找不到 Docker 安裝腳本"
    fi
}

# ==================== 互動選擇 ====================
interactive_menu() {
    section "選擇要安裝的組件"
    echo "可用組件："
    echo "  1) ZSH 配置環境"
    echo "  2) 通用軟件包 (eza, bat, ripgrep, 等)"
    echo "  3) Neovim + LSP 完整環境"
    echo "  4) Tmux 配置"
    echo "  5) Git 配置"
    echo "  6) Docker"
    echo "  7) 【極簡開發環境】 (Tmux + Minimal Neovim + Git)"
    echo "  8) 全部安裝"
    echo "  0) 退出"
    echo ""
    read -p "請選擇: " choices
    for choice in $choices; do
        case $choice in
            1) INSTALL_ZSH=true ;;
            2) INSTALL_GENERAL=true ;;
            3) INSTALL_NEOVIM=true ;;
            4) INSTALL_TMUX=true ;;
            5) INSTALL_GIT=true ;;
            6) INSTALL_DOCKER=true ;;
            7) INSTALL_MINIMAL=true; INSTALL_TMUX=true; INSTALL_NEOVIM=true; INSTALL_GIT=true; INSTALL_GENERAL=true ;;
            8) INSTALL_ZSH=true; INSTALL_GENERAL=true; INSTALL_NEOVIM=true; INSTALL_TMUX=true; INSTALL_GIT=true; INSTALL_DOCKER=true ;;
            0) exit 0 ;;
        esac
    done
}

# ==================== 主流程 ====================
main() {
    echo "════════════════════════════════════════════════════"
    echo "  🚀 Lazinit 環境初始化腳本"
    echo "════════════════════════════════════════════════════"
    parse_args "$@"
    detect_environment
    
    if [ "$INSTALL_ZSH" = false ] && [ "$INSTALL_GENERAL" = false ] && [ "$INSTALL_NEOVIM" = false ] && \
       [ "$INSTALL_TMUX" = false ] && [ "$INSTALL_GIT" = false ] && [ "$INSTALL_DOCKER" = false ] && \
       [ "$INSTALL_MINIMAL" = false ]; then
        interactive_menu
    fi
    
    if [ "$INSTALL_ZSH" = true ]; then install_zsh; fi
    if [ "$INSTALL_GENERAL" = true ]; then install_general; fi
    if [ "$INSTALL_TMUX" = true ]; then install_tmux; fi
    if [ "$INSTALL_GIT" = true ]; then install_git; fi
    if [ "$INSTALL_NEOVIM" = true ]; then install_neovim; fi
    if [ "$INSTALL_DOCKER" = true ]; then install_docker; fi
    
    success "🎉 初始化完成！"
}

main "$@"
