#!/bin/bash

# Script pour builder et lancer l'application Cubstart sur un iPhone physique
# Usage: ./scripts/run-ios-device.sh

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 Lancement de Cubstart sur iPhone physique...${NC}"

# Répertoire du projet
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Configuration
SCHEME="Cubstart"
BUNDLE_ID="com.WellBe.Cubstart"
PROJECT_FILE="Cubstart.xcodeproj"

# Vérifier que devicectl est disponible
if ! command -v xcrun &> /dev/null || ! xcrun devicectl --help &> /dev/null; then
    echo -e "${RED}❌ Erreur: xcrun devicectl n'est pas disponible${NC}"
    echo -e "${YELLOW}   Assurez-vous d'avoir Xcode installé et mis à jour${NC}"
    exit 1
fi

# Trouver un iPhone connecté
echo -e "${BLUE}🔍 Recherche d'un iPhone connecté...${NC}"

# Essayer plusieurs méthodes pour trouver l'iPhone
DEVICE_INFO=""
DEVICE_UDID=""

# Méthode 1: devicectl (moderne)
DEVICE_INFO=$(xcrun devicectl list devices 2>/dev/null | grep -i "iPhone" | grep -v "Simulator" | head -1)

# Méthode 2: instruments (ancienne méthode, parfois plus fiable)
if [ -z "$DEVICE_INFO" ]; then
    DEVICE_INFO=$(xcrun instruments -s devices 2>/dev/null | grep -i "iPhone" | grep -v "Simulator" | head -1)
fi

if [ -z "$DEVICE_INFO" ]; then
    echo -e "${RED}❌ Aucun iPhone physique trouvé${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Étapes de dépannage :${NC}"
    echo ""
    echo "1. ✅ Vérifiez que votre iPhone est connecté au Mac avec un câble USB"
    echo "2. ✅ Sur votre iPhone :"
    echo "   - Déverrouillez l'écran"
    echo "   - Si une alerte apparaît : 'Faire confiance à cet ordinateur ?'"
    echo "     → Appuyez sur 'Faire confiance'"
    echo "   - Entrez votre code PIN si demandé"
    echo ""
    echo "3. ✅ Essayez un autre câble USB ou un autre port USB"
    echo ""
    echo "4. ✅ Exécutez le diagnostic :"
    echo "   ./scripts/diagnostic-iphone.sh"
    echo ""
    echo -e "${BLUE}   Appareils actuellement détectés :${NC}"
    xcrun devicectl list devices 2>/dev/null || echo "   Aucun appareil détecté"
    echo ""
    echo -e "${YELLOW}💡 En attendant, vous pouvez tester sur simulateur avec :${NC}"
    echo "   ./scripts/run-ios-simulator.sh"
    echo "   ou appuyez sur Cmd+Shift+R dans Cursor"
    exit 1
fi

# Extraire l'UDID et le nom
echo -e "${BLUE}   Informations brutes : $DEVICE_INFO${NC}"

# Essayer plusieurs formats d'UDID
# Format 1: avec tirets (00008110-00123456789ABCDE)
DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)

# Format 2: avec tirets courts (00008110-0012-3456-789A-BCDE)
if [ -z "$DEVICE_UDID" ]; then
    DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
fi

# Format 3: entre parenthèses (format instruments)
if [ -z "$DEVICE_UDID" ]; then
    DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -oE '\([A-F0-9-]+\)' | tr -d '()' | head -1)
fi

# Format 4: sans tirets (40 caractères hex)
if [ -z "$DEVICE_UDID" ]; then
    DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{40}' | head -1)
fi

# Format 5: UUID standard
if [ -z "$DEVICE_UDID" ]; then
    DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
fi

DEVICE_NAME=$(echo "$DEVICE_INFO" | sed 's/.*iPhone[^|(]*[|(]*\([^)|]*\).*/\1/' | xargs | head -1)

if [ -z "$DEVICE_UDID" ]; then
    echo -e "${RED}❌ Impossible de trouver l'UDID de l'iPhone${NC}"
    echo -e "${YELLOW}   Informations détectées :${NC}"
    echo "$DEVICE_INFO"
    echo ""
    echo -e "${YELLOW}   Essayez de trouver l'UDID manuellement avec :${NC}"
    echo "   xcrun devicectl list devices"
    echo "   ou"
    echo "   xcrun instruments -s devices"
    exit 1
fi

echo -e "${GREEN}✓ iPhone trouvé: ${DEVICE_NAME:-iPhone} (${DEVICE_UDID})${NC}"

# Vérifier l'état de l'appareil
echo -e "${BLUE}🔌 Vérification de l'état de l'appareil...${NC}"
DEVICE_STATE=$(xcrun devicectl device info --device "$DEVICE_UDID" 2>/dev/null | grep -i "state" || echo "")

# Builder l'application pour iPhone
echo -e "${BLUE}🔨 Compilation de l'application pour iPhone...${NC}"
if command -v xcpretty &> /dev/null; then
    xcodebuild \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS,id=$DEVICE_UDID" \
        -configuration Debug \
        clean build \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="" \
        | xcpretty --color --simple
    BUILD_SUCCESS=$?
else
    echo -e "${YELLOW}ℹ️  xcpretty non disponible, affichage standard...${NC}"
    xcodebuild \
        -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS,id=$DEVICE_UDID" \
        -configuration Debug \
        clean build \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM=""
    BUILD_SUCCESS=$?
fi

if [ $BUILD_SUCCESS -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la compilation${NC}"
    echo -e "${YELLOW}   Vérifiez que :${NC}"
    echo -e "${YELLOW}   1. Votre compte Apple ID est configuré dans Xcode (Settings > Accounts)${NC}"
    echo -e "${YELLOW}   2. Les profils de développement sont téléchargés${NC}"
    echo -e "${YELLOW}   3. Votre iPhone est bien connecté et déverrouillé${NC}"
    exit 1
fi

# Trouver le chemin de l'app compilée
echo -e "${BLUE}🔍 Recherche de l'application compilée...${NC}"
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Erreur: Application non trouvée après le build${NC}"
    echo -e "${YELLOW}   Chemin recherché: ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug-iphoneos/Cubstart.app${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Application compilée: $APP_PATH${NC}"

# Installer l'application sur l'iPhone
echo -e "${BLUE}📦 Installation de l'application sur l'iPhone...${NC}"
if xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH" 2>&1; then
    echo -e "${GREEN}✓ Application installée${NC}"
else
    echo -e "${YELLOW}⚠️  Erreur lors de l'installation, tentative alternative...${NC}"
    # Méthode alternative avec ios-deploy si disponible
    if command -v ios-deploy &> /dev/null; then
        ios-deploy --bundle "$APP_PATH" --id "$DEVICE_UDID"
    else
        echo -e "${RED}❌ Échec de l'installation${NC}"
        echo -e "${YELLOW}   Vous pouvez essayer d'installer manuellement avec :${NC}"
        echo -e "${BLUE}   xcrun devicectl device install app --device $DEVICE_UDID \"$APP_PATH\"${NC}"
        exit 1
    fi
fi

# Lancer l'application
echo -e "${BLUE}🎬 Lancement de l'application...${NC}"
if xcrun devicectl device process launch --device "$DEVICE_UDID" "$BUNDLE_ID" 2>&1; then
    echo -e "${GREEN}✅ Application lancée avec succès sur votre iPhone!${NC}"
else
    echo -e "${YELLOW}⚠️  L'application est installée mais n'a pas pu être lancée automatiquement${NC}"
    echo -e "${YELLOW}   Vous pouvez la lancer manuellement depuis votre iPhone${NC}"
    echo -e "${BLUE}   Ou essayer : xcrun devicectl device process launch --device $DEVICE_UDID $BUNDLE_ID${NC}"
fi

echo ""
echo -e "${GREEN}✨ Terminé!${NC}"

