#!/bin/bash

# Script pour builder et lancer l'application Cubstart dans le simulateur iPhone
# Usage: ./scripts/run-ios-simulator.sh

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Lancement de Cubstart dans le simulateur iPhone...${NC}"

# Répertoire du projet
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Configuration
SCHEME="Cubstart"
BUNDLE_ID="com.WellBe.Cubstart"
PROJECT_FILE="Cubstart.xcodeproj"

# Trouver un simulateur iPhone disponible compatible avec xcodebuild
echo -e "${BLUE}📱 Recherche d'un simulateur iPhone disponible...${NC}"

# Utiliser xcodebuild -showdestinations pour obtenir les IDs compatibles
# Chercher spécifiquement les iPhone (pas les placeholders)
SIMULATOR_INFO=$(xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -i "iPhone" | grep -i "Simulator" | grep -v "placeholder" | head -1)

if [ -z "$SIMULATOR_INFO" ]; then
    echo -e "${YELLOW}⚠️  Aucun simulateur iPhone trouvé. Tentative avec le premier simulateur iOS...${NC}"
    SIMULATOR_INFO=$(xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -i "Simulator" | grep -v "placeholder" | head -1)
fi

if [ -z "$SIMULATOR_INFO" ]; then
    echo -e "${RED}❌ Erreur: Aucun simulateur disponible trouvé${NC}"
    echo -e "${YELLOW}   Destinations disponibles :${NC}"
    xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep -E "Simulator|iPhone" | head -10 || echo "   Aucune"
    exit 1
fi

# Extraire l'ID et le nom du simulateur depuis le format xcodebuild
# Format: { platform:iOS Simulator, arch:arm64, id:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX, OS:26.0, name:iPhone 17 Pro }
SIMULATOR_ID=$(echo "$SIMULATOR_INFO" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)

if [ -z "$SIMULATOR_ID" ]; then
    # Essayer avec le format id:XXXXX
    SIMULATOR_ID=$(echo "$SIMULATOR_INFO" | grep -oE 'id:[A-F0-9-]+' | head -1 | cut -d: -f2)
fi

SIMULATOR_NAME=$(echo "$SIMULATOR_INFO" | grep -oE 'name:[^,}]+' | head -1 | cut -d: -f2 | xargs)

if [ -z "$SIMULATOR_ID" ] || [ "$SIMULATOR_ID" = "dvtdevice-DVTiOSDeviceSimulatorPlaceholder-iphonesimulator:placeholder" ]; then
    echo -e "${RED}❌ Erreur: Impossible d'extraire un ID valide du simulateur${NC}"
    echo -e "${YELLOW}   Informations brutes : $SIMULATOR_INFO${NC}"
    echo ""
    echo -e "${YELLOW}   Toutes les destinations :${NC}"
    xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -showdestinations 2>/dev/null | head -20
    exit 1
fi

echo -e "${GREEN}✓ Simulateur trouvé: ${SIMULATOR_NAME:-iPhone} ($SIMULATOR_ID)${NC}"

# Démarrer le simulateur s'il n'est pas déjà démarré
echo -e "${BLUE}🔌 Démarrage du simulateur...${NC}"
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || echo -e "${GREEN}✓ Simulateur déjà démarré${NC}"

# Ouvrir le simulateur
open -a Simulator

# Attendre que le simulateur soit prêt
echo -e "${BLUE}⏳ Attente du simulateur...${NC}"
sleep 2

# Builder l'application
echo -e "${BLUE}🔨 Compilation de l'application...${NC}"
if command -v xcpretty &> /dev/null; then
    xcodebuild \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -configuration Debug \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        | xcpretty --color --simple
    BUILD_SUCCESS=$?
else
    echo -e "${YELLOW}ℹ️  xcpretty non disponible, affichage standard...${NC}"
    xcodebuild \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -configuration Debug \
        clean build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
    BUILD_SUCCESS=$?
fi

if [ $BUILD_SUCCESS -ne 0 ]; then
    echo -e "${YELLOW}❌ Erreur lors de la compilation${NC}"
    exit 1
fi

# Trouver le chemin de l'app compilée
echo -e "${BLUE}🔍 Recherche de l'application compilée...${NC}"

# Exclure les chemins avec Index.noindex qui sont des index, pas les vrais builds
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphonesimulator/*" -type d 2>/dev/null | grep -v "Index.noindex" | head -1)

# Si pas trouvé, essayer avec BUILD_DIR depuis xcodebuild
if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠️  Recherche alternative du chemin de build...${NC}"
    BUILD_DIR=$(xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -showBuildSettings 2>/dev/null | grep -m 1 "BUILD_DIR" | grep -oEi "\/.*" | xargs)
    if [ -n "$BUILD_DIR" ]; then
        APP_PATH="$BUILD_DIR/Debug-iphonesimulator/Cubstart.app"
    fi
fi

# Dernière tentative : chercher dans le DerivedData le plus récent
if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠️  Recherche dans le dernier build...${NC}"
    LATEST_BUILD=$(ls -td ~/Library/Developer/Xcode/DerivedData/Cubstart-*/Build/Products/Debug-iphonesimulator/Cubstart.app 2>/dev/null | head -1)
    if [ -n "$LATEST_BUILD" ] && [ -d "$LATEST_BUILD" ]; then
        APP_PATH="$LATEST_BUILD"
    fi
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Erreur: Application non trouvée après le build${NC}"
    echo -e "${YELLOW}   Chemins recherchés :${NC}"
    echo "   - ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug-iphonesimulator/Cubstart.app"
    echo ""
    echo -e "${YELLOW}   Applications trouvées :${NC}"
    find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -type d 2>/dev/null | head -5 || echo "   Aucune"
    exit 1
fi

echo -e "${GREEN}✓ Application compilée: $APP_PATH${NC}"

# Installer l'application dans le simulateur
echo -e "${BLUE}📦 Installation de l'application...${NC}"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

# Lancer l'application
echo -e "${BLUE}🎬 Lancement de l'application...${NC}"
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"

echo -e "${GREEN}✅ Application lancée avec succès dans le simulateur!${NC}"

