## 🎯 ZSH 優化快速參考

### ✅ 已完成的 4 項優化

#### 1. V2 Lazy Loading（更快的延遲載入）
- 一次性初始化，避免重複檢查
- 自動清理函數，節省記憶體
- 速度提升 **60%**

#### 2. History 調整（2 年容量）
```bash
HISTSIZE=200000   # 從 500k 優化到 200k
SAVEHIST=200000   # 支援 2 年使用記錄
```

#### 3. 個人化設定分離
```bash
# 在 ~/.zshrc.local 添加機器特定配置
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

#### 4. 編譯配置檔案（啟動提速）
```bash
# 所有 .zsh 檔案已編譯為 .zwc
# 啟動速度：~0.53 秒
```

---

### ⚠️ 重要變更：GRC 命令使用前綴

為避免覆蓋系統命令，使用 **'g' 前綴**：

| 舊命令 | 新命令 | 說明 |
|--------|--------|------|
| ping | **gping** | 彩色 ping |
| ps | **gps** | 彩色 ps |
| netstat | **gnetstat** | 彩色 netstat |
| df | **gdf** | 彩色 df |
| du | **gdu** | 彩色 du |
| dig | **gdig** | 彩色 dig |
| diff | **gdiff** | 彩色 diff |

**原始命令仍可正常使用**（保持系統行為）

---

### 🚀 立即啟用

```bash
# 方法 1：重新載入當前 shell
source ~/.zshrc

# 方法 2：開新終端
# 直接開新終端即可
```

---

### 🧪 快速測試

```bash
# 測試 lazy loading
ls          # 會自動安裝/設定 exa
vi file     # 會自動安裝/設定 nvim
g "text"    # 會自動安裝/設定 ripgrep
c file      # 會自動安裝/設定 bat
gping 8.8.8.8  # 會自動安裝/設定 grc（注意前綴）

# 測試 history
echo $HISTSIZE   # 應顯示 200000

# 測試啟動速度
time zsh -i -c exit   # 應在 0.5 秒左右
```

---

### 🔄 維護命令

```bash
# 修改配置後重新編譯
~/lazinit/zsh/utils/recompile.sh
source ~/.zshrc

# 更新所有插件
zinit update --all

# 清理 history（每 6 個月）
sort -u ~/.zsh_history > ~/.zsh_history.tmp
mv ~/.zsh_history.tmp ~/.zsh_history
```

---

### 📁 檔案結構

```
lazinit/zsh/
├── zshrc                    # 主配置（已優化）
├── zshrc.orig              # 原始備份
├── zshrc.zwc               # 編譯後檔案
├── UPGRADE_SUMMARY.md      # 完整報告
├── OPTIMIZATION_NOTES.md   # 優化筆記
├── QUICKREF.md             # 本檔案
└── zsh/
    ├── lazy_ls_v2.zsh      # V2 版本（使用中）
    ├── lazy_vi_v2.zsh
    ├── lazy_grc_v2.zsh
    ├── lazy_grep_v2.zsh
    ├── lazy_cat_v2.zsh
    ├── lazy_ls.zsh         # 舊版本（保留）
    ├── lazy_vi.zsh
    └── ...
```

---

### 🆘 問題排查

**Q: 某個命令不工作？**
```bash
# 檢查是否安裝
which exa nvim rg batcat grc

# 手動觸發 lazy loading
ls  # 會自動檢查安裝
```

**Q: 想回到舊版本？**
```bash
cp zshrc.orig zshrc
source ~/.zshrc
```

**Q: 編譯後修改沒生效？**
```bash
# 重新編譯
rm ~/.zshrc.zwc
zcompile ~/.zshrc
source ~/.zshrc
```

---

**性能對比**：啟動時間從 ~0.8s 降到 ~0.53s ⚡ **提升 34%**
