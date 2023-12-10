## append to the history file, don't overwrite it
shopt -s histappend

## check the window size after each command and, if necessary,
## update the values of LINES and COLUMNS.
shopt -s checkwinsize

HISTCONTROL=ignoreboth
HISTFILESIZE=10000
HISTSIZE=50000
HISTTIMEFORMAT='%F %T'

EDITOR=/usr/bin/vim

## More Colors
export TERM='xterm-256color'

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

## make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

###########################################################################
### https://gist.github.com/javipolo/62eb953f817a9a2f63b8127ff5f60788
###########################################################################

## Make short hostname only if its not an IP address
__tm_get_hostname(){
    local HOST="$(echo $* | awk '{print $NF}')"
    if echo $HOST | grep -P "^([0-9]+\.){3}[0-9]+" -q; then
        echo $HOST
    else
        echo $HOST | awk -F '.' '{print $1"."$NF}'
    fi
}

__tm_get_current_window(){
    tmux list-windows| awk -F : '/\(active\)$/{print $1}'
}

__tm_is_tmux_session() {
  [[ "$(ps -p $(ps -p $$ -o ppid=) -o comm=| cut -d : -f 1)" == "tmux" ]] && return 0 || return 1
}

## Rename window according to __tm_get_hostname and then restore it after the command
__tm_command() {
    if __tm_is_tmux_session; then
        __tm_window=$(__tm_get_current_window)
        # Use current window to change back the setting. If not it will be applied to the active window
        trap "tmux set-window-option -t $__tm_window automatic-rename on 1>/dev/null" RETURN
        tmux rename-window "$(__tm_get_hostname $*)"
    fi
    command "$@"
}

ssh() {
    if (( ${#@} == 1 )); then
      __tm_command ssh "$@"
    else
      $(which ssh) "$@"
    fi
}

###########################################################################
### git stuff
###########################################################################

ORIG_PROMPT="$PS1"
git_prompt () {
  git status > /dev/null 2>&1
  retval=$?
  if [ $retval -eq 0 ]; then
    git_branch=$(git rev-parse --abbrev-ref HEAD)
    git_repo=$(git config --get remote.origin.url | cut -d\/ -f5-5)
    if [ $git_repo != "puppet" ]; then
      PS1="\[$(tput setaf 3)\](${git_repo}::${git_branch}):\w\$ \[$(tput setaf 0)\]\[$(tput sgr0)\]"
    else
      PS1="\[$(tput setaf 5)\](${git_branch}):\w\$ \[$(tput setaf 0)\]\[$(tput sgr0)\]"
    fi
  else
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
      debian_chroot=$(cat /etc/debian_chroot)
    fi
    #PS1="$ORIG_PROMPT"
    PS1="\[$(tput setaf 6)\][$(date +%H:%M:%S)] ${debian_chroot:+($debian_chroot)}\u@\h:\w$ \[$(tput setaf 0)\]\[$(tput sgr0)\]"
  fi
}
PROMPT_COMMAND='git_prompt'

###########################################################################
### Misc. functions
###########################################################################

delete_lines () {
  usage='Usage:
    delete_lines [FILE] [LINE_NUMBER...]
    or
    delete_lines [FILE]:[LINE_NUMBER], [FILE]:[LINE_NUMBER:...]'

  if (( $# == 1 )); then
    if [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
      echo "${usage}"
      return 0
    else
      local params=($(echo "$1" |tr ':' ' '))
      local target_file="${params[0]}"
    fi
  elif (( $# >= 2 )); then
    local params=( "$@" )
    local target_file="${params[0]}"
  else
    echo "${usage}"
    return 1
  fi
  if [[ ! -f ${target_file} ]]; then
    echo "Target file '${target_file}' does not exist."
    echo
    echo "${usage}"
    return 1
  fi
  if ! [[ ${params[1]} == +([0-9]) ]]; then
    echo "No lines to remove given"
    echo
    echo "${usage}"
    return 1
  fi
  for line in $(echo "${params[@]}" | tr ' ' '\n' | sort -rn | head -n-1); do
    echo Doing sed -i "${line}d" "${target_file}"
    sed -i "${line}d" "${target_file}"
  done
  return 0
}

export LANG="en_US.UTF-8"
export LANGUAGE="en"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export LC_ALL=
