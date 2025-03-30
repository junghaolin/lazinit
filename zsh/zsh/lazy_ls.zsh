# ~/.zsh/lazy_ls.zsh
source ~/.zsh/utils/check_alias.zsh



do_alias() {
  alias ls='exa -lbF --git'
  alias l='exa -lbF --git'
  alias ll='exa -lbGF --git'
  alias llm='exa -lbGd --git --sort=modified'
  alias la='exa -lhHbmua --time-style=long-iso --color-scale'
  alias laa='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'
  alias lx='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'
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
# 如果是非互動 shell，且 exa 已存在，直接設定 alias
if command -v exa >/dev/null 2>&1; then
  do_alias
  return
fi

_lazy_ls_alias_init() {
  check_alias exa eza exa
  if [ $? -eq 0 ]; then
    # exa-based aliases
    do_alias
  else
    # fallback to ls
    alias ls='ls --color=auto'
    alias l='ls -CF'
    alias ll='ls -lh'
    alias la='ls -a'
  fi

  # 移除初始化函數（覆蓋 alias 名稱）
  unfunction l ll la llm laa lx lS lt lt3 lt4 lt5 lt6 lt7 lt8 lt9 lt0 2>/dev/null
  echo "Aliases for '$1' initialized. Please run '$1' again."
}

# Lazy init entry points
l()    { _lazy_ls_alias_init l "$@"; }
ll()   { _lazy_ls_alias_init ll "$@"; }
llm()  { _lazy_ls_alias_init llm "$@"; }
la()   { _lazy_ls_alias_init la "$@"; }
laa()  { _lazy_ls_alias_init laa "$@"; }
lx()   { _lazy_ls_alias_init lx "$@"; }
lS()   { _lazy_ls_alias_init lS "$@"; }
lt()   { _lazy_ls_alias_init lt "$@"; }
lt3()  { _lazy_ls_alias_init lt3 "$@"; }
lt4()  { _lazy_ls_alias_init lt4 "$@"; }
lt5()  { _lazy_ls_alias_init lt5 "$@"; }
lt6()  { _lazy_ls_alias_init lt6 "$@"; }
lt7()  { _lazy_ls_alias_init lt7 "$@"; }
lt8()  { _lazy_ls_alias_init lt8 "$@"; }
lt9()  { _lazy_ls_alias_init lt9 "$@"; }
lt0()  { _lazy_ls_alias_init lt0 "$@"; }

