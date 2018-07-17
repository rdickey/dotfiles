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
    if [ -n "`which brew`" ]; then
        if [ -f $(brew --prefix)/etc/bash_completion ]; then
            . $(brew --prefix)/etc/bash_completion
        fi
    fi
fi

HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=1000000                  # big big history
HISTFILESIZE=1000000              # big big history
shopt -s histappend               # append to history, don't overwrite it

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

# After each command, append to the history file and reread it
#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

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

alias ffs='sudo $(history -p \!\!)'
eval "$(thefuck --alias)"

alias bitchen='kitchen'

export LESS="-x4 -FXR"

#complete -C aws_completer aws

[[ -s "$HOME/.bash_custom" ]] && source "$HOME/.bash_custom"
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -d "$HOME/.rvm/bin" ]] && export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
[[ -d "/usr/local/heroku/bin" ]] && export PATH="/usr/local/heroku/bin:$PATH"

#alias fixws="wmctrl -R Wireshark -e 0,100,300,1600,1000"
alias fixws="wmctrl -R Wireshark -e 0,1000,1200,1600,1000"

# MacPorts Installer addition
[[ -d "/opt/local/bin" ]] && export PATH="/opt/local/sbin:$PATH"
[[ -d "/opt/local/sbin" ]] && export PATH="/opt/local/bin:$PATH"

[[ -n "`which boot2docker`" ]] && eval "$(boot2docker shellinit 2>/dev/null)"

[[ -s "/etc/bashrc_Apple_Terminal" ]] && source "/etc/bashrc_Apple_Terminal"

#ssh-add $HOME/.ssh/*pem >/dev/null 2>&1

#if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# Functions we'll use for tfinit, tfplan and tfapply in this repo

function tfinit() {
    if [ -z "$1" ]; then
        echo "ERROR: Must supply a workspace, such as 'us-east-1'"
        echo -e "\nusage: tfinit <workspace>\n"
        return 1
    fi
    # Test if workspace can be used
    terraform workspace select "$1" >/dev/null 2>/dev/null
    # If it fails, init is required before using any non-default workspace
    if [ $? -ne 0 ]; then
        # Init may fail on backend and that's okay
        terraform init || echo -e "\nINFO: Init with default workspace Completed.  The above error is expected.  YMMV.\n\n\n"
        terraform workspace new "$1" || echo -e "\nINFO: Create of workspace $1 may have failed if it already exists.  YMMV.\n\n\n"
    fi
    # Need to switch to desired workspace before init
    terraform workspace select "$1"
    terraform init
}

function tfplan() {
    if [ -z "$1" ]; then
        echo "ERROR: Must supply a workspace, such as 'us-east-1'"
        echo -e "\nusage: tfplan <workspace>\n"
        return 1
    fi
    var_file="$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../../$1.tfvars"
    set -x
    tfinit $1 && \
    terraform plan -detailed-exitcode -var-file="$var_file" ${@:2}
    rc=$?
    set +x
    return $rc
}

function tfapply() {
    if [ -z "$1" ]; then
        echo "ERROR: Must supply a workspace, such as 'us-east-1'"
        echo -e "\nusage: tfapply <workspace>\n"
        return 1
    fi
    var_file="$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../../$1.tfvars"
    set -x
    tfinit "$1" && \
    [ -f "$2" ] && terraform apply "$2" || terraform apply -var-file="$var_file" ${@:2}
    rc=$?
    set +x
    return $rc
}

function tfimport() {
    if [ -z "$1" ]; then
        echo "ERROR: Must supply a workspace, such as 'us-east-1'"
        echo -e "\nusage: tfimport <workspace>\n"
        return 1
    fi
    var_file="$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../$1.tfvars"
    [ ! -f "$var_file" ] && var_file="../../$1.tfvars"
    #tfinit "$1" && \
    [ -f "$var_file" ] && terraform import -var-file="$var_file" ${@:2} || terraform import ${@:2}
}


export BASH_PROFILE_DONE=true
