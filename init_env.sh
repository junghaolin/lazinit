#!/bin/bash
# Lazinit 環境初始化腳本（函數式架構）
# 自動檢測環境並適配配置
# 
# 使用方式：
#   ./init_env.v3.sh                    # 互動模式
#   ./init_env.v3.sh --all              # 自動安裝所有組件
#   ./init_env.v3.sh --zsh              # 只安裝 ZSH
#   ./init_env.v3.sh --neovim           # 只安裝 Neovim
#   ./init_env.v3.sh --docker           # 只安裝 Docker
#   ./init_env.v3.sh --general          # 只安裝通用軟件包

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
    if [ $# -eq 0 ]; then
        # 無參數，互動模式
        return
    fi
    
    for arg in "$@"; do
        case $arg in
            --all|-a)
                AUTO_INSTALL_ALL=true
                INSTALL_ZSH=true
                INSTALL_NEOVIM=true
                INSTALL_DOCKER=true
                INSTALL_GENERAL=true
                INSTALL_TMUX=true
                ;;
            --zsh)
                INSTALL_ZSH=true
                ;;
            --neovim)
                INSTALL_NEOVIM=true
                ;;
            --tmux)
                INSTALL_TMUX=true
                ;;
            --git)
                INSTALL_GIT=true
                ;;
            --docker)
                INSTALL_DOCKER=true
                ;;
            --general)
                INSTALL_GENERAL=true
                ;;
            --help|-h)
                echo "使用方式："
                echo "  $0           # 互動模式"
                echo "  $0 --all     # 安裝所有組件"
                echo "  $0 --zsh     # 只安裝 ZSH"
                echo "  $0 --neovim  # 只安裝 Neovim"
                echo "  $0 --tmux    # 只安裝 Tmux 配置"
                echo "  $0 --docker  # 只安裝 Docker"
                echo "  $0 --general # 只安裝通用軟件包"
                exit 0
                ;;
            *)
                error "未知參數: $arg"
                echo "使用 --help 查看幫助"
                exit 1
                ;;
        esac
    done
}

# ==================== 環境檢測 ====================
detect_environment() {
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
        if command -v systemd-detect-virt >/dev/null 2>&1; then
            VIRT=$(systemd-detect-virt 2>/dev/null || echo "none")
            if [ "$VIRT" != "none" ] && [ -n "$VIRT" ]; then
                IS_VM=true
                info "檢測到虛擬化環境: $VIRT"
            fi
        fi
        if [ -f /proc/meminfo ]; then
            TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}') || TOTAL_MEM=999999999
            if [ "$TOTAL_MEM" -lt 4000000 ]; then
                IS_VM=true
                info "檢測到低記憶體環境 (< 4GB)"
            fi
        fi
    fi
    
    # 檢測用途
    IS_WORK=false
    if [[ "$HOSTNAME" =~ work ]] || [[ "$HOSTNAME" =~ office ]]; then
        IS_WORK=true
        warning "檢測到工作環境"
    fi
    
    # 確定是否需要 sudo
    SUDO="sudo"
    if [ "$(id -u)" == "0" ]; then
        SUDO=""
        warning "以 root 運行，不使用 sudo"
    fi
    
    # 總結
    echo ""
    info "環境摘要:"
    echo "  OS: $OS"
    echo "  Package Manager: $PKG_MANAGER"
    echo "  VM: $IS_VM"
    echo "  Work: $IS_WORK"
    echo "  Hostname: $HOSTNAME"
    echo ""
}

# ==================== 安裝 ZSH ====================
install_zsh() {
    section "安裝和配置 ZSH"
    
    # 1. 確保 zsh 和 git 已安裝
    local REQUIRED_TOOLS=""
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
            brew install$REQUIRED_TOOLS
        else
            $SUDO apt update
            $SUDO apt install -y$REQUIRED_TOOLS
        fi
        
        success "工具安裝完成"
        hash -r
    else
        success "zsh 和 git 已安裝"
    fi
    
    # 2. 配置 ZSH
    local ZSHP="$SCRIPT_DIR/zsh"
    if [ ! -d "$ZSHP" ]; then
        error "找不到 zsh 配置目錄: $ZSHP"
        return 1
    fi
    
    cd ~
    
    # 備份現有配置
    if [ -f .zshrc ] && [ ! -L .zshrc ]; then
        local BACKUP=".zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        info "備份現有 .zshrc → $BACKUP"
        mv .zshrc "$BACKUP"
    fi
    
    if [ -d .zsh ] && [ ! -L .zsh ]; then
        local BACKUP=".zsh.backup.$(date +%Y%m%d_%H%M%S)"
        info "備份現有 .zsh → $BACKUP"
        mv .zsh "$BACKUP"
    fi
    
    # 創建符號連結
    info "創建符號連結..."
    [ -L ~/.zshrc ] && rm ~/.zshrc
    [ -L ~/.zsh ] && rm ~/.zsh
    
    ln -sf "$ZSHP/zshrc" ~/.zshrc
    ln -sf "$ZSHP/zsh" ~/.zsh
    
    success "ZSH 配置完成"
    echo "  ~/.zshrc -> $ZSHP/zshrc"
    echo "  ~/.zsh   -> $ZSHP/zsh"
    echo ""
    
    # 3. 安裝 zinit
    if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
        info "安裝 zinit 插件管理器..."
        mkdir -p "$HOME/.local/share/zinit"
        chmod g-rwX "$HOME/.local/share/zinit"
        git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" 2>/dev/null
        success "zinit 安裝完成"
    else
        success "zinit 已安裝"
    fi
    
    # 4. 編譯配置
    if command -v zsh >/dev/null 2>&1; then
        info "編譯 ZSH 配置..."
        if [ -x "$ZSHP/utils/recompile.sh" ]; then
            "$ZSHP/utils/recompile.sh"
        else
            zsh -c "zcompile ~/.zshrc" 2>/dev/null || true
            success "配置編譯完成"
        fi
    fi
    
    # 5. 創建個人化配置
    if [ ! -f "$HOME/.zshrc.local" ]; then
        info "創建個人化配置文件 ~/.zshrc.local"
        cat > "$HOME/.zshrc.local" << 'EOF'
# ~/.zshrc.local - 機器特定的配置
# 此檔案不會被 git 追蹤，可以放置機器特定的設置

# 範例：工作環境特定的配置
# export WORK_PROJECT_PATH=/path/to/work

# 範例：臨時測試的 alias
# alias mytest='echo "testing"'

# 範例：機器特定的 PATH
# export PATH=$PATH:/opt/custom/bin

EOF
        success "已創建 ~/.zshrc.local"
    else
        success "~/.zshrc.local 已存在"
    fi
    
    # 6. 設置預設 shell
    if [ "$SHELL" != "$(command -v zsh)" ]; then
        warning "當前預設 shell 不是 zsh"
        
        if [ "$AUTO_INSTALL_ALL" = true ]; then
            info "自動設置 zsh 為預設 shell..."
            local REPLY="y"
        else
            read -p "是否將 zsh 設為預設 shell? [y/N] " -n 1 -r
            echo
        fi
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ "$OS" = "macos" ]; then
                chsh -s "$(command -v zsh)" && success "預設 shell 已設為 zsh"
            else
                $SUDO chsh -s "$(command -v zsh)" "$USER" && success "預設 shell 已設為 zsh（需重新登入生效）"
            fi
        fi
    else
        success "預設 shell 已經是 zsh"
    fi
    
    # 7. 配置 Powerlevel10k 主題
    if [ ! -f "$HOME/.p10k.zsh" ]; then
        if [ -f "$ZSHP/p10k.zsh" ]; then
            info "複製 Powerlevel10k 預設配置..."
            cp "$ZSHP/p10k.zsh" "$HOME/.p10k.zsh"
            success "Powerlevel10k 主題已配置"
        else
            info "首次啟動 zsh 時會自動配置 Powerlevel10k 主題"
        fi
    else
        success "Powerlevel10k 配置已存在"
    fi
    
    echo ""
}

# ==================== 安裝通用軟件包 ====================
install_general() {
    section "安裝通用軟件包"
    
    # 選擇包列表
    local PKG_LIST_FILE
    if [ "$IS_VM" = true ]; then
        PKG_LIST_FILE="$SCRIPT_DIR/init_apt_pks.vm"
        info "使用 VM 精簡版包列表"
        
        if [ ! -f "$PKG_LIST_FILE" ]; then
            warning "VM 包列表不存在，從完整版創建精簡版..."
            grep -v -E 'btop|nvtop|glances|fastfetch|neofetch' "$SCRIPT_DIR/init_apt_pks" > "$PKG_LIST_FILE" || true
            success "已創建 $PKG_LIST_FILE"
        fi
    elif [ "$OS" = "macos" ]; then
        PKG_LIST_FILE="$SCRIPT_DIR/init_brew_pks"
        info "使用 macOS brew 包列表"
        
        if [ ! -f "$PKG_LIST_FILE" ]; then
            warning "macOS 包列表不存在，從 Linux 版本轉換..."
            cat "$SCRIPT_DIR/init_apt_pks" | sed \
                -e 's/batcat/bat/g' \
                -e 's/fd-find/fd/g' \
                -e 's/openssh-server/openssh/g' \
                > "$PKG_LIST_FILE"
            success "已創建 $PKG_LIST_FILE"
        fi
    else
        PKG_LIST_FILE="$SCRIPT_DIR/init_apt_pks"
        info "使用完整版包列表"
    fi
    
    if [ ! -f "$PKG_LIST_FILE" ]; then
        error "找不到包列表文件: $PKG_LIST_FILE"
        return 1
    fi
    
    # 過濾待安裝的包
    info "檢查包可用性..."
    local PACKAGES_TO_INSTALL=""
    
    for pkg in $(cat "$PKG_LIST_FILE" | tr ' ' '\n'); do
        [ -z "$pkg" ] && continue
        
        if [ "$OS" = "macos" ]; then
            # macOS: brew 會自動處理
            PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
        else
            # Linux: 檢查包狀態
            if ! apt-cache show "$pkg" >/dev/null 2>&1; then
                warning "跳過 $pkg (倉庫中不存在)"
                continue
            fi
            
            if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
                info "跳過 $pkg (已安裝)"
                continue
            fi
            
            if apt-cache policy "$pkg" | grep -q 'Candidate: (none)'; then
                warning "跳過 $pkg (無安裝候選)"
                continue
            fi
            
            PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
        fi
    done
    
    # 安裝包
    if [ -n "$PACKAGES_TO_INSTALL" ]; then
        success "待安裝的包:$PACKAGES_TO_INSTALL"
        
        if [ "$OS" = "macos" ]; then
            brew update
            brew install $PACKAGES_TO_INSTALL
        else
            $SUDO apt update
            $SUDO apt upgrade -y
            $SUDO apt install -y $PACKAGES_TO_INSTALL
        fi
        
        success "軟件包安裝完成"
        hash -r
    else
        success "所有包都已安裝"
    fi
    
    echo ""
}

# ==================== 安裝 Neovim ====================
install_neovim() {
    section "安裝 Neovim + LSP 環境"
    
    local NEOVIM_INSTALLER="$SCRIPT_DIR/neovim/install.sh"
    
    if [ ! -x "$NEOVIM_INSTALLER" ]; then
        error "找不到 Neovim 安裝腳本: $NEOVIM_INSTALLER"
        info "請檢查文件是否存在並有執行權限"
        return 1
    fi
    
    info "運行 Neovim 安裝腳本..."
    "$NEOVIM_INSTALLER"
    
    echo ""
}

# ==================== 安裝 Tmux ====================
install_tmux() {
    section "安裝 Tmux 配置"
    
    local TMUX_INSTALLER="$SCRIPT_DIR/tmux/install.sh"
    
    if [ ! -x "$TMUX_INSTALLER" ]; then
        error "找不到 Tmux 安裝腳本: $TMUX_INSTALLER"
        info "請檢查文件是否存在並有執行權限"
        return 1
    fi
    
    info "運行 Tmux 安裝腳本..."
    "$TMUX_INSTALLER"
    
    echo ""
}

# ==================== 安裝 Git ====================
install_git() {
    section "安裝 Git 配置"
    
    local GIT_INSTALLER="$SCRIPT_DIR/git/install.sh"
    
    if [ ! -x "$GIT_INSTALLER" ]; then
        error "找不到 Git 安裝腳本: $GIT_INSTALLER"
        info "請檢查文件是否存在並有執行權限"
        return 1
    fi
    
    info "運行 Git 安裝腳本..."
    "$GIT_INSTALLER"
    
    echo ""
}

# ==================== 安裝 Docker ====================
install_docker() {
    section "安裝 Docker"
    
    local DOCKER_INSTALLER="$SCRIPT_DIR/install_docker_apt.sh"
    
    if [ ! -x "$DOCKER_INSTALLER" ]; then
        error "找不到 Docker 安裝腳本: $DOCKER_INSTALLER"
        info "請檢查文件是否存在並有執行權限"
        return 1
    fi
    
    info "運行 Docker 安裝腳本..."
    "$DOCKER_INSTALLER"
    
    echo ""
}

# ==================== 互動選擇 ====================
interactive_menu() {
    section "選擇要安裝的組件"
    
    echo "可用組件："
    echo "  1) ZSH 配置環境"
    echo "  2) 通用軟件包 (eza, bat, ripgrep, 等)"
    echo "  3) Neovim + LSP 環境"
    echo "  4) Tmux 配置"
    echo "  5) Git 配置"
    echo "  6) Docker"
    echo "  7) 全部安裝"
    echo "  0) 退出"
    echo ""
    
    read -p "請選擇 (可多選，用空格分隔，如: 1 2 3): " choices
    
    for choice in $choices; do
        case $choice in
            1) INSTALL_ZSH=true ;;
            2) INSTALL_GENERAL=true ;;
            3) INSTALL_NEOVIM=true ;;
            4) INSTALL_TMUX=true ;;
            5) INSTALL_GIT=true ;;
            6) INSTALL_DOCKER=true ;;
            7)
                INSTALL_ZSH=true
                INSTALL_GENERAL=true
                INSTALL_NEOVIM=true
                INSTALL_TMUX=true
                INSTALL_GIT=true
                INSTALL_DOCKER=true
                ;;
            0) exit 0 ;;
            *) warning "未知選項: $choice" ;;
        esac
    done
    
    echo ""
}

# ==================== 主流程 ====================
main() {
    echo "════════════════════════════════════════════════════"
    echo "  🚀 Lazinit 環境初始化腳本"
    echo "════════════════════════════════════════════════════"
    echo ""
    
    # 解析參數
    parse_args "$@"
    
    # 檢測環境
    detect_environment
    
    # 如果沒有指定任何安裝選項，進入互動模式
    if [ "$INSTALL_ZSH" = false ] && \
       [ "$INSTALL_GENERAL" = false ] && \
       [ "$INSTALL_NEOVIM" = false ] && \
       [ "$INSTALL_TMUX" = false ] && \
       [ "$INSTALL_DOCKER" = false ]; then
        interactive_menu
    fi
    
    # 執行安裝任務
    if [ "$INSTALL_ZSH" = true ]; then
        install_zsh
    fi
    
    if [ "$INSTALL_GENERAL" = true ]; then
        install_general
    fi
    
    if [ "$INSTALL_NEOVIM" = true ]; then
        install_neovim
    fi
    
    if [ "$INSTALL_TMUX" = true ]; then
        install_tmux
    fi
    
    if [ "$INSTALL_GIT" = true ]; then
        install_git
    fi
    
    if [ "$INSTALL_DOCKER" = true ]; then
        install_docker
    fi
    
    # 完成提示
    section "安裝完成"
    success "🎉 所有選定的組件已安裝完成！"
    echo ""
    
    if [ "$INSTALL_ZSH" = true ]; then
        echo "📋 ZSH 下一步："
        echo "   exec zsh              # 立即啟動 zsh"
        echo "   cat ~/lazinit/zsh/QUICKREF.md  # 查看快速參考"
        echo ""
    fi
    
    echo "🔧 其他可用腳本："
    [ -f "$SCRIPT_DIR/fcitx5.install.sh" ] && echo "   $SCRIPT_DIR/fcitx5.install.sh  # 安裝 Fcitx5 輸入法"
    echo ""
}

# 執行主流程
main "$@"
