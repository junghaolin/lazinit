# ~/.zsh/lazy_vi.zsh
source ~/.zsh/utils/check_alias.zsh

do_alias(){
    alias vi='nvim'
    alias nv='nvim'
}

if command -v batcat >/dev/null 2>&1; then
  do_alias
  return
fi

_lazy_vi_alias_init() {
  # 試著檢查 nvim / 安裝
  check_alias nvim neovim neovim
  if [ $? -eq 0 ]; then
    do_alias
  else
    echo "[lazy_vi] 'nvim' not installed or cannot be installed. Falling back to system vi."
    # 你也可以改成 alias vi='/usr/bin/vi'
    # 或是直接不做事
  fi

  # 移除暫時函數，讓 alias 生效
  unfunction vi nv 2>/dev/null
  echo "[lazy_vi] Aliases for '$1' initialized. Please rerun '$1'."
}

# 函數 override
vi() {
  _lazy_vi_alias_init vi "$@"
}
nv() {
  _lazy_vi_alias_init nv "$@"
}
