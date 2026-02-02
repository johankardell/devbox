#!/bin/bash
set -e

echo "===================================="
echo "Setting up Linux DevBox"
echo "===================================="

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install zsh
echo "Installing zsh..."
sudo apt-get install -y zsh

# Install tmux
echo "Installing tmux..."
sudo apt-get install -y tmux

# Install git
echo "Installing git..."
sudo apt-get install -y git

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh plugins
echo "Installing zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy zsh configuration files
echo "Setting up zsh configuration..."
if [ -f .zshrc ]; then
    cp .zshrc ~/.zshrc
    echo "✓ Copied .zshrc"
fi

if [ -f .p10k.zsh ]; then
    cp .p10k.zsh ~/.p10k.zsh
    echo "✓ Copied .p10k.zsh"
fi

# Change default shell to zsh
echo "Setting zsh as default shell..."
sudo chsh -s $(which zsh) $USER

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install GitHub CLI
echo "Installing GitHub CLI..."
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# GitHub Copilot is now built into gh CLI (gh copilot commands)
# No separate extension installation needed

# Install Visual Studio Code Insiders
echo "Installing Visual Studio Code Insiders..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt-get update
sudo apt-get install -y code-insiders

# Install useful development tools
echo "Installing additional development tools..."
sudo apt-get install -y \
    curl \
    wget \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release

# Clean up
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

echo ""
echo "===================================="
echo "Installation Complete!"
echo "===================================="
echo ""
echo "Installed tools:"
echo "  - zsh with Oh My Zsh and Powerlevel10k"
echo "  - tmux $(tmux -V)"
echo "  - git $(git --version)"
echo "  - Azure CLI $(az version --output tsv --query '\"azure-cli\"' 2>/dev/null || echo 'installed')"
echo "  - GitHub CLI $(gh --version | head -1)"
echo "  - GitHub Copilot (gh copilot) - built into gh CLI"
echo "  - VS Code Insiders (code-insiders)"
echo ""
echo "Next steps:"
echo "  1. Logout and login again (or run: exec zsh) to use zsh"
echo "  2. Authenticate with GitHub: gh auth login"
echo "  3. Authenticate with Azure: az login --use-device-code"
echo "  4. Configure git: git config --global user.name 'Your Name'"
echo "  5. Configure git: git config --global user.email 'your@email.com'"
echo ""
