# ~/.zsh/lazy_grep.zsh
source ~/.zsh/utils/check_alias.zsh

do_alias(){
    alias grep='rg --color=always --no-ignore-vcs --mmap --colors "match:fg:red"'
}

if command -v rg >/dev/null 2>&1; then
  do_alias
  return
fi

_lazy_grep_alias_init() {
  check_alias rg ripgrep ripgrep
  if [ $? -eq 0 ]; then
    do_alias
  else
    echo "[lazy_grep] 'rg' not installed or cannot be installed. Falling back to system grep."
  fi

  unfunction grep 2>/dev/null
  echo "[lazy_grep] Alias for '$1' initialized. Please rerun '$1'."
}

# 函數 override
grep() {
  _lazy_grep_alias_init grep "$@"
}
