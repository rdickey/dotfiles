# Replace rd with your deployment ID
alias k="kubectl -n ns-user-rd"
alias kpo="kubectl -n ns-user-rd get po -o wide"
alias kdeploy="kubectl -n ns-user-rd get deploy -o wide"
alias ksvc="kubectl -n ns-user-rd get svc -o wide"

function guestbook() {
    if [ -z "$1" ]
    then
        echo "ClusterID for guestbook argument not supplied"
        return 1
    fi
    cd $HOME/src/gitlab-odx.oracle.com/odx/oke/k8s-manager
    ./scripts/dtenant-manager instances kubeconfig $1 > $HOME/src/kubeconfig.$1
    kubectl create -f ~/src/gitlab-odx.oracle.com/odx/oke/end2end/examples/guestbook-all-in-one-dns.yaml --kubeconfig=$HOME/src/kubeconfig.$1
    kubectl get services/frontend --kubeconfig=$HOME/src/kubeconfig.$1
    kubectl get nodes --kubeconfig=$HOME/src/kubeconfig.$1

    CLUSTER_IP=`kubectl get nodes --kubeconfig=$HOME/src/kubeconfig.$1 -o yaml | grep external.ipaddress | head -n 3 | tail -n 1 | awk '{print $2 }'`
    NODEPORT=`kubectl get services/frontend --kubeconfig=$HOME/src/kubeconfig.$1 -o yaml | grep nodePort: | awk '{print $3 }'`

    open http://$CLUSTER_IP:$NODEPORT
    popd
}
