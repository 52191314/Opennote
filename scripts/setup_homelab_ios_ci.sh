#!/usr/bin/env bash
# 🤖 Generated wholely or partially with Claude Code; Google Antigravity
#
# Setup script to prepare an Ubuntu Homelab host to run iOS CI via Docker-OSX & GitHub Actions Self-Hosted Runner.

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

# 3. Create persistent storage for macOS container
DISK_DIR="${HOME}/docker-osx-disk"
mkdir -p "${DISK_DIR}"
echo "✅ Disk directory ready at: ${DISK_DIR}"

echo ""
echo "------------------------------------------------------------"
echo " Launching Docker-OSX Container"
echo "------------------------------------------------------------"
echo "Command to run macOS with KVM acceleration:"
echo ""
echo "docker run -it \\"
echo "    --device /dev/kvm \\"
echo "    -p 50922:10022 \\"
echo "    -v ${DISK_DIR}:/image \\"
echo "    -e RAM=12 \\"
echo "    -e CPU_CORES=6 \\"
echo "    -e HEADLESS=true \\"
echo "    sickcodes/docker-osx:auto"
echo ""
echo "------------------------------------------------------------"
echo " Once inside the macOS VM:"
echo "------------------------------------------------------------"
echo " 1. Install Xcode Command Line Tools: xcode-select --install"
echo " 2. Install Xcode.app and accept license: sudo xcodebuild -license accept"
echo " 3. Register GitHub Actions Self-Hosted Runner:"
echo "    - Go to GitHub -> Repo Settings -> Actions -> Runners -> New runner -> macOS"
echo "    - When running ./config.sh, add custom labels: --labels self-hosted,macOS,homelab"
echo "    - Install runner as a daemon: sudo ./svc.sh install && sudo ./svc.sh start"
echo ""
echo "✅ Setup complete! Your homelab is ready to build iOS applications."
