$ErrorActionPreference = "Stop"

Write-Host "===================================="
Write-Host "Setting up Linux DevBox"
Write-Host "===================================="

# Update system
Write-Host "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install essential packages
Write-Host "Installing essential packages..."
sudo apt-get install -y `
    zsh `
    tmux `
    git `
    curl `
    wget `
    build-essential `
    ca-certificates `
    gnupg `
    lsb-release `
    unzip `
    jq

# Install Oh My Zsh
Write-Host "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Powerlevel10k theme
Write-Host "Installing Powerlevel10k..."
$ZSH_CUSTOM = if ($env:ZSH_CUSTOM) { $env:ZSH_CUSTOM } else { "$HOME/.oh-my-zsh/custom" }
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

# Install zsh plugins
Write-Host "Installing zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Set zsh as default shell
Write-Host "Setting zsh as default shell..."
$zshPath = (which zsh)
$currentUser = (whoami)
sudo chsh -s $zshPath $currentUser

# Install Azure CLI
Write-Host "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install GitHub CLI
Write-Host "Installing GitHub CLI..."
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
$arch = dpkg --print-architecture
echo "deb [arch=$arch signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# Install GitHub Copilot CLI
Write-Host "Installing GitHub Copilot CLI..."
curl -fsSL https://gh.io/copilot-install | sudo bash

# Install Visual Studio Code Insiders
Write-Host "Installing Visual Studio Code Insiders..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
Remove-Item -Force packages.microsoft.gpg -ErrorAction SilentlyContinue
sudo apt-get update
sudo apt-get install -y code-insiders

# Install Neovim (latest stable from PPA)
Write-Host "Installing Neovim..."
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install -y neovim

# Install NVM and Node.js
Write-Host "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
$env:NVM_DIR = "$HOME/.nvm"
. "$env:NVM_DIR/nvm.sh"
Write-Host "Installing Node.js LTS..."
nvm install --lts

# Install kubectl
Write-Host "Installing kubectl..."
$stableVersion = (curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$stableVersion/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
Remove-Item kubectl -ErrorAction SilentlyContinue

# Install kubectx and kubens
Write-Host "Installing kubectx and kubens..."
sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx
sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens
sudo chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# Install krew (kubectl plugin manager)
Write-Host "Installing krew..."
$tempDir = (mktemp -d)
Push-Location $tempDir
$OS = (uname).ToLower()
$ARCH = (uname -m) -replace 'x86_64','amd64' -replace 'aarch64','arm64'
$KREW = "krew-${OS}_${ARCH}"
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
tar zxvf "${KREW}.tar.gz"
& "./${KREW}" install krew
Pop-Location

# Install OpenTofu (Terraform alternative)
Write-Host "Installing OpenTofu..."
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
Remove-Item install-opentofu.sh -ErrorAction SilentlyContinue

# Clean up
Write-Host "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

Write-Host ""
Write-Host "===================================="
Write-Host "Installation Complete!"
Write-Host "===================================="
Write-Host ""
Write-Host "Installed tools:"
Write-Host "  - zsh $(zsh --version)"
Write-Host "  - oh-my-zsh + powerlevel10k"
Write-Host "  - tmux $(tmux -V)"
Write-Host "  - git $(git --version)"
$nodeVersion = try { node --version } catch { "installed via nvm" }
Write-Host "  - Node.js $nodeVersion"
$kubectlVersion = try { (kubectl version --client -o json 2>$null | ConvertFrom-Json).clientVersion.gitVersion } catch { "installed" }
Write-Host "  - kubectl $kubectlVersion"
Write-Host "  - kubectx and kubens"
Write-Host "  - krew (kubectl plugin manager)"
Write-Host "  - OpenTofu (terraform alias)"
$azVersion = try { az version --output tsv --query '"azure-cli"' 2>$null } catch { "installed" }
Write-Host "  - Azure CLI $azVersion"
$ghVersion = (gh --version | Select-Object -First 1)
Write-Host "  - GitHub CLI $ghVersion"
$nvimVersion = (nvim --version | Select-Object -First 1)
Write-Host "  - Neovim $nvimVersion"
Write-Host "  - GitHub Copilot CLI (copilot)"
Write-Host "  - VS Code Insiders (code-insiders)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Authenticate with GitHub: gh auth login"
Write-Host "  2. Authenticate with Azure: az login"
Write-Host "  3. Configure git: git config --global user.name 'Your Name'"
Write-Host "  4. Configure git: git config --global user.email 'your@email.com'"
Write-Host ""
