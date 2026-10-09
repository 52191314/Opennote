#!/usr/bin/env bash
# 🤖 Generated wholely or partially with Claude Code; Google Antigravity
#
# Setup script to prepare an Ubuntu Homelab host to run iOS CI via dockurr/macos & GitHub Actions Self-Hosted Runner.

set -euo pipefail

echo "============================================================"
echo " Opennote Ubuntu Homelab iOS CI Runner Setup"
echo "============================================================"

# 1. Verify KVM hardware acceleration
if [ ! -e /dev/kvm ]; then
    echo "❌ /dev/kvm is not accessible on this host."
    echo "Ensure Intel VT-x or AMD-V is enabled in your BIOS."
    echo "Install KVM tools with: sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils"
    exit 1
fi
echo "✅ /dev/kvm found."

# 2. Check user group
if ! groups "$USER" | grep -q '\bkvm\b'; then
    echo "Adding $USER to kvm group..."
    sudo usermod -aG kvm "$USER"
    echo "⚠️ Group membership updated. You may need to run 'newgrp kvm' or re-login."
fi

# 3. Create persistent storage directory
STORAGE_DIR="/opt/dockur-macos"
mkdir -p "${STORAGE_DIR}/data"
echo "✅ Persistent storage ready at: ${STORAGE_DIR}/data"

echo ""
echo "------------------------------------------------------------"
echo " macOS Runner Container Deployment (dockurr/macos)"
echo "------------------------------------------------------------"
echo "Container manages macOS Sonoma with web viewer on port 8006."
echo "Access installation in browser at: http://<server-ip>:8006"
echo ""
echo "Compose location: ${STORAGE_DIR}/docker-compose.yml"
echo "Start command: (cd ${STORAGE_DIR} && docker compose up -d)"
echo ""
echo "------------------------------------------------------------"
echo " Once macOS Sonoma installation completes:"
echo "------------------------------------------------------------"
echo " 1. Access GUI at http://<server-ip>:8006 or VNC at <server-ip>:5900"
echo " 2. Install Xcode Command Line Tools: xcode-select --install"
echo " 3. Install Xcode.app and accept license: sudo xcodebuild -license accept"
echo " 4. Register GitHub Actions Self-Hosted Runner:"
echo "    - Go to GitHub -> Repo Settings -> Actions -> Runners -> New runner -> macOS"
echo "    - When running ./config.sh, add custom labels: --labels self-hosted,macOS,homelab"
echo "    - Install runner as a daemon: sudo ./svc.sh install && sudo ./svc.sh start"
echo ""
echo "✅ Setup complete! Your homelab is ready to build iOS applications."

