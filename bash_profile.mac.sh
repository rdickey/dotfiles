# TODO: combine the common parts of bash_profile.linux and bash_profile.mac and only have the small differences in each
#echo sourcing .bash_profile

[[ -f /etc/profile ]] && . /etc/profile
[[ -f ~/.aws.sh ]] && . ~/.aws.sh
export EDITOR="/usr/bin/vim"
export HISTFILESIZE=1048576
export LSCOLORS="cxgxcbdbdxegeddxdxcxcx"
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

for f in ~/.bash_functions*; do
    source $f
done

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
    if [ -d "$(brew --prefix)/bash_completion.d" ]; then
        for f in `find $(brew --prefix)/bash_completion.d/*`; do
            source "$f" 2>/dev/null
        done
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
alias egrep="egrep --color --exclude-dir .terragrunt-cache"
# This is a hack so that things like "sudo vi" will evaluate as "sudo vim".
# Otherwise, bash would only evaluate the alias for sudo (if any), not whatever came after it.
alias sudo="sudo "
alias fixcursor="setterm -cursor on"

alias ffs='sudo $(history -p \!\!)'
[[ -f `which thefuck` ]] && eval "$(thefuck --alias)"

alias bitchen='kitchen'

alias hd="helm -n develop"
alias hs="helm -n staging"
alias hp="helm -n production"
alias hm="helm -n monitoring"
alias hsy="helm -n kube-system"
alias hk="helm -n kube-system"
alias kd="kubectl -n develop"
alias ks="kubectl -n staging"
alias kp="kubectl -n production"
alias km="kubectl -n monitoring"
alias kk="kubectl -n kube-system"
alias ksy="kubectl -n kube-system"
alias k9d="k9s -n develop"
alias k9s="k9s -n staging"
alias k9p="k9s -n production"
alias k9m="k9s -n monitoring"
alias k9k="k9s -n kube-system"
alias k9sy="k9s -n kube-system"
alias k9a="k9s -A"

alias label_nodes="for f in \`kubectl get nodes | grep none | awk '{print \$1}'\`; do NG=\`kubectl describe node \$f | grep nodegroup-name | cut -d = -f 2\`; echo \$f \$NG; kubectl label node \$f node-role.kubernetes.io/\${NG}=true ; done"

export LESS="-x4 -FXR"

#complete -C aws_completer aws

[[ -s "$HOME/.bash_custom" ]] && source "$HOME/.bash_custom"
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -d "$HOME/.rvm/bin" ]] && [[ -z "`echo $PATH | grep $HOME/.rvm/bin`" ]] && export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -d "/usr/local/sbin" ]] && [[ -z "`echo $PATH | grep /usr/local/sbin`" ]] && export PATH="$PATH:/usr/local/sbin"

### Added by the Heroku Toolbelt
[[ -d "/usr/local/heroku/bin" ]] && export PATH="/usr/local/heroku/bin:$PATH"

#alias fixws="wmctrl -R Wireshark -e 0,100,300,1600,1000"
alias fixws="wmctrl -R Wireshark -e 0,1000,1200,1600,1000"

# MacPorts Installer addition
[[ -d "/opt/local/bin" ]] && export PATH="/opt/local/sbin:$PATH"
[[ -d "/opt/local/sbin" ]] && export PATH="/opt/local/sbin:$PATH"

#[[ -n "`which boot2docker`" ]] && eval "$(boot2docker shellinit 2>/dev/null)"

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

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

### CRITICAL Go ENV variables
[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"
export GOPATH=${HOME}
[[ -d $GOROOT ]] && [[ -z "`echo $PATH | grep $GOROOT`" ]] && export PATH=$PATH:$GOROOT
[[ -d $GOPATH ]] &&  [[ -z "`echo $PATH | grep $GOPATH/bin`" ]] &&export PATH=$PATH:$GOPATH/bin
[[ -z $GOPATH && -d $HOME/go ]] && export GOPATH=$HOME/go
[[ -d /usr/local/opt/go/libexec/bin ]] && [[ -z "`echo $PATH | grep /usr/local/opt/go/libexec/bin`" ]] && export PATH=$PATH:/usr/local/opt/go/libexec/bin

[[ -s "/Users/rdickey/.gvm/scripts/gvm" ]] && source "/Users/rdickey/.gvm/scripts/gvm"

MONGO_BIN_PATH="/usr/local/opt/mongodb-community@4.0/bin"
[[ -d $MONGO_BIN_PATH ]] && export PATH=$MONGO_BIN_PATH:$PATH

export BASH_SILENCE_DEPRECATION_WARNING=1

# Stuff for kafka
[[ -d /usr/local/opt/openjdk@17/bin ]] && export PATH=/usr/local/opt/openjdk@17/bin:$PATH
[[ -d /Users/rdickey/kafka/kafka_2.13-2.8.2/bin ]] && export PATH=/Users/rdickey/kafka/kafka_2.13-2.8.2/bin:$PATH

#AWSume alias to source the AWSume script
alias awsume="source awsume"

#Auto-Complete function for AWSume
_awsume() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(awsume-autocomplete)
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _awsume awsume

export BASH_PROFILE_DONE=true

#export AWS_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem
#export CURL_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem
#export SSL_CERT_FILE=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem
#export GIT_SSL_CAPATH=/Library/Application\ Support/Netskope/STAgent/data/netskope-cert-bundle.pem

unset AWS_CA_BUNDLE
unset CURL_CA_BUNDLE
unset SSL_CERT_FILE
unset GIT_SSL_CAPATH
