# ~/.zsh/lazy_cat.zsh
# Lazy load 'cat' => alias to 'bat'
# Require: check_alias() in ~/.zsh/utils/check_alias.zsh

source ~/.zsh/utils/check_alias.zsh
do_alias(){
  alias cat='batcat --color=always --paging=never'
}

if command -v batcat >/dev/null 2>&1; then
  do_alias
  return
fi

_lazy_cat_alias_init() {
  # 如果系統已經有 bat，就直接 alias
  if command -v bat >/dev/null 2>&1; then
    do_alias
  else
    # 系統沒有 bat => 嘗試自動安裝
    # 依發行版和倉庫不同，可能套件名是 bat 或 batcat
    # 下面以 bat 為例
    check_alias batcat bat bat
    if [ $? -eq 0 ]; then
      do_alias
    else
      echo "[lazy_cat] bat not installed or cannot be installed. Falling back to system 'cat'."
    fi
  fi

  # lazy-load 完成，卸載此函數
  unfunction cat 2>/dev/null

  echo "[lazy_cat] Alias for '$1' initialized. Please re-run '$1'."
}

# 第一次呼叫 'cat' 時才做初始化
cat() {
  _lazy_cat_alias_init cat "$@"
}
