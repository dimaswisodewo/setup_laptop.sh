#!/bin/bash

# ==============================================================================
# MacBook Setup Script
# Description: Automates the installation of Brew packages, casks, and AI CLI tools.
#              Also migrates local configurations to ~/.config.
# ==============================================================================

# --- Color Definitions for Pretty Output ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==> Starting Laptop Setup...${NC}"

# 1. Check for Homebrew, install if not present
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to path for the current session (Intel and Apple Silicon)
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}✓ Homebrew is already installed.${NC}"
fi

# 2. SCALABLE BREW INSTALLATION
# Add any new packages or casks to these arrays to expand the setup.

# Terminal tools and utilities
PACKAGES=(
    "starship"
    "lazygit"
    "git-delta"
    "ripgrep"
    "dimaswisodewo/tools/sshwitch"
    "fzf"
    "zsh-autocomplete"
)

# GUI Applications and Fonts
CASKS=(
    "ghostty"
    "fork"
    "codex"
)

echo -e "${BLUE}==> Updating Homebrew...${NC}"
brew update -v

echo -e "${BLUE}==> Installing Brew Formulae...${NC}"
for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        echo -e "${GREEN}✓ $pkg is already installed.${NC}"
    else
        echo -e "${YELLOW}Installing $pkg...${NC}"
        brew install "$pkg"
    fi
done

echo -e "${BLUE}==> Installing Brew Casks...${NC}"
for cask in "${CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo -e "${GREEN}✓ $cask is already installed.${NC}"
    else
        echo -e "${YELLOW}Installing $cask...${NC}"
        brew install --cask "$cask"
    fi
done

# 3. AI CLI TOOLS (via NPM)
# Ensure Node is ready before installing global tools
echo -e "${BLUE}==> Installing AI CLI Tools...${NC}"
NPM_TOOLS=(
    "@google/gemini-cli"
    "@anthropic-ai/claude-code"
)

for tool in "${NPM_TOOLS[@]}"; do
    echo -e "${YELLOW}Installing $tool globally...${NC}"
    npm install -g "$tool"
done

# 4. CONFIGURATION MIGRATION
# This section copies contents from the local 'config' folder to ~/.config
if [ -d "./config" ]; then
    echo -e "${BLUE}==> Migrating configurations to ~/.config...${NC}"
    mkdir -p "$HOME/.config"
    # Sync folders while preserving structure. 
    # NOTE: Does not delete existing files in ~/.config
    cp -R ./config/ "$HOME/.config/"
    echo -e "${GREEN}✓ Configuration migration complete.${NC}"
else
    echo -e "${YELLOW}Warning: './config' directory not found. Skipping config migration.${NC}"
fi

# 5. SHELL INTEGRATION
# Setup Starship prompt in .zshrc if not already there
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
    echo -e "${BLUE}==> Adding Starship initialization to .zshrc...${NC}"
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
else
    echo -e "${GREEN}✓ Starship already configured in .zshrc.${NC}"
fi

# 6. LAZYGIT CONFIGURATION
LAZYGIT_CONFIG_DIR="$HOME/Library/Application Support/lazygit"
LAZYGIT_LOCAL_CONFIG="./config/lazygit/config.yml"

echo -e "${BLUE}==> Configuring Lazygit custom pager...${NC}"
mkdir -p "$LAZYGIT_CONFIG_DIR"

if [ -f "$LAZYGIT_LOCAL_CONFIG" ]; then
    cp "$LAZYGIT_LOCAL_CONFIG" "$LAZYGIT_CONFIG_DIR/config.yml"
    echo -e "${GREEN}✓ Lazygit configuration migrated.${NC}"
else
    echo -e "${YELLOW}Warning: '$LAZYGIT_LOCAL_CONFIG' not found. Skipping.${NC}"
fi

# Setup fzf integration
if ! grep -q 'fzf --zsh' "$HOME/.zshrc"; then
    echo -e "${BLUE}==> Adding fzf initialization to .zshrc...${NC}"
    echo 'eval "$(fzf --zsh)"' >> "$HOME/.zshrc"
else
    echo -e "${GREEN}✓ fzf already configured in .zshrc.${NC}"
fi

# Setup zsh-autocomplete
if ! grep -q 'zsh-autocomplete.plugin.zsh' "$HOME/.zshrc"; then
    echo -e "${BLUE}==> Adding zsh-autocomplete to .zshrc...${NC}"
    # Using brew --prefix to dynamically find the path for both Apple Silicon and Intel
    echo 'source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh' >> "$HOME/.zshrc"
else
    echo -e "${GREEN}✓ zsh-autocomplete already configured in .zshrc.${NC}"
fi

# 7. GIT DELTA CONFIGURATION
echo -e "${BLUE}==> Configuring Git Delta...${NC}"
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global merge.conflictstyle "zdiff3"
echo -e "${GREEN}✓ Git Delta configured.${NC}"

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Setup Complete! Please restart your    ${NC}"
echo -e "${GREEN}    terminal or run: source ~/.zshrc      ${NC}"
echo -e "${GREEN}==========================================${NC}"
