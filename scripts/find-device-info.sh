#!/bin/bash

# Script pour trouver l'UDID de l'iPhone et le chemin de l'application compilée
# Usage: ./scripts/find-device-info.sh

echo "🔍 Recherche des informations de votre iPhone..."
echo ""

# Trouver l'UDID de l'iPhone connecté
echo "📱 === UDID de votre iPhone ==="
DEVICE_INFO=$(xcrun devicectl list devices 2>/dev/null | grep -i "iPhone")

if [ -z "$DEVICE_INFO" ]; then
    echo "❌ Aucun iPhone trouvé"
    echo ""
    echo "Vérifiez que :"
    echo "  1. Votre iPhone est connecté au Mac"
    echo "  2. Vous avez fait confiance à l'ordinateur sur l'iPhone"
    echo "  3. L'iPhone est déverrouillé"
    echo ""
    echo "Appareils détectés :"
    xcrun devicectl list devices 2>/dev/null || echo "Aucun appareil détecté"
else
    echo "$DEVICE_INFO"
    echo ""
    
    # Extraire l'UDID
    UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)
    
    if [ -z "$UDID" ]; then
        # Essayer un autre format (sans tirets)
        UDID=$(echo "$DEVICE_INFO" | grep -oE '[A-F0-9]{40}' | head -1)
    fi
    
    if [ -n "$UDID" ]; then
        echo "✅ UDID trouvé : $UDID"
        echo ""
        echo "Vous pouvez utiliser cette commande :"
        echo "  xcodebuild -project Cubstart.xcodeproj -scheme Cubstart -destination \"platform=iOS,id=$UDID\" clean build"
    else
        echo "⚠️  Impossible d'extraire l'UDID automatiquement"
        echo "   Regardez la ligne ci-dessus et cherchez l'identifiant unique"
    fi
fi

echo ""
echo "📦 === Chemin de l'application compilée ==="

# Chercher l'application compilée
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d 2>/dev/null | head -1)

if [ -n "$APP_PATH" ] && [ -d "$APP_PATH" ]; then
    echo "✅ Application trouvée :"
    echo "   $APP_PATH"
    echo ""
    echo "Si vous avez besoin de l'installer manuellement :"
    if [ -n "$UDID" ]; then
        echo "   xcrun devicectl device install app --device $UDID \"$APP_PATH\""
    else
        echo "   xcrun devicectl device install app --device VOTRE_UDID \"$APP_PATH\""
    fi
else
    echo "⚠️  Aucune application compilée trouvée"
    echo ""
    echo "L'application sera créée après le build dans :"
    echo "   ~/Library/Developer/Xcode/DerivedData/Cubstart-*/Build/Products/Debug-iphoneos/Cubstart.app"
    echo ""
    echo "Pour la trouver après compilation, utilisez :"
    echo "   find ~/Library/Developer/Xcode/DerivedData -name \"Cubstart.app\" -path \"*/Debug-iphoneos/*\""
fi

echo ""
echo "✨ Terminé !"

