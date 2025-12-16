# Neovim 配置分析報告

## 📁 目錄結構
```
neovim/
├── install.sh              # 安裝腳本（含 LSP 服務器）
├── marksman.tar.gz         # Markdown LSP 二進制
└── nvim/                   # Neovim 配置目錄
    ├── init.lua            # 主配置文件
    ├── lazy-lock.json      # Lazy.nvim 插件鎖定版本
    ├── lazyvim.json        # LazyVim 配置
    ├── rocks.toml          # Lua rocks 配置
    └── lua/plugins/        # 插件配置
        ├── comment.lua     # 註釋插件
        ├── completion.lua  # 自動補全
        ├── editor.lua      # 編輯器增強
        ├── lsp.lua         # LSP 配置
        ├── ui.lua          # UI 相關
        └── utils.lua       # 工具插件
```

---

## 🔍 install.sh 分析

### 功能概覽
這是一個**全功能** LSP 開發環境安裝腳本：

#### 1. 基礎依賴
```bash
- git
- nvm (Node Version Manager)
- Node.js LTS
```

#### 2. 已安裝的 LSP 服務器
| 語言 | LSP 服務器 | 安裝方式 |
|------|-----------|---------|
| **Markdown** | marksman | 二進制下載 |
| **Lua** | lua-language-server | 源碼編譯 |
| **YAML** | yaml-language-server | npm |
| **Go** | gopls | go install |
| **C/C++** | clangd | apt |
| **Bash** | bash-language-server | npm |
| **Python** | pyright | npm |
| **JSON** | vscode-langservers-extracted | npm |
| **Dockerfile** | dockerfile-language-server-nodejs | npm |

#### 3. 額外依賴
```bash
- ninja-build, build-essential (編譯工具)
- golang
- luajit
- libmagickwand-dev, libgraphicsmagick1-dev (圖片處理)
- luarocks + magick (Lua 圖片庫)
```

---

## ⚠️ 發現的問題

### 1. **重複安裝 lua-language-server** ❌
```bash
# 第 38-39 行：
sudo mv build/bin/main.lua /usr/local/bin/
# 第 41-42 行：
sudo mkdir -p /opt
sudo mv build/bin/main.lua /opt/   # ← 文件已經被移走了！
```
**問題**：第二次 `mv` 會失敗，因為文件已經不存在。

**建議修復**：
```bash
# 應該是複製整個目錄
sudo mkdir -p /opt/lua-language-server
sudo cp -r build/bin/* /opt/lua-language-server/
sudo ln -sf /opt/lua-language-server/lua-language-server /usr/local/bin/
```

### 2. **硬編碼 Linux 平台** ⚠️
```bash
# 第 21 行：
curl -L -o marksman.tar.gz \
  https://github.com/.../marksman-linux.tar.gz
```
**問題**：macOS 上無法使用。

**建議**：根據系統選擇：
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    MARKSMAN_URL="marksman-macos.tar.gz"
else
    MARKSMAN_URL="marksman-linux.tar.gz"
fi
```

### 3. **假設 sudo 權限** ⚠️
所有 `sudo` 操作沒有檢查權限或提供降級方案。

### 4. **缺少錯誤處理** ⚠️
- 沒有 `set -e`
- 編譯失敗不會停止
- 網路失敗不會重試

### 5. **在 /tmp 編譯** ⚠️
```bash
cd /tmp
git clone ...
```
如果重啟機器，/tmp 可能被清空，編譯產物丟失。

---

## 💡 Neovim 配置分析

### init.lua
- ✅ 使用 Lazy.nvim 作為插件管理器
- ✅ 基本設置合理（leader key, clipboard, tab width）
- ✅ 使用 Treesitter 折疊

### 插件配置（lua/plugins/）

#### 1. LSP (lsp.lua)
```lua
- nvim-lspconfig
- 配置了 9 種語言的 LSP
- nvim-treesitter (語法高亮)
```

#### 2. 補全 (completion.lua)
```lua
- nvim-cmp (補全引擎)
- LuaSnip (代碼片段)
- 多種補全源（LSP、buffer、path、cmdline）
```

#### 3. 註釋 (comment.lua)
```lua
- Comment.nvim
- gcc: 註釋單行
- gbc: 註釋塊
```

#### 4. 編輯器 (editor.lua)
```lua
- vim-numbertoggle (行號切換)
- which-key.nvim (快捷鍵提示)
```

#### 5. UI (ui.lua)
```lua
- (需要查看完整文件)
```

---

## 🚀 改進建議

### 優先級 1：修復 install.sh 錯誤
```bash
# 1. 添加錯誤處理
set -e
set -o pipefail

# 2. 修復 lua-language-server 安裝
# 3. 添加平台檢測
# 4. 檢查權限
```

### 優先級 2：跨平台支持
```bash
# 根據 OS 選擇安裝方式
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: 用 brew 安裝 LSP
    brew install lua-language-server gopls
else
    # Linux: 源碼編譯或 apt
fi
```

### 優先級 3：可選安裝
```bash
# 讓用戶選擇要安裝哪些 LSP
echo "選擇要安裝的 LSP："
echo "1) 全部"
echo "2) 基礎 (Lua, Python, Bash)"
echo "3) Web (JSON, YAML, Dockerfile)"
echo "4) 系統語言 (C/C++, Go)"
```

### 優先級 4：VM 優化
```bash
# VM 環境跳過重量級工具
if [ "$IS_VM" = true ]; then
    # 跳過圖片處理庫
    # 只裝基礎 LSP
fi
```

---

## 📝 建議的新 install.sh 結構

```bash
#!/bin/bash
# Neovim + LSP 安裝腳本（增強版）

set -e

# 1. 環境檢測
detect_environment() {
    # 檢測 OS, VM 等
}

# 2. 安裝基礎工具
install_base() {
    # git, nvm, node
}

# 3. 安裝 Lazy.nvim
install_lazy() {
    # 插件管理器
}

# 4. 安裝 LSP (模組化)
install_lsp_markdown() { ... }
install_lsp_lua() { ... }
install_lsp_python() { ... }
...

# 5. 配置符號連結
setup_config() {
    ln -sf $(pwd)/nvim ~/.config/nvim
}

# 6. 主流程
main() {
    detect_environment
    install_base
    install_lazy
    
    # 根據環境選擇性安裝 LSP
    if [ "$FULL_INSTALL" = true ]; then
        install_all_lsp
    else
        install_basic_lsp
    fi
    
    setup_config
}

main "$@"
```

---

## 🎯 總結

### ✅ 優點
1. 功能完整（9 種語言 LSP）
2. 使用現代插件管理器（Lazy.nvim）
3. 配置結構清晰（模組化）

### ❌ 需改進
1. 修復 lua-language-server 安裝錯誤
2. 添加跨平台支持（macOS）
3. 添加錯誤處理
4. 可選安裝（不要強制全裝）
5. VM 環境優化

### 📋 下一步
1. 修復當前 install.sh 的 bug
2. 創建增強版（跨平台 + 可選）
3. 測試 macOS 和 Linux
4. 添加到主 init_env.sh 的可選步驟

---

**要不要我幫你創建修復版的 install.sh？**
