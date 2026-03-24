# 🚀 Lazinit: 極速環境初始化與 Dotfiles 精選

Lazinit 是一套專為高效工程師打造的環境初始化工具。它不僅能一鍵部署 Zsh、Neovim、Tmux 和 Git，更能根據設備性能自動調整配置，從旗艦級工作站到極簡的樹莓派開發板皆能完美適配。

## ✨ 核心特色

- **模組化設計**：Zsh, Neovim, Tmux, Git 均為獨立模組，可分開安裝或一鍵整合。
- **環境感知**：支援「豪華旗艦版」與「極簡開發版 (Minimal)」。
- **效能優化**：Zsh 插件延遲載入、NVM/Conda 懶載入，確保啟動時間 < 0.2s。
- **現代體驗**：
  - **Neovim**：基於 LazyVim 的結構化配置，支援 ToggleTerm 與全語言 LSP。
  - **Tmux**：上方分頁列樣式、完美系統剪貼簿同步、防滑鼠跨界複製。
  - **Git**：內建神級彩色歷史樹 (`git lg`) 與自動化工作流。

---

## 🚀 快速開始 (Quick Start)

首先克隆此倉庫：
```bash
git clone https://github.com/junghaolin/lazinit.git ~/lazinit
cd ~/lazinit
```

### 1. 完整旗艦體驗 (工作站 / 筆電)
這會安裝所有插件、LSP 服務器及 Zsh 美化環境。
```bash
./init_env.sh --all
```

### 2. 極簡開發環境 (樹莓派 / 伺服器 / 資源受限設備)
這會跳過 Zsh (使用 Bash)，僅安裝 Tmux、極簡版 Neovim 與核心導航工具。
```bash
./init_env.sh --minimal
```

### 3. 互動選單模式
自定義你想安裝的組件：
```bash
./init_env.sh
```

---

## 🛠 模組詳解

### 💻 Neovim
- **核心**：結構化 Lua 配置，易於維護。
- **導航**：使用 `fzf-lua` (極簡模式) 或 `Telescope` (完整模式)。
- **終端**：按 `<Space> t` 切換下方 1/3 高度的浮動終端。
- **故障排除**：若插件出錯，執行 `./neovim/install.sh --reinstall` 深度清理重置。

### 🐚 Zsh
- **主題**：Powerlevel10k (自動配置)。
- **外掛**：語法高亮、自動建議、Tab 補全美化。
- **速度**：NVM 與 Conda 僅在首次使用時載入，絕不拖慢 Shell 啟動。

### 🪟 Tmux
- **分頁**：狀態列移至頂部，現代分頁列質感。
- **剪貼簿**：支援滑鼠拖曳直接複製到系統剪貼簿 (OSC 52)。
- **快速鍵**：Prefix 改為 `Ctrl + a`，支援 Vim 風格視窗切換。

### 🌿 Git
- **縮寫**：`git st` (狀態), `git cm` (提交), `git lg` (彩色樹狀圖)。
- **配置**：自動 Rebase、自動設定遠端追蹤、全域忽略垃圾檔案。

---

## 💡 內建小抄 (Cheat Sheets)

別擔心記不住快捷鍵，我們內建了專屬命令：
- 輸入 `tmux-help`：查看 Tmux 常用快捷鍵。
- 輸入 `nvim-help`：查看 Neovim 導航與編輯快捷鍵。

---

## 📂 目錄結構

```text
~/lazinit/
├── init_env.sh      # 主控台安裝腳本 (v3 完全體)
├── zsh/             # Zsh 模組配置與 p10k 主題
├── neovim/          # Neovim 配置 (含 Full/Minimal 雙模式)
├── tmux/            # Tmux 模組與頂部分頁列配置
├── git/             # Git 模組與全域忽略配置
└── utils/           # 輔助工具 (小抄、維護腳本)
```

## 📝 個人化
如有機器特定的配置，請寫在 `~/.zshrc.local`，此檔案已被 Git 忽略，不會被同步。
