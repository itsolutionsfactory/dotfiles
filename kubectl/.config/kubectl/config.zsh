# Kubectl aliases and settings

# Load kubectl completion
source ~/.config/kubectl/completion.zsh

# Kubectl aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ka='kubectl apply'
alias kx='kubectl exec -it'
alias kc='kubectl config'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Get pods
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kubectl get pods -o wide'

# Get deployments
alias kgd='kubectl get deployments'
alias kgda='kubectl get deployments --all-namespaces'

# Get services
alias kgs='kubectl get services'
alias kgsa='kubectl get services --all-namespaces'

# Get nodes
alias kgn='kubectl get nodes'
alias kgno='kubectl get nodes -o wide'

# Get namespaces
alias kgns='kubectl get namespaces'

# Port forwarding
alias kpf='kubectl port-forward'

# Set default namespace
function ksetns() {
    kubectl config set-context --current --namespace="$1"
}

# Get pod logs with follow
function klogf() {
    kubectl logs -f "$1"
}

# Get pod logs with previous
function klogp() {
    kubectl logs --previous "$1"
}

# Delete pod
function kdp() {
    kubectl delete pod "$1"
}

# Get pod details
function kdpod() {
    kubectl describe pod "$1"
}

# Get service details
function kdsvc() {
    kubectl describe service "$1"
}

# Get deployment details
function kddeploy() {
    kubectl describe deployment "$1"
}

# Get all resources in namespace
function kall() {
    kubectl get all -n "$1"
}

# Set KUBECONFIG environment variable
export KUBECONFIG=~/.kube/config

# Add kubectl plugins to PATH
export PATH="${PATH}:${HOME}/.kube/plugins" 