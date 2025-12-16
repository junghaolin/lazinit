# 自动修复说明

## ✨ 安装脚本已内置预防性修复

从现在开始，运行 `install.v2.sh` 或 `install.sh` 时，脚本会**自动执行预防性修复**，无需手动干预。

### 🔧 自动修复内容

#### 1. 清理问题锁文件
```bash
# 自动备份并删除 lazy-lock.json
# 避免版本冲突和依赖问题
```

#### 2. 清理 Neo-tree 状态
```bash
# 删除 ~/.local/share/nvim/neo-tree/
# 避免 "attempt to index local 'tree' (a nil value)" 错误
```

#### 3. 检查目录权限
```bash
# 确保 ~/.local/share/nvim 和 ~/.cache/nvim 权限正确
# 避免权限相关错误
```

#### 4. 验证 Bootstrap 代码
```bash
# 检查 init.lua 中的 bootstrap 代码是否是最新版本
# 确保兼容 Neovim 0.10+ 和 0.11+
```

---

## 🚀 使用方法

### 新环境安装

```bash
cd ~/lazinit/neovim
./install.v2.sh
```

**就这样！** 脚本会自动：
1. 安装 Neovim
2. 安装 LSP
3. 创建符号链接
4. **执行预防性修复**
5. 显示完成信息

### 首次启动

```bash
nvim
```

- lazy.nvim 自动 bootstrap ✅
- 插件自动下载 ✅
- 无需手动修复 ✅

---

## 📋 修复日志

安装时会看到：

```
━━━ 預防性修復（避免常見問題） ━━━

⚠ 發現 lazy-lock.json，備份並刪除以確保使用最新版本...
✓ 已清理鎖文件
ℹ 清理 Neo-tree 舊狀態...
✓ 已清理 Neo-tree 狀態
ℹ 檢查目錄權限...
✓ 權限檢查完成
✓ Bootstrap 代碼已是最新版本（兼容 0.10+/0.11+）
✓ 預防性修復完成
```

---

## 🔍 如果仍遇到问题

### 1. 检查健康状况
```vim
:checkhealth
:Lazy health
```

### 2. 手动清理（终极方案）
```bash
cd ~/lazinit/neovim
./fix_neotree.sh
```

### 3. 查看日志
```vim
:messages
```

---

## 🎉 优势

### 之前
1. 运行 install.sh
2. 启动 nvim
3. 遇到错误
4. 查文档找解决方案
5. 手动运行 fix_neotree.sh
6. 重启 nvim

### 现在
1. 运行 install.v2.sh
2. 启动 nvim
3. **完美运行** ✨

---

## 📊 覆盖的问题

| 问题 | 自动修复 | 手动修复工具 |
|------|---------|-------------|
| lazy.nvim 未安装 | ✅ Bootstrap | - |
| 版本冲突 | ✅ 清理锁文件 | fix_neotree.sh |
| Neo-tree 状态丢失 | ✅ 清理状态 | fix_neotree.sh |
| 目录权限错误 | ✅ 自动修复 | chmod 755 |
| Bootstrap 过时 | ✅ 自动检测 | MACOS_FIXES.md |

---

## 💡 技术细节

### install.v2.sh 中的修复代码
```bash
# 1. 清理锁文件
if [ -f "$HOME/.config/nvim/lazy-lock.json" ]; then
    cp ... && rm ...
fi

# 2. 清理 Neo-tree
if [ -d "$HOME/.local/share/nvim/neo-tree" ]; then
    rm -rf ...
fi

# 3. 修复权限
chmod -R 755 ...

# 4. 验证 bootstrap
if grep -q "vim.uv or vim.loop" ...; then
    # 已是最新版本
fi
```

### init.lua 中的 Bootstrap
```lua
-- 兼容 0.10 和 0.11
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    -- 自动克隆 + 错误处理
    if vim.v.shell_error ~= 0 then
        -- 友好错误提示
    end
end
```

---

*最后更新：2025-12-16*
*适用于：Linux + macOS*
