# ~/.zsh/lazy_grep_v2.zsh
# 優化版：一次性初始化

_setup_grep_aliases() {
  # 使用 'g' 別名而非覆蓋 grep
  alias g='rg --color=always --no-ignore-vcs --mmap --colors "match:fg:red"'
}

# 如果 rg 已存在，直接設定
if command -v rg >/dev/null 2>&1; then
  _setup_grep_aliases
  unfunction _setup_grep_aliases
  return
fi

# Lazy loading：一次性初始化
_lazy_grep_init_once() {
  # 嘗試安裝
  if ! command -v rg >/dev/null 2>&1; then
    if command -v apt-cache >/dev/null 2>&1 && apt-cache show ripgrep >/dev/null 2>&1; then
      echo "[lazy_grep] Installing ripgrep..."
      if [ "$(id -u)" -eq 0 ]; then
        apt install ripgrep -y >/dev/null 2>&1
      elif groups "$USER" | grep -qw sudo; then
        sudo apt install ripgrep -y 2>/dev/null
      fi
    fi
  fi

  # 設定 alias
  if command -v rg >/dev/null 2>&1; then
    _setup_grep_aliases
  else
    echo "[lazy_grep] rg not installed"
  fi

  # 清理函數
  unfunction g rg 2>/dev/null
  unfunction _lazy_grep_init_once _setup_grep_aliases 2>/dev/null
}

# 單一觸發函數
_lazy_grep_trigger() {
  _lazy_grep_init_once
  "$@"
}

g()  { _lazy_grep_trigger g  "$@"; }
rg() { _lazy_grep_trigger rg "$@"; }
