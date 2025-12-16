# ~/.zsh/lazy_vi_v2.zsh
# 優化版：一次性初始化

_setup_vi_aliases() {
  alias vi='nvim'
  alias nv='nvim'
  alias vim='nvim'
}

# 如果 nvim 已存在，直接設定
if command -v nvim >/dev/null 2>&1; then
  _setup_vi_aliases
  unfunction _setup_vi_aliases
  return
fi

# Lazy loading：一次性初始化
_lazy_vi_init_once() {
  # 嘗試安裝
  if ! command -v nvim >/dev/null 2>&1; then
    if command -v apt-cache >/dev/null 2>&1 && apt-cache show neovim >/dev/null 2>&1; then
      echo "[lazy_vi] Installing neovim..."
      if [ "$(id -u)" -eq 0 ]; then
        apt install neovim -y >/dev/null 2>&1
      elif groups "$USER" | grep -qw sudo; then
        sudo apt install neovim -y 2>/dev/null
      fi
    fi
  fi

  # 設定 alias
  if command -v nvim >/dev/null 2>&1; then
    _setup_vi_aliases
  else
    echo "[lazy_vi] nvim not installed, using system vi"
  fi

  # 清理函數
  unfunction vi nv vim 2>/dev/null
  unfunction _lazy_vi_init_once _setup_vi_aliases 2>/dev/null
}

# 單一觸發函數
_lazy_vi_trigger() {
  _lazy_vi_init_once
  "$@"
}

vi()  { _lazy_vi_trigger vi  "$@"; }
nv()  { _lazy_vi_trigger nv  "$@"; }
vim() { _lazy_vi_trigger vim "$@"; }
