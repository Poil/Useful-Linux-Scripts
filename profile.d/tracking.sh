export CLIENT_IP=$(who -m | sed -r "s/.*\((.*)\).*/\\1/")
export DATE=$(date "+%d/%m/%Y %H:%M:%S")
export REAL_USER=$(who -m | cut -f 1 -d " ")

export HISTTIMEFORMAT="[ %d/%m/%Y %H:%M:%S ] "
export HISTFILESIZE='5000'
export HISTSIZE='5000'
export HISTIGNORE=''
export HISTCONTROL=''

test -n "$BASH_VERSION" && shopt -s histappend
test -n "$BASH_VERSION" && shopt -s histverify

export PROMPT_COMMAND='RETRN_VAL=$?; history -a; [[ $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//") != "${LAST_COMMAND}" ]] && logger -p user.info -t tracking"[$$]" "[ $REAL_USER::$USER@$CLIENT_IP:$PWD ] $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//") [$RETRN_VAL]"; export LAST_COMMAND=$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")'

test -n "$BASH_VERSION" && shopt -s cmdhist

