# ~/.zsh/lazy_cat_v2.zsh
# 優化版：一次性初始化

_setup_cat_aliases() {
  # 使用 'c' 和 'bat' 別名，不覆蓋 cat
  alias c='batcat --color=always --paging=never'
  alias bat='batcat --color=always --paging=never'
}

# 如果 batcat 或 bat 已存在，直接設定
if command -v batcat >/dev/null 2>&1 || command -v bat >/dev/null 2>&1; then
  # 如果是 bat，建立到 batcat 的別名
  if ! command -v batcat >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
    alias batcat='bat'
  fi
  _setup_cat_aliases
  unfunction _setup_cat_aliases
  return
fi

# Lazy loading：一次性初始化
_lazy_cat_init_once() {
  # 嘗試安裝
  if ! command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    if command -v apt-cache >/dev/null 2>&1 && apt-cache show bat >/dev/null 2>&1; then
      echo "[lazy_cat] Installing bat..."
      if [ "$(id -u)" -eq 0 ]; then
        apt install bat -y >/dev/null 2>&1
      elif groups "$USER" | grep -qw sudo; then
        sudo apt install bat -y 2>/dev/null
      fi
    fi
  fi

  # 設定 alias
  if command -v batcat >/dev/null 2>&1 || command -v bat >/dev/null 2>&1; then
    if ! command -v batcat >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
      alias batcat='bat'
    fi
    _setup_cat_aliases
  else
    echo "[lazy_cat] bat not installed"
  fi

  # 清理函數
  unfunction c bat 2>/dev/null
  unfunction _lazy_cat_init_once _setup_cat_aliases 2>/dev/null
}

# 單一觸發函數
_lazy_cat_trigger() {
  _lazy_cat_init_once
  "$@"
}

c()   { _lazy_cat_trigger c   "$@"; }
bat() { _lazy_cat_trigger bat "$@"; }
