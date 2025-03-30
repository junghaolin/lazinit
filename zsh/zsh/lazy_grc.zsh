# ~/.zsh/lazy_grc.zsh
source ~/.zsh/utils/check_alias.zsh

do_alias(){
    alias grc='grc -es --colour=auto'
    alias netstat='sudo grc netstat'
    alias lsof='sudo grc netstat'
    alias ping='grc ping'
    alias traceroute='grc traceroute'
    alias ifconfig='grc ifconfig'
    alias mount='grc mount'
    alias ps='grc ps'
    alias df='grc df'
    alias du='grc du'
    alias dig='grc dig'
    alias diff='grc diff'
    alias wdiff='grc wdiff'
    alias route='grc route'
    alias mtr='grc mtr'
    alias git='grc git'
    alias docker='grc docker'
}

if command -v grc >/dev/null 2>&1; then
  do_alias
  return
fi


_lazy_grc_alias_init() {
  check_alias grc grc grc
  if [ $? -eq 0 ]; then
    do_alias
  else
    echo "[lazy_grc] 'grc' not installed or cannot be installed. Falling back to system commands."
  fi

  # 移除暫時函數，後續直接 alias
  unfunction grc netstat lsof ping traceroute ifconfig mount ps df du dig diff wdiff route mtr git docker 2>/dev/null
  echo "[lazy_grc] Aliases for '$1' initialized. Please rerun '$1'."
}

# 需要覆蓋的所有命令都定義函數
netstat()     { _lazy_grc_alias_init netstat "$@"; }
lsof()        { _lazy_grc_alias_init lsof "$@"; }
ping()        { _lazy_grc_alias_init ping "$@"; }
traceroute()  { _lazy_grc_alias_init traceroute "$@"; }
ifconfig()    { _lazy_grc_alias_init ifconfig "$@"; }
mount()       { _lazy_grc_alias_init mount "$@"; }
ps()          { _lazy_grc_alias_init ps "$@"; }
df()          { _lazy_grc_alias_init df "$@"; }
du()          { _lazy_grc_alias_init du "$@"; }
dig()         { _lazy_grc_alias_init dig "$@"; }
diff()        { _lazy_grc_alias_init diff "$@"; }
wdiff()       { _lazy_grc_alias_init wdiff "$@"; }
route()       { _lazy_grc_alias_init route "$@"; }
mtr()         { _lazy_grc_alias_init mtr "$@"; }
git()         { _lazy_grc_alias_init git "$@"; }
docker()      { _lazy_grc_alias_init docker "$@"; }
