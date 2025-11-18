#!/bin/bash
sudo apt-get install gnupg apt-transport-https
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
sudo apt update
sudo WAZUH_MANAGER="wazuh.lan.zoba.cc" WAZUH_MANAGER_PORT="11514" apt-get install wazuh-agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent.service
sudo systemctl start wazuh-agent.service
