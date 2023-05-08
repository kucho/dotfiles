function myip {
    dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"'
}

function gips {
    local -r g=("gcloud" "container" "clusters")
    gcloud container clusters describe ${1:-$(${g} list | fzf --height 50% --header-lines 1 --reverse | cut -d ' ' -f 1)} \
        --flatten="masterAuthorizedNetworksConfig.cidrBlocks[]" \
        --format="value(masterAuthorizedNetworksConfig.cidrBlocks.displayName:label='Name', masterAuthorizedNetworksConfig.cidrBlocks.cidrBlock:label='IP')"
}

function listening {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}
