# ~/.zsh/lazy_ls_v2.zsh
# 優化版：避免重複初始化，一次性完成所有 alias 設定

# 設定所有 exa 相關 alias
_setup_ls_aliases() {
  alias lg='exa -lbF --git'
  alias ls='exa -F'
  alias l='exa -lbF'
  alias ll='exa -lbGF'
  alias llm='exa -lbGd --sort=modified'
  alias la='exa -lhHbmua --time-style=long-iso --color-scale'
  alias laa='exa -lbhHigUmuSa --time-style=long-iso --color-scale'
  alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --color-scale'
  alias lS='exa -1'
  alias lt='exa --tree --level=2'
  alias lt3='exa --tree --level=3'
  alias lt4='exa --tree --level=4'
  alias lt5='exa --tree --level=5'
  alias lt6='exa --tree --level=6'
  alias lt7='exa --tree --level=7'
  alias lt8='exa --tree --level=8'
  alias lt9='exa --tree --level=9'
  alias lt0='exa --tree --level=10'
}

# 如果 exa 或 eza 已存在，直接設定
if command -v exa >/dev/null 2>&1 || command -v eza >/dev/null 2>&1; then
  # 如果是 eza，建立軟連結或 alias 到 exa
  if ! command -v exa >/dev/null 2>&1 && command -v eza >/dev/null 2>&1; then
    alias exa='eza'
  fi
  _setup_ls_aliases
  unfunction _setup_ls_aliases
  return
fi

# Lazy loading：一次性初始化所有命令
_lazy_ls_init_once() {
  # 檢查並安裝
  if command -v eza >/dev/null 2>&1; then
    alias exa='eza'
  elif ! command -v exa >/dev/null 2>&1; then
    # 嘗試安裝（靜默執行，避免輸出干擾）
    if command -v apt-cache >/dev/null 2>&1; then
      for pkg in eza exa; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
          echo "[lazy_ls] Installing $pkg..."
          if [ "$(id -u)" -eq 0 ]; then
            apt install "$pkg" -y >/dev/null 2>&1
          elif groups "$USER" | grep -qw sudo; then
            sudo apt install "$pkg" -y 2>/dev/null
          fi
          break
        fi
      done
    fi
  fi

  # 重新檢查並設定 alias
  if command -v exa >/dev/null 2>&1 || command -v eza >/dev/null 2>&1; then
    if ! command -v exa >/dev/null 2>&1 && command -v eza >/dev/null 2>&1; then
      alias exa='eza'
    fi
    _setup_ls_aliases
  else
    # 回退到標準 ls
    alias ls='ls --color=auto'
    alias l='ls -CF'
    alias ll='ls -lh'
    alias la='ls -A'
  fi

  # 清理：移除所有函數覆蓋
  unfunction ls l ll la llm laa lx lS lt lt3 lt4 lt5 lt6 lt7 lt8 lt9 lt0 2>/dev/null
  unfunction _lazy_ls_init_once _setup_ls_aliases 2>/dev/null
}

# 使用單一函數攔截第一次調用
_lazy_ls_trigger() {
  _lazy_ls_init_once
  # 執行原始命令
  "$@"
}

# 覆蓋所有 ls 相關命令
ls()  { _lazy_ls_trigger ls  "$@"; }
l()   { _lazy_ls_trigger l   "$@"; }
ll()  { _lazy_ls_trigger ll  "$@"; }
llm() { _lazy_ls_trigger llm "$@"; }
la()  { _lazy_ls_trigger la  "$@"; }
laa() { _lazy_ls_trigger laa "$@"; }
lx()  { _lazy_ls_trigger lx  "$@"; }
lS()  { _lazy_ls_trigger lS  "$@"; }
lt()  { _lazy_ls_trigger lt  "$@"; }
lt3() { _lazy_ls_trigger lt3 "$@"; }
lt4() { _lazy_ls_trigger lt4 "$@"; }
lt5() { _lazy_ls_trigger lt5 "$@"; }
lt6() { _lazy_ls_trigger lt6 "$@"; }
lt7() { _lazy_ls_trigger lt7 "$@"; }
lt8() { _lazy_ls_trigger lt8 "$@"; }
lt9() { _lazy_ls_trigger lt9 "$@"; }
lt0() { _lazy_ls_trigger lt0 "$@"; }
