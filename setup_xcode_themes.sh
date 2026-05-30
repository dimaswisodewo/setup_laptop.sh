#!/bin/bash

# --- Color Definitions for Pretty Output ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==> Installing Lullaby Xcode Themes...${NC}"

XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

# Create the directory if it doesn't exist
if [ ! -d "$XCODE_THEMES_DIR" ]; then
    echo -e "${YELLOW}Creating Xcode themes directory...${NC}"
    mkdir -p "$XCODE_THEMES_DIR"
fi

# Copy all .xccolortheme files from Lullaby directory
if [ -d "./Lullaby" ]; then
    echo -e "${BLUE}==> Copying themes to $XCODE_THEMES_DIR...${NC}"
    cp ./Lullaby/*.xccolortheme "$XCODE_THEMES_DIR/"
    echo -e "${GREEN}✓ Xcode themes installation complete.${NC}"
else
    echo -e "${YELLOW}Warning: './Lullaby' directory not found. Skipping theme installation.${NC}"
fi
