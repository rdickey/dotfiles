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
