#!/bin/bash

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Install the font when this script is run independently of setup_laptop.sh.
if ! command -v brew &>/dev/null; then
    echo "Homebrew is required. Run setup_laptop.sh first." >&2
    exit 1
fi
if ! brew list --cask font-kode-mono &>/dev/null; then
    brew install --cask font-kode-mono
fi

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
if [ -d "$SCRIPT_DIR/Lullaby" ]; then
    echo -e "${BLUE}==> Copying themes to $XCODE_THEMES_DIR...${NC}"
    cp "$SCRIPT_DIR"/Lullaby/*.xccolortheme "$XCODE_THEMES_DIR/"
    # Select Kode Mono themes for both appearance modes.
    defaults write com.apple.dt.Xcode XCFontAndColorCurrentDarkTheme -string "LullabyPlus.xccolortheme"
    defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string "LullabyLight.xccolortheme"
    echo -e "${GREEN}✓ Xcode themes installed with Kode Mono as the default code font. Restart Xcode to apply.${NC}"
else
    echo -e "${YELLOW}Error: '$SCRIPT_DIR/Lullaby' directory not found.${NC}" >&2
    exit 1
fi
