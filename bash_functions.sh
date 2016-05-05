# To be sourced in bash_profile

function find_git_branch {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head == ref:\ refs/heads/* ]]; then
                git_branch="${head#*/*/}"
            elif [[ $head != '' ]]; then
                git_branch='(detached)'
            else
                git_branch='(unknown)'
            fi

            # requires the following .gitconfig alias:
            # unpushed = !GIT_CURRENT_BRANCH=$(git name-rev --name-only HEAD) && git log origin/$GIT_CURRENT_BRANCH..$GIT_CURRENT_BRANCH --oneline
            if [[ -n $(git branch   2> /dev/null) ]] && [[ -n $(git unpushed 2> /dev/null) ]]; then
                git_branch="${git_branch}(`git unpushed | wc -l | tr -d ' \n'`)"
            fi

            if [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]]; then
                git_branch="${git_branch}*"
            fi

            git_branch="$git_branch "
            return
        fi
        dir="../$dir"
    done
    git_branch=''
}
function munge_path {
    if [ -n "`which ruby 2>/dev/null`" ]; then
        munged_path=`ruby -e "y='$PWD'.sub('$HOME','~');x='';p=y.split('/');x+='.../' if p.length > 4; x+=p[[0,p.length-4].max,p.length].join('/');x+='/' if p.length==0;if x.length < y.length then print x; else print y; end;"`
        # TODO: rewrite this to not use ruby.  hints:
        # echo $name | egrep -o '/' | wc -w
        # echo $name | cut -d '/' -f 5-7
    else
        munged_path=$PWD
        [[ "$munged_path" =~ ^"$HOME"(/|$) ]] && munged_path="~${name#$HOME}"
    fi
}


function go {
    for U in ec2-user ubuntu centos root $USER; do
        ssh -oConnectTimeout=1 -oUser=$U $* && return
    done
}

function goo {
    while true; do date;go $1 && return; sleep 1; done
}

function gooo {
    while true; do date;go $1; sleep 1; done
}

function goi {
    ip=`echo $1 | sed 's/ec2//' | egrep -o '[0-9]+-[0-9]+-[0-9]+-[0-9]+' | sed -e 's/-/./g'`
    if [ -n "$ip" ]; then
        echo "Connecting to ip $ip"
        go $ip
    else
        echo "Could not get ip for $1.  Maybe it's ill formatted?"
    fi
}

function goa {
    host=`aws ec2 describe-instances --output text |grep $1 | egrep -o 'ec2-[0-9-]+.[a-z0-9-]+.amazonaws.com' | head -1`
    if [ -n "$host" ]; then
        echo "Connecting to host $host"
        go $host
    else
        echo "Could not get hostname for $1.  Maybe it doesn't exist?"
    fi
}

function goid {
    hostname=`aws ec2 describe-instances --instance-ids $1 --output text | egrep INSTANCES | egrep -o 'ec2-.+amazonaws.com' | head -n 1`
    if [ -n "$hostname" ]; then
        echo "Connecting to hostname $hostname"
        go $hostname
    else
        echo "Couldn't get hostname for id $1.  Maybe it died?"
    fi
}
