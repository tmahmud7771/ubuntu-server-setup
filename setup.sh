#!/bin/bash

# =========================================
# Ultimate Ubuntu Dev Setup
# ZSH + OhMyZSH + UV + NVM + Node LTS
# MongoDB + Redis
# =========================================

clear

echo "========================================="
echo " Ubuntu Ultimate Dev Environment Setup"
echo "========================================="
echo ""

# Ask sudo password once
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# -----------------------------------------
# System Update
# -----------------------------------------
echo ""
echo "[1/8] Updating system..."
sudo apt update && sudo apt upgrade -y

# -----------------------------------------
# Install Base Packages
# -----------------------------------------
echo ""
echo "[2/8] Installing dependencies..."

sudo apt install -y \
curl \
wget \
git \
gnupg \
build-essential \
ca-certificates \
software-properties-common \
apt-transport-https \
zsh \
redis-server

# -----------------------------------------
# Install Oh My Zsh
# -----------------------------------------
echo ""
echo "[3/8] Installing Oh My Zsh..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# -----------------------------------------
# Install ZSH Plugins
# -----------------------------------------
echo ""
echo "[4/8] Installing ZSH plugins..."

git clone https://github.com/zsh-users/zsh-autosuggestions \
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null

# Update plugins
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Set ZSH default shell
chsh -s $(which zsh)

# -----------------------------------------
# Install UV
# -----------------------------------------
echo ""
echo "[5/8] Installing UV..."

curl -LsSf https://astral.sh/uv/install.sh | sh

echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc

# -----------------------------------------
# Install NVM + Node.js LTS
# -----------------------------------------
echo ""
echo "[6/8] Installing NVM + Node.js LTS..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts
nvm alias default lts/*

# -----------------------------------------
# Install MongoDB
# -----------------------------------------
echo ""
echo "[7/8] Installing MongoDB..."

UBUNTU_VERSION=$(lsb_release -rs)

curl -fsSL https://pgp.mongodb.com/server-8.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
--dearmor

if [[ "$UBUNTU_VERSION" == "24.04" ]]; then
    DISTRO="noble"
elif [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    DISTRO="jammy"
elif [[ "$UBUNTU_VERSION" == "20.04" ]]; then
    DISTRO="focal"
else
    echo "Unsupported Ubuntu version"
    exit 1
fi

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $DISTRO/mongodb-org/8.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt update
sudo apt install -y mongodb-org

sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl start mongod

# -----------------------------------------
# Start Redis
# -----------------------------------------
echo ""
echo "[8/8] Starting Redis..."

sudo systemctl enable redis-server
sudo systemctl start redis-server

# -----------------------------------------
# Finished
# -----------------------------------------

clear

echo "========================================="
echo " Setup Complete Successfully!"
echo "========================================="
echo ""

echo "Installed:"
echo "✔ ZSH"
echo "✔ Oh My Zsh"
echo "✔ ZSH Autosuggestions"
echo "✔ ZSH Syntax Highlighting"
echo "✔ UV Package Manager"
echo "✔ NVM"
echo "✔ Node.js LTS"
echo "✔ MongoDB 8"
echo "✔ Redis"
echo ""

echo "MongoDB Status:"
sudo systemctl is-active mongod

echo ""
echo "Redis Status:"
sudo systemctl is-active redis-server

echo ""
echo "Run these after restart:"
echo "source ~/.zshrc"

echo ""
echo "Mongo Shell:"
echo "mongosh"

echo ""
echo "Redis CLI:"
echo "redis-cli"

echo ""
echo "Restart terminal now."
