#!/bin/bash

ensureRoot() {
    if [[ $(id -u) != 0 ]]; then
        echo -e "\e[0;31m[PERMISSION] Root is requried\e[0m"
        log ERROR "Root is required."
        exit 1
    fi
}

prepare() {
    echo -e "\e[0;36m[APT] Preparing...\e[0m"
    apt-get update
    apt-get install lsb-release wget curl gnupg -y
    apt-key del 835b8acb
    curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
    apt-get update
}

installWarp() {
    echo -e "\e[0;36m[APT] Installing warp...\e[0m"
    apt-get install cloudflare-warp -y
    echo -e "\e[0;36m[WARP] Enable warp...\e[0m"
    systemctl enable warp-svc
    echo -e "\e[0;36m[WARP] Starting warp...\e[0m"
    systemctl start warp-svc
    echo -e "\e[0;36m[WARP] Register device...\e[0m"
    warp-cli --accept-tos register
}

initWarp() {
    # default proxy is :40000
    echo -e "\e[0;36m[WARP] Setting Proxy Mode...\e[0m"
    warp-cli --accept-tos set-mode proxy
    echo -e "\e[0;36m[WARP] Connecting...\e[0m"
    warp-cli --accept-tos connect
    echo -e "\e[0;36m[WARP] Enable always on...\e[0m"
    warp-cli --accept-tos enable-always-on
}

installAgent() {
    #/usr/local/bin
    mkdir -p /etc/f-proxy
    echo -e "\e[0;36m[AGENT] Downloading...\e[0m"
    if service --status-all | grep -Fq 'f-proxy'; then    
        systemctl stop f-proxy
    fi
    rm /usr/local/bin/f-proxy-agent
    wget -O /usr/local/bin/f-proxy-agent https://github.com/FastGitORG/F-Proxy-Agent/releases/latest/download/proxy
    chmod +x /usr/local/bin/f-proxy-agent
    echo -e "\e[0;36m[AGENT] Installing service...\e[0m"
    cp config.yaml /etc/f-proxy
    cp f-proxy.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable f-proxy
    echo -e "\e[0;36m[AGENT] Start service...\e[0m"
    systemctl start f-proxy
}

set -e # if failed exit
ensureRoot
prepare

installWarp
initWarp

installAgent
