#!/bin/bash
# ZSH 配置安裝腳本
# 用途：在新主機上快速部署優化後的 ZSH 配置

set -e  # 遇到錯誤立即停止

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：輸出帶顏色的訊息
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# 函數：檢查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函數：創建備份
backup_if_exists() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        info "備份現有檔案: $file -> $backup"
        mv "$file" "$backup"
        success "備份完成"
    fi
}

echo "════════════════════════════════════════════════════"
echo "  🚀 ZSH 優化配置安裝腳本"
echo "════════════════════════════════════════════════════"
echo ""

# 1. 檢查並安裝必要工具
info "檢查必要工具..."
MISSING_TOOLS=""

if ! command_exists zsh; then
    MISSING_TOOLS="$MISSING_TOOLS zsh"
fi

if ! command_exists git; then
    MISSING_TOOLS="$MISSING_TOOLS git"
fi

if [ -n "$MISSING_TOOLS" ]; then
    warning "缺少必要工具:$MISSING_TOOLS"
    info "正在自動安裝..."
    
    # 檢查是否為 apt 系統（Debian/Ubuntu）
    if command_exists apt; then
        sudo apt update || { error "apt update 失敗"; exit 1; }
        sudo apt install -y$MISSING_TOOLS || { error "安裝失敗"; exit 1; }
        success "工具安裝完成"
    # 檢查是否為 yum 系統（RHEL/CentOS）
    elif command_exists yum; then
        sudo yum install -y$MISSING_TOOLS || { error "安裝失敗"; exit 1; }
        success "工具安裝完成"
    # 檢查是否為 dnf 系統（Fedora）
    elif command_exists dnf; then
        sudo dnf install -y$MISSING_TOOLS || { error "安裝失敗"; exit 1; }
        success "工具安裝完成"
    # 檢查是否為 pacman 系統（Arch）
    elif command_exists pacman; then
        sudo pacman -Sy --noconfirm$MISSING_TOOLS || { error "安裝失敗"; exit 1; }
        success "工具安裝完成"
    # 檢查是否為 brew 系統（macOS）
    elif command_exists brew; then
        brew install$MISSING_TOOLS || { error "安裝失敗"; exit 1; }
        success "工具安裝完成"
    else
        error "無法識別的套件管理器"
        info "請手動安裝: sudo apt install$MISSING_TOOLS"
        exit 1
    fi
else
    success "所有必要工具已安裝"
fi
echo ""

# 2. 確認當前目錄
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAZINIT_DIR="$(dirname "$SCRIPT_DIR")"

info "配置目錄: $LAZINIT_DIR"

if [ ! -f "$SCRIPT_DIR/zshrc" ]; then
    error "找不到 zshrc 檔案，請確認在正確的目錄執行此腳本"
    exit 1
fi

success "配置檔案檢查通過"
echo ""

# 3. 備份現有配置
info "備份現有配置..."
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.zsh"
success "備份完成"
echo ""

# 4. 創建符號連結
info "創建符號連結..."

# 刪除舊的符號連結（如果存在）
[ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -L "$HOME/.zsh" ] && rm "$HOME/.zsh"

# 創建新的符號連結
ln -sf "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$SCRIPT_DIR/zsh" "$HOME/.zsh"

success "符號連結已創建:"
echo "  ~/.zshrc -> $SCRIPT_DIR/zshrc"
echo "  ~/.zsh   -> $SCRIPT_DIR/zsh"
echo ""

# 5. 安裝 zinit（如果不存在）
if [ ! -d "$HOME/.local/share/zinit/zinit.git" ]; then
    info "安裝 zinit 插件管理器..."
    mkdir -p "$HOME/.local/share/zinit"
    chmod g-rwX "$HOME/.local/share/zinit"
    git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" 2>/dev/null
    success "zinit 安裝完成"
else
    success "zinit 已安裝"
fi
echo ""

# 6. 編譯配置
info "編譯 ZSH 配置以加速啟動..."
if [ -x "$SCRIPT_DIR/utils/recompile.sh" ]; then
    "$SCRIPT_DIR/utils/recompile.sh"
else
    # 手動編譯
    zsh -c "zcompile $HOME/.zshrc"
    cd "$HOME/.zsh"
    for file in lazy_*_v2.zsh utils/check_alias.zsh; do
        [ -f "$file" ] && zsh -c "zcompile $file"
    done
    success "配置編譯完成"
fi
echo ""

# 7. 檢查並安裝推薦工具
info "檢查推薦工具..."
RECOMMENDED_TOOLS=()

command_exists exa || command_exists eza || RECOMMENDED_TOOLS+=("eza")
command_exists nvim || RECOMMENDED_TOOLS+=("neovim")
command_exists rg || RECOMMENDED_TOOLS+=("ripgrep")
command_exists batcat || command_exists bat || RECOMMENDED_TOOLS+=("bat")
command_exists grc || RECOMMENDED_TOOLS+=("grc")
command_exists fd || RECOMMENDED_TOOLS+=("fd-find")

if [ ${#RECOMMENDED_TOOLS[@]} -gt 0 ]; then
    warning "以下推薦工具未安裝:"
    for tool in "${RECOMMENDED_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "這些工具會在首次使用時自動安裝（需要 sudo 權限）"
    echo "或者你可以現在手動安裝:"
    echo "  sudo apt install ${RECOMMENDED_TOOLS[*]}"
else
    success "所有推薦工具已安裝"
fi
echo ""

# 8. 設置 zsh 為預設 shell（可選）
if [ "$SHELL" != "$(command -v zsh)" ]; then
    warning "當前預設 shell 不是 zsh"
    read -p "是否將 zsh 設為預設 shell? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "設置 zsh 為預設 shell..."
        chsh -s "$(command -v zsh)"
        success "預設 shell 已設置為 zsh（需要重新登入生效）"
    fi
    echo ""
fi

# 9. 創建個人化配置檔案（如果不存在）
if [ ! -f "$HOME/.zshrc.local" ]; then
    info "創建個人化配置檔案 ~/.zshrc.local"
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
echo ""

# 10. 完成
echo "════════════════════════════════════════════════════"
success "🎉 安裝完成！"
echo "════════════════════════════════════════════════════"
echo ""
echo "📋 下一步："
echo ""
echo "1. 重新載入配置："
echo "   exec zsh"
echo ""
echo "2. 或開啟新終端以使用新配置"
echo ""
echo "3. 測試啟動速度："
echo "   time zsh -i -c exit"
echo ""
echo "4. 查看快速參考："
echo "   cat $SCRIPT_DIR/QUICKREF.md"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
info "提示：首次啟動可能需要下載 zinit 插件，請稍等片刻"
echo ""
