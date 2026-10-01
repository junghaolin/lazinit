# ZSH 配置優化筆記

## 已完成的優化 ✅

### 1. PATH 管理
- ✅ 使用 `typeset -U path` 自動去除重複路徑
- ✅ 集中管理所有 PATH 配置
- ✅ 添加路徑存在性檢查
- ✅ 修正 GO_PATH 和 CONDA_PATH 的重複定義問題

### 2. 結構優化
- ✅ 清晰的分段註釋
- ✅ 刪除未使用的註釋代碼
- ✅ 統一使用 `find_dir` 函數尋找路徑

### 3. Conda 初始化
- ✅ 移除硬編碼路徑
- ✅ 改進錯誤處理

## 進階優化建議 🚀

### 1. Lazy Loading 優化（可選）

#### 問題
- 當前每次調用都會執行完整的初始化檢查
- `check_alias.zsh` 的 APT 操作較慢

#### 解決方案
已創建優化版本：
- `lazy_ls_v2.zsh` - 一次性初始化所有 ls 相關命令
- `lazy_grc_v2.zsh` - 使用 'g' 前綴避免覆蓋系統命令

#### 使用方法
```bash
# 在 zshrc 中替換：
source ~/.zsh/lazy_ls_v2.zsh  # 取代 lazy_ls.zsh
source ~/.zsh/lazy_grc_v2.zsh # 取代 lazy_grc.zsh
```

### 2. GRC 命令別名策略

#### 當前問題
覆蓋 `git`, `docker`, `ps`, `mount` 等系統命令可能導致：
- 腳本執行失敗（腳本預期標準輸出格式）
- CI/CD 環境問題
- 性能下降

#### 建議方案 A：使用前綴（推薦）
```bash
gping    # 取代 ping
gps      # 取代 ps
gnetstat # 取代 netstat
```

優點：
- ✅ 不影響系統腳本
- ✅ 明確表達使用 grc
- ✅ 避免意外行為

缺點：
- ❌ 需要記憶新命令

#### 建議方案 B：選擇性覆蓋
只覆蓋較少使用的命令：
```bash
alias ping='grc ping'      # 通常只在終端使用
alias traceroute='grc traceroute'
alias ifconfig='grc ifconfig'

# 不覆蓋這些：
# git, docker, ps, mount, df, du
```

### 3. Zinit 插件載入優化

#### 當前配置
```bash
zinit wait lucid for \
  atinit"..." zdharma-continuum/fast-syntax-highlighting \
  ...
```

#### 優化建議
可以進一步延遲載入：
```bash
# 語法高亮可以在第一次提示符後載入
zinit wait lucid atload'_zsh_autosuggest_start' for \
  zsh-users/zsh-autosuggestions

zinit wait'1' lucid for \
  zdharma-continuum/fast-syntax-highlighting

# 補全可以更晚載入
zinit wait'2' lucid blockf for \
  zsh-users/zsh-completions
```

### 4. History 檔案優化

#### 當前配置
```bash
HISTSIZE=500000
SAVEHIST=500000
```

#### 建議
- 500k 條記錄可能過大，考慮減少到 50k-100k
- 定期清理重複項：
```bash
# 添加到 cron 或定期執行
sort -u ~/.zsh_history > ~/.zsh_history.tmp
mv ~/.zsh_history.tmp ~/.zsh_history
```

### 5. 檢查 APT 可用性（針對非 Debian 系統）

如果你的配置需要在多個系統使用：
```bash
# 在 check_alias.zsh 開頭添加
if ! command -v apt-cache >/dev/null 2>&1; then
  # 使用其他包管理器 (brew, yum, pacman, etc.)
  return 1
fi
```

## 性能測試 📊

### 測試啟動時間
```bash
# 測試 zsh 啟動時間
time zsh -i -c exit

# 測試特定函數
time ls
time gps
```

### 預期結果
- 首次啟動：< 0.5s
- Lazy loading 首次觸發：< 1s（含安裝檢查）
- 後續調用：< 0.01s

## 最佳實踐建議 💡

### 1. 定期維護
```bash
# 清理未使用的 zinit 插件
zinit delete --clean

# 更新插件
zinit update --all
```

### 2. 備份配置
```bash
# 使用 git 管理配置
cd ~/lazinit
git add zsh/
git commit -m "Update zsh config"
```

### 3. 分離個人化設定
創建 `~/.zshrc.local` 存放機器特定的配置：
```bash
# 在 zshrc 最後添加
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

## 進一步優化方向 🔮

1. **使用 zsh-defer** - 延遲載入非關鍵命令
2. **編譯 zsh 配置** - 使用 `zcompile` 加速
3. **使用 zinit 的 turbo mode** - 更積極的延遲載入
4. **快取 command 檢查結果** - 避免重複檢查

## 參考資源 📚

- [Zinit Wiki](https://github.com/zdharma-continuum/zinit/wiki)
- [Zsh Performance](https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load/)
- [Powerlevel10k Performance](https://github.com/romkatv/powerlevel10k#performance)
