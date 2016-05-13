# TODO: combine the common parts of bash_profile.linux and bash_profile.mac and only have the small differences in each
#echo sourcing .bash_profile

[[ -f /etc/profile ]] && . /etc/profile
[[ -f ~/.aws.sh ]] && . ~/.aws.sh
export EDITOR="/usr/bin/vim"
export HISTFILESIZE=1048576
export LS_COLORS='no=00:fi=00:di=00;32:ln=00;36:pi=01;36:so=00;34:bd=33;01:cd=33;01:or=31;01:ex=00;33:*.tar=01;37:*.tgz=01;37:*.arj=01;37:*.taz=01;37:*.lzh=01;37:*.zip=01;37:*.z=01;37:*.Z=01;37:*.gz=01;37:*.deb=01;37:*.rpm=01;37:*.bz2=01;37:*.jpg=01;32:*.gif=01;32:*.png=01;32:*.bmp=01;32:*.ppm=01;32:*.tga=01;32:*.xbm=01;32:*.xpm=01;32:*.tif=01;32:*.mpg=01;32:*.avi=01;32:*.gl=01;32:*.dl=01;35:*.cc=01;32:*.cpp=01;32:*.py=01;32:*.java=01;32:*.h=00;32:*.c=01;32:*.o=00;37:*.pyc=00;37'
export PATH=$HOME/bin:$PATH

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

alias ls="ls --color -F"
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

complete -C aws_completer aws

[[ -s "$HOME/.bash_custom" ]] && source "$HOME/.bash_custom"
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

### Added by the Heroku Toolbelt
[[ -d "/usr/local/heroku/bin" ]] && export PATH="/usr/local/heroku/bin:$PATH"

ssh-add $HOME/.ssh/*pem >/dev/null 2>&1
export BASH_PROFILE_DONE=true
