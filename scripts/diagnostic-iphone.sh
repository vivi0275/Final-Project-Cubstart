#!/bin/bash

# Script de diagnostic pour vérifier la connexion iPhone
# Usage: ./scripts/diagnostic-iphone.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 Diagnostic de la connexion iPhone...${NC}"
echo ""

# Vérification 1: devicectl
echo -e "${BLUE}1️⃣ Vérification avec devicectl...${NC}"
DEVICES=$(xcrun devicectl list devices 2>&1)
if echo "$DEVICES" | grep -qi "iPhone\|iPad"; then
    echo -e "${GREEN}✅ iPhone détecté avec devicectl:${NC}"
    echo "$DEVICES" | grep -i "iPhone\|iPad"
else
    echo -e "${YELLOW}⚠️  Aucun iPhone détecté avec devicectl${NC}"
    echo "$DEVICES"
fi
echo ""

# Vérification 2: instruments (ancienne méthode)
echo -e "${BLUE}2️⃣ Vérification avec instruments...${NC}"
INSTRUMENTS=$(xcrun instruments -s devices 2>&1 || true)
if echo "$INSTRUMENTS" | grep -qi "iPhone\|iPad" && ! echo "$INSTRUMENTS" | grep -qi "Simulator"; then
    echo -e "${GREEN}✅ iPhone détecté avec instruments:${NC}"
    echo "$INSTRUMENTS" | grep -i "iPhone\|iPad" | grep -v "Simulator"
else
    echo -e "${YELLOW}⚠️  Aucun iPhone physique détecté avec instruments${NC}"
fi
echo ""

# Vérification 3: USB
echo -e "${BLUE}3️⃣ Vérification USB...${NC}"
USB_DEVICES=$(system_profiler SPUSBDataType 2>/dev/null | grep -A 10 -i "iphone\|ipad" || echo "")
if [ -n "$USB_DEVICES" ]; then
    echo -e "${GREEN}✅ Appareil iOS détecté via USB:${NC}"
    echo "$USB_DEVICES"
else
    echo -e "${YELLOW}⚠️  Aucun appareil iOS détecté via USB${NC}"
fi
echo ""

# Vérification 4: libimobiledevice (si installé)
if command -v idevice_id &> /dev/null; then
    echo -e "${BLUE}4️⃣ Vérification avec libimobiledevice...${NC}"
    IDEVICE_IDS=$(idevice_id -l 2>&1 || echo "")
    if [ -n "$IDEVICE_IDS" ]; then
        echo -e "${GREEN}✅ iPhone détecté avec libimobiledevice:${NC}"
        echo "$IDEVICE_IDS"
    else
        echo -e "${YELLOW}⚠️  Aucun iPhone détecté avec libimobiledevice${NC}"
    fi
    echo ""
fi

# Résumé et recommandations
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 RÉSUMÉ ET RECOMMANDATIONS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if echo "$DEVICES" | grep -qi "iPhone\|iPad" && ! echo "$DEVICES" | grep -qi "Simulator"; then
    echo -e "${GREEN}✅ iPhone détecté !${NC}"
    echo ""
    echo "Pour trouver l'UDID exact, utilisez :"
    echo "  xcrun devicectl list devices | grep -i iPhone"
    echo ""
    echo "Ou utilisez le script :"
    echo "  ./scripts/find-device-info.sh"
else
    echo -e "${RED}❌ Aucun iPhone physique détecté${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Étapes de dépannage :${NC}"
    echo ""
    echo "1. Vérifiez que votre iPhone est connecté au Mac avec un câble USB"
    echo "2. Sur votre iPhone :"
    echo "   - Déverrouillez l'écran"
    echo "   - Si une alerte apparaît : 'Faire confiance à cet ordinateur ?'"
    echo "     → Appuyez sur 'Faire confiance'"
    echo "   - Entrez votre code PIN si demandé"
    echo ""
    echo "3. Vérifiez le câble :"
    echo "   - Essayez un autre câble USB"
    echo "   - Essayez un autre port USB sur le Mac"
    echo "   - Assurez-vous que le câble supporte la transmission de données"
    echo ""
    echo "4. Redémarrez si nécessaire :"
    echo "   - Débranchez et rebranchez l'iPhone"
    echo "   - Redémarrez votre iPhone"
    echo "   - Redémarrez votre Mac"
    echo ""
    echo "5. Vérifiez Xcode (une seule fois) :"
    echo "   - Ouvrez Xcode"
    echo "   - Allez dans Window > Devices and Simulators"
    echo "   - Vérifiez que votre iPhone apparaît dans la liste"
    echo ""
    echo "6. Vérifiez les réglages iPhone :"
    echo "   - Réglages > Général > Gestion des appareils"
    echo "   - Vérifiez qu'il n'y a pas de profil bloqué"
    echo ""
fi

echo ""
echo -e "${BLUE}💡 Astuce :${NC}"
echo "Si vous voulez tester sur simulateur en attendant, utilisez :"
echo "  ./scripts/run-ios-simulator.sh"
echo "  ou appuyez sur Cmd+Shift+R dans Cursor"

