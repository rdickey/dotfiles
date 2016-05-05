# TODO: combine the common parts of bash_profile.linux and bash_profile.mac and only have the small differences in each
#echo sourcing .bash_profile

[[ -f /etc/profile ]] && . /etc/profile
[[ -f ~/.aws.sh ]] && . ~/.aws.sh
export EDITOR="/usr/bin/vim"
export HISTFILESIZE=1048576
export LSCOLORS="cxgxcbdbdxegeddxdxcxcx"
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

source ~/.bash_functions

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" -a -z "$BASHRC_DONE"  ]; then
        . "$HOME/.bashrc"
    fi
    if [ -f "/etc/bash_completion" ] && ! shopt -oq posix; then
        . "/etc/bash_completion"
    fi
    if [ -d "/etc/bash_completion.d" ]; then
        for f in `find /etc/bash_completion.d/*`; do
            source "$f" 2>/dev/null
        done
    fi
fi

# colors found at http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
# ref: http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
true &&     RS="\[\033[0m\]"    # reset
true && BRANCH="\[\033[1;34m\]"
true &&     FG="\[\033[0;31m\]"
true &&    FGB="\[\033[1;31m\]"
if [ "$USER" = "root" ]; then
    SEP='#'
else
    SEP='$'
fi
PS1="${FGB}{${BRANCH}\$git_branch${FGB}\u@\h:${FG}\w${FGB}}${SEP}${RS} "
PROMPT_COMMAND='echo -ne "\033]0;$git_branch$USER@$HOSTNAME:$munged_path\007"'
PROMPT_COMMAND="munge_path; find_git_branch; $PROMPT_COMMAND"

alias ls="ls -GF"
alias sl="ls"
alias l="ls -al"
alias ll="ls -alhF"
[[ -n "`which vim 2>/dev/null`" ]] && alias vi="vim" || echo "Warning: vim is not installed.  This may cause sadness."

alias grep="egrep"
alias egrep="egrep --color"
# This is a hack so that things like "sudo vi" will evaluate as "sudo vim".
# Otherwise, bash would only evaluate the alias for sudo (if any), not whatever came after it.
alias sudo="sudo "
alias fixcursor="setterm -cursor on"

alias fuck='sudo $(history -p \!\!)'
alias ffs='sudo $(history -p \!\!)'

export LESS="-x4 -FXR"

[[ -s "$HOME/.bash_custom" ]] && source "$HOME/.bash_custom"
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

### Added by the Heroku Toolbelt
[[ -d "/usr/local/heroku/bin" ]] && export PATH="/usr/local/heroku/bin:$PATH"

#alias fixws="wmctrl -R Wireshark -e 0,100,300,1600,1000"
alias fixws="wmctrl -R Wireshark -e 0,1000,1200,1600,1000"

# MacPorts Installer addition
[[ -d "/opt/local/bin" ]] && export PATH="/opt/local/sbin:$PATH"
[[ -d "/opt/local/sbin" ]] && export PATH="/opt/local/bin:$PATH"

ssh-add $HOME/.ssh/*pem >/dev/null 2>&1
export BASH_PROFILE_DONE=true
