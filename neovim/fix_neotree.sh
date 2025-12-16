#!/bin/bash
# Neo-tree 状态丢失修复脚本
# 用于解决 "attempt to index local 'tree' (a nil value)" 错误

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Neo-tree 状态丢失修复工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查配置目录
NVIM_CONFIG="${HOME}/.config/nvim"
NVIM_DATA="${HOME}/.local/share/nvim"

if [ ! -d "$NVIM_CONFIG" ]; then
    error "找不到 Neovim 配置目录: $NVIM_CONFIG"
    exit 1
fi

info "Neovim 配置目录: $NVIM_CONFIG"
info "Neovim 数据目录: $NVIM_DATA"
echo ""

# 步骤 1: 备份 lazy-lock.json
if [ -f "$NVIM_CONFIG/lazy-lock.json" ]; then
    info "备份 lazy-lock.json..."
    cp "$NVIM_CONFIG/lazy-lock.json" "$NVIM_CONFIG/lazy-lock.json.backup.$(date +%Y%m%d_%H%M%S)"
    success "备份完成"
else
    warning "未找到 lazy-lock.json（可能是首次安装）"
fi

# 步骤 2: 清理插件缓存
info "清理插件缓存和状态文件..."

# 清理 Neo-tree 状态
if [ -d "$NVIM_DATA/neo-tree" ]; then
    rm -rf "$NVIM_DATA/neo-tree"
    success "已清理 Neo-tree 状态"
fi

# 清理 lazy.nvim 缓存
if [ -d "$NVIM_DATA/lazy" ]; then
    warning "即将清理所有插件（将重新下载）"
    read -p "是否继续? [y/N]: " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$NVIM_DATA/lazy"
        success "已清理插件缓存"
    else
        info "跳过清理"
    fi
fi

# 步骤 3: 删除 lazy-lock.json
info "删除 lazy-lock.json（将重新生成）..."
if [ -f "$NVIM_CONFIG/lazy-lock.json" ]; then
    rm "$NVIM_CONFIG/lazy-lock.json"
    success "已删除 lazy-lock.json"
fi

echo ""
success "修复准备完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  下一步操作"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 启动 Neovim:"
echo "   nvim"
echo ""
echo "2. 等待插件自动安装完成"
echo ""
echo "3. 手动更新插件（如果需要）:"
echo "   :Lazy update"
echo ""
echo "4. 重启 Neovim 测试 Neo-tree:"
echo "   <Space>e"
echo ""
echo "如果问题仍然存在，请运行:"
echo "   :checkhealth neo-tree"
echo ""
