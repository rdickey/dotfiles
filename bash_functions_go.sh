[[ -z $GOPATH && -d $HOME/go ]] && export GOPATH=$HOME/go
[[ -d /usr/local/opt/go/libexec/bin ]] && export PATH=$PATH:/usr/local/opt/go/libexec/bin
[[ -d $GOPATH ]] && export PATH=$PATH:$GOPATH/bin
