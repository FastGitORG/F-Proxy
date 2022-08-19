#!/bin/bash

ensureRoot() {
    if [[ $(id -u) != 0 ]]; then
        log ERROR "Root is required."
        exit 1
    fi
}

setupDependency() {
    apt-get update
    apt-get install lsb-release wget curl -y
}

setupRepository() {
    curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
    apt-get update
}

installWarp() {
    apt-get install cloudflare-warp -y
    systemclt enable warp-svc.sevice
}

startWarpService() {
    echo "[WARP] Start Service"
    systemclt start warp-svc.sevice
}

setupWarp() {
    warp-cli --accept-tos register
}

startWarpProxy() {
    # default proxy is :40000
    echo "[WARP] Set Mode"
    warp-cli --accept-tos set-mode proxy
    echo "[WARP] CONNECT"
    warp-cli --accept-tos connect
    echo "[WARP] ENABLE ALWAYS ON"
    warp-cli --accept-tos enable-always-on
}

installGoSniProxy() {
    #/usr/local/bin
    #wget -O /usr/local/bin/sniproxy
    #chmod +x /usr/local/bin/sniproxy
    echo "x"
}

runGoSniProxy() {
    echo "y"
}

ensureRoot
setupDependency
setupRepository
installWarp
startWarpService
setupWarp
startWarpProxy
