#!/bin/bash

# Script pour ajouter Firebase SDK via Swift Package Manager
# Usage: ./scripts/add-firebase-package.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔥 Ajout du SDK Firebase au projet...${NC}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

PROJECT_FILE="Cubstart.xcodeproj"
SCHEME="Cubstart"

# Méthode 1: Utiliser xcodebuild pour ajouter le package
# Note: Cette méthode nécessite Xcode mais peut être automatisée

echo -e "${YELLOW}⚠️  L'ajout automatique de packages Swift nécessite Xcode${NC}"
echo ""
echo -e "${BLUE}Options disponibles :${NC}"
echo ""
echo -e "${GREEN}Option 1 : Ouvrir Xcode automatiquement${NC}"
echo "   Le script va ouvrir Xcode et vous guidera pour ajouter le package"
echo ""
echo -e "${GREEN}Option 2 : Instructions manuelles${NC}"
echo "   Suivez les étapes dans GUIDE_FIREBASE.md"
echo ""
echo -e "${GREEN}Option 3 : Modifier project.pbxproj manuellement${NC}"
echo "   Plus complexe mais ne nécessite pas Xcode"
echo ""

read -p "Voulez-vous ouvrir Xcode maintenant ? (o/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    echo -e "${BLUE}Ouverture de Xcode...${NC}"
    open "$PROJECT_FILE"
    
    echo ""
    echo -e "${GREEN}✅ Xcode ouvert !${NC}"
    echo ""
    echo -e "${BLUE}📋 Étapes à suivre dans Xcode :${NC}"
    echo ""
    echo "1. Dans Xcode, allez dans : File > Add Package Dependencies..."
    echo ""
    echo "2. Collez cette URL :"
    echo -e "   ${YELLOW}https://github.com/firebase/firebase-ios-sdk${NC}"
    echo ""
    echo "3. Sélectionnez :"
    echo "   - Version : Up to Next Major Version"
    echo "   - Version : 11.0.0"
    echo ""
    echo "4. Sélectionnez les produits :"
    echo "   ✅ FirebaseCore (obligatoire)"
    echo "   ✅ FirebaseFirestore (pour la base de données)"
    echo "   ✅ FirebaseAuth (pour l'authentification)"
    echo ""
    echo "5. Cliquez sur Add Package"
    echo ""
    echo "6. Une fois terminé, compilez avec :"
    echo "   ./scripts/run-ios-simulator.sh"
else
    echo ""
    echo -e "${BLUE}📚 Consultez GUIDE_FIREBASE.md pour les instructions détaillées${NC}"
fi

