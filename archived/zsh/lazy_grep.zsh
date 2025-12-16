# ~/.zsh/lazy_grep.zsh
source ~/.zsh/utils/check_alias.zsh

do_alias(){
    # Avoid aliasing 'grep' to 'rg' to prevent flag incompatibility (e.g. -E).
    # Alias 'rg' or 'g' instead.
    alias g='rg --color=always --no-ignore-vcs --mmap --colors "match:fg:red"'
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
    echo "[lazy_grep] 'rg' not installed."
  fi

  unfunction g rg 2>/dev/null
  echo "[lazy_grep] Alias for '$1' initialized. Running command..."
  eval "$1" "${@:2}"
}

# Trigger on 'g' or 'rg'
g() {
  _lazy_grep_alias_init g "$@"
}
rg() {
  _lazy_grep_alias_init rg "$@"
}
