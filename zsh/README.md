# ZSH 配置 - 快速開始

## 🚀 新主機安裝

### 一鍵安裝
```bash
cd ~/lazinit/zsh
./install.sh
```

安裝腳本會自動：
- ✅ 檢查必要工具（zsh, git）
- ✅ 備份現有配置
- ✅ 創建符號連結
- ✅ 安裝 zinit 插件管理器
- ✅ 編譯所有配置檔案
- ✅ 創建個人化配置檔案

### 手動安裝
```bash
# 1. 創建符號連結
ln -sf ~/lazinit/zsh/zshrc ~/.zshrc
ln -sf ~/lazinit/zsh/zsh ~/.zsh

# 2. 編譯配置
~/lazinit/zsh/utils/recompile.sh

# 3. 重新載入
exec zsh
```

## 🔧 日常維護

### 修改配置後
```bash
# 1. 編輯配置
vim ~/lazinit/zsh/zshrc

# 2. 重新編譯
~/lazinit/zsh/utils/recompile.sh

# 3. 重新載入
source ~/.zshrc
```

### 更新插件
```bash
zinit update --all
```

## 📦 Git 管理

### 提交變更
```bash
cd ~/lazinit
git add zsh/
git commit -m "Update zsh config"
git push
```

### 同步到其他機器
```bash
# 機器 A（修改）
cd ~/lazinit
git push

# 機器 B（同步）
cd ~/lazinit
git pull
~/lazinit/zsh/utils/recompile.sh
source ~/.zshrc
```

## 📚 詳細文檔

- [QUICKREF.md](QUICKREF.md) - 快速參考卡片
- [UPGRADE_SUMMARY.md](UPGRADE_SUMMARY.md) - 完整升級報告
- [SYMLINK_SETUP.md](SYMLINK_SETUP.md) - 符號連結設置指南
- [DIRECTORY_STRUCTURE.md](DIRECTORY_STRUCTURE.md) - 目錄結構說明

## ⚡ 常用命令

```bash
# GRC 彩色命令（使用 g 前綴）
gping 8.8.8.8    # 彩色 ping
gps aux          # 彩色 ps
gdf -h           # 彩色 df

# 其他工具
ls               # exa/eza
vi file          # nvim
g "pattern"      # ripgrep
c file           # bat

# 歷史搜尋
Ctrl+K           # 往上搜尋
Ctrl+J           # 往下搜尋
```

## 🐛 問題排查

```bash
# 檢查符號連結
ls -la ~/.zshrc ~/.zsh

# 測試啟動速度
time zsh -i -c exit

# 重新編譯配置
rm -f ~/.zshrc.zwc ~/.zsh/*.zwc ~/.zsh/utils/*.zwc
~/lazinit/zsh/utils/recompile.sh
```
