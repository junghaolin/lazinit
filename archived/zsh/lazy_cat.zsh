# ~/.zsh/lazy_cat.zsh
source ~/.zsh/utils/check_alias.zsh

do_alias(){
  # Avoid aliasing 'cat' to 'bat' to prevent issues with scripts/agents expecting standard cat behavior.
  # Instead, we can alias 'c' or just ensure 'bat' is available.
  alias c='batcat --color=always --paging=never'
  alias bat='batcat --color=always --paging=never'
}

if command -v batcat >/dev/null 2>&1; then
  do_alias
  return
fi

_lazy_cat_alias_init() {
  # 如果系統已經有 bat，就直接 alias
  if command -v batcat >/dev/null 2>&1; then
    do_alias
  else
    # 系統沒有 bat => 嘗試自動安裝
    check_alias batcat bat bat
    if [ $? -eq 0 ]; then
      do_alias
    else
      echo "[lazy_cat] bat not installed. 'c' alias will not work."
    fi
  fi

  # lazy-load 完成，卸載此函數
  unfunction c bat 2>/dev/null

  echo "[lazy_cat] Alias for '$1' initialized. Running command..."
  eval "$1" "${@:2}"
}

# Trigger on 'c' or 'bat' instead of 'cat'
c() {
  _lazy_cat_alias_init c "$@"
}
bat() {
  _lazy_cat_alias_init bat "$@"
}
