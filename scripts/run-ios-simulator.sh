#!/bin/bash

# Script to open Xcode project for launching the app in the simulator
# Usage: ./scripts/run-ios-simulator.sh

# Colors for messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Opening Xcode project...${NC}"

# Get project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Project file
PROJECT_FILE="Cubstart.xcodeproj"

# Check if project file exists
if [ ! -d "$PROJECT_FILE" ]; then
    echo -e "❌ Error: Project file not found: $PROJECT_FILE"
    exit 1
fi

# Open Xcode with the project
echo -e "${BLUE}📱 Opening Xcode...${NC}"
open "$PROJECT_FILE"

echo -e "${GREEN}✅ Xcode opened!${NC}"
echo -e "${GREEN}💡 Press ⌘R in Xcode to build and run the app in the simulator${NC}"

