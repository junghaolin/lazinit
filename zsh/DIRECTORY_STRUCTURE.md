# 📦 ZSH 配置目錄結構

```
lazinit/zsh/
├── install.sh                   # 🚀 新主機安裝腳本
├── zshrc                        # 主配置文件
├── zshrc.orig                   # 原始配置備份
├── zshrc.zwc                    # 編譯後檔案（舊位置，已棄用）
│
├── utils/                       # 🛠️ 工具腳本
│   └── recompile.sh            # 重新編譯腳本
│
├── archived/                    # 📁 舊版本歸檔
│   ├── lazy_ls.zsh             # 舊版 lazy loading
│   ├── lazy_vi.zsh
│   ├── lazy_grc.zsh
│   ├── lazy_grep.zsh
│   └── lazy_cat.zsh
│
├── zsh/                         # ZSH 模組目錄
│   ├── lazy_ls_v2.zsh          # ✨ V2 版本（使用中）
│   ├── lazy_vi_v2.zsh
│   ├── lazy_grc_v2.zsh
│   ├── lazy_grep_v2.zsh
│   ├── lazy_cat_v2.zsh
│   │
│   ├── lib/
│   │   └── _lctask_run_function.sh
│   │
│   ├── site-functions/
│   │   └── _letask
│   │
│   └── utils/
│       └── check_alias.zsh
│
└── docs/                        # 📚 文檔
    ├── QUICKREF.md             # 快速參考
    ├── UPGRADE_SUMMARY.md      # 升級報告
    ├── OPTIMIZATION_NOTES.md   # 優化筆記
    └── SYMLINK_SETUP.md        # 符號連結設置
```

## 符號連結（實際使用）

```
~/.zshrc  -> ~/lazinit/zsh/zshrc
~/.zsh    -> ~/lazinit/zsh/zsh
```

## 編譯後檔案（實際位置）

```
~/.zshrc.zwc                     # 12K
~/.zsh/lazy_ls_v2.zsh.zwc       # 9.3K
~/.zsh/lazy_vi_v2.zsh.zwc       # 3.7K
~/.zsh/lazy_grc_v2.zsh.zwc      # 7.1K
~/.zsh/lazy_grep_v2.zsh.zwc     # 3.5K
~/.zsh/lazy_cat_v2.zsh.zwc      # 4.6K
~/.zsh/utils/check_alias.zsh.zwc # 3.0K
```
