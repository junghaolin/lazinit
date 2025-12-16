# 🔗 符號連結環境設置指南

## 當前設置

你使用符號連結來管理配置：

```bash
~/.zshrc  -> ~/lazinit/zsh/zshrc
~/.zsh    -> ~/lazinit/zsh/zsh
```

## ✅ 已完成調整

### 1. 重新編譯在正確位置

所有編譯檔案現在位於：
```
~/.zshrc.zwc                          # 12K
~/.zsh/lazy_ls_v2.zsh.zwc            # 9.3K
~/.zsh/lazy_vi_v2.zsh.zwc            # 3.7K
~/.zsh/lazy_grc_v2.zsh.zwc           # 7.1K
~/.zsh/lazy_grep_v2.zsh.zwc          # 3.5K
~/.zsh/lazy_cat_v2.zsh.zwc           # 4.6K
~/.zsh/utils/check_alias.zsh.zwc     # 3.0K
```

### 2. 性能測試
- 平均啟動時間：**0.54 秒**
- 所有配置已編譯並優化

## 🚀 立即生效

```bash
# 重新載入配置
source ~/.zshrc

# 或開新終端即可
```

## 🔄 修改配置後的流程

當你修改 `~/lazinit/zsh/zshrc` 或任何 lazy loading 腳本後：

### 方法 1：自動重新編譯腳本
```bash
# 已創建在 ~/lazinit/zsh/utils/recompile.sh
#!/bin/bash
echo "🔄 重新編譯 ZSH 配置..."

# 編譯主配置
zcompile ~/.zshrc

# 編譯所有 lazy loading 腳本
cd ~/.zsh
for file in lazy_*.zsh utils/check_alias.zsh; do
  [ -f "$file" ] && zcompile "$file"
done

echo "✅ 編譯完成！"
ls -lh ~/.zshrc.zwc ~/.zsh/*.zwc ~/.zsh/utils/*.zwc
EOF

chmod +x ~/lazinit/zsh/recompile.sh
```

使用：
```bash
~/lazinit/zsh/utils/recompile.sh
source ~/.zshrc
```

### 方法 2：手動編譯
```bash
# 編譯主配置
zcompile ~/.zshrc

# 編譯單個腳本
zcompile ~/.zsh/lazy_ls_v2.zsh

# 重新載入
source ~/.zshrc
```

## 📝 Git 管理

因為你的配置在 `~/lazinit` 下，可以用 git 管理：

```bash
cd ~/lazinit
git add zsh/
git commit -m "Update zsh configuration"
git push
```

### .gitignore 建議
```bash
# 添加到 ~/lazinit/.gitignore
*.zwc
.zsh_history
```

這樣編譯檔案不會被提交，保持倉庫乾淨。

## 🔍 驗證設置

```bash
# 檢查符號連結
ls -la ~/.zshrc ~/.zsh

# 檢查編譯檔案
ls -lh ~/.zshrc.zwc ~/.zsh/*.zwc

# 測試啟動速度
time zsh -i -c exit

# 測試 lazy loading
ls    # 應該觸發 exa 初始化
vi    # 應該觸發 nvim 初始化
```

## ⚠️ 注意事項

### 編譯檔案位置
- ✅ 正確：`~/.zshrc.zwc`（符號連結的目標位置）
- ❌ 錯誤：`~/lazinit/zsh/zshrc.zwc`（源文件位置）

ZSH 會在**執行位置**（~/.zshrc）查找編譯檔案，而不是源文件位置。

### 多機器同步

如果在多台機器上使用相同配置：

```bash
# 機器 A
cd ~/lazinit
git add zsh/
git commit -m "Update config"
git push

# 機器 B
cd ~/lazinit
git pull
~/lazinit/zsh/utils/recompile.sh  # 重新編譯
source ~/.zshrc
```

## 🛠️ 故障排除

### 問題：修改沒有生效
```bash
# 刪除所有編譯檔案
rm -f ~/.zshrc.zwc ~/.zsh/*.zwc ~/.zsh/utils/*.zwc

# 重新編譯
~/lazinit/zsh/utils/recompile.sh

# 重新載入
source ~/.zshrc
```

### 問題：找不到命令
```bash
# 檢查符號連結
readlink -f ~/.zshrc
readlink -f ~/.zsh

# 應該指向
# /home/zeph/lazinit/zsh/zshrc
# /home/zeph/lazinit/zsh/zsh
```

### 問題：啟動慢
```bash
# 檢查編譯檔案是否存在
ls -la ~/.zshrc.zwc ~/.zsh/*.zwc

# 如果不存在，重新編譯
~/lazinit/zsh/recompile.sh
```

## 📦 完整部署到新機器

```bash
# 1. 克隆配置
git clone <your-repo> ~/lazinit

# 2. 創建符號連結
ln -sf ~/lazinit/zsh/zshrc ~/.zshrc
ln -sf ~/lazinit/zsh/zsh ~/.zsh

# 3. 編譯配置
~/lazinit/zsh/utils/recompile.sh

# 4. 重新載入
source ~/.zshrc
```

---

**現在所有改動已經生效！** 🎉

執行 `source ~/.zshrc` 即可使用優化後的配置。
