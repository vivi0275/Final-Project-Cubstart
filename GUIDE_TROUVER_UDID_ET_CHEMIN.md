# 🔍 Guide : Trouver l'UDID et le chemin de l'application

## 📱 Méthode 1 : Script automatique (le plus simple)

Exécutez simplement :

```bash
./scripts/find-device-info.sh
```

Ce script vous donnera automatiquement :
- ✅ L'UDID de votre iPhone
- ✅ Le chemin de l'application compilée

---

## 📱 Méthode 2 : Trouver l'UDID manuellement

### Étape 1 : Lister tous les appareils connectés

```bash
xcrun devicectl list devices
```

### Étape 2 : Identifier votre iPhone dans la liste

Vous verrez quelque chose comme :

```
iPhone de Victor (00008110-00123456789ABCDE) [Connected]
```

L'UDID est la partie entre parenthèses : `00008110-00123456789ABCDE`

### Alternative : Format avec tirets

Parfois l'UDID peut être affiché avec des tirets :
```
iPhone de Victor (00008110-0012-3456-789A-BCDE) [Connected]
```

Dans ce cas, l'UDID est : `00008110-0012-3456-789A-BCDE`

### Exemple de sortie complète

```bash
$ xcrun devicectl list devices

Devices:
  iPhone de Victor (00008110-00123456789ABCDE) [Connected]
    - iOS 17.0
    - UDID: 00008110-00123456789ABCDE
```

---

## 📦 Méthode 3 : Trouver le chemin de l'application compilée

### Après avoir compilé l'application

Une fois que vous avez fait le build, l'application est créée dans un dossier spécifique.

### Commande pour trouver l'application

```bash
find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d
```

### Exemple de résultat

```
/Users/vivi0/Library/Developer/Xcode/DerivedData/Cubstart-ayexsxtwlfvgjsdaguepbghusvfu/Build/Products/Debug-iphoneos/Cubstart.app
```

### Si aucune application n'est trouvée

Cela signifie que l'application n'a pas encore été compilée pour iPhone physique. 

Pour compiler, utilisez :

```bash
xcodebuild \
  -project Cubstart.xcodeproj \
  -scheme Cubstart \
  -destination "platform=iOS,id=VOTRE_UDID" \
  clean build
```

Remplacez `VOTRE_UDID` par l'UDID que vous avez trouvé à l'étape précédente.

---

## 🎯 Exemple complet étape par étape

### 1. Trouver l'UDID

```bash
$ xcrun devicectl list devices

Devices:
  iPhone de Victor (00008110-00123456789ABCDE) [Connected]
```

**UDID trouvé :** `00008110-00123456789ABCDE`

### 2. Compiler l'application

```bash
xcodebuild \
  -project Cubstart.xcodeproj \
  -scheme Cubstart \
  -destination "platform=iOS,id=00008110-00123456789ABCDE" \
  clean build
```

### 3. Trouver le chemin de l'application

```bash
$ find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d

/Users/vivi0/Library/Developer/Xcode/DerivedData/Cubstart-ayexsxtwlfvgjsdaguepbghusvfu/Build/Products/Debug-iphoneos/Cubstart.app
```

**Chemin trouvé :** `/Users/vivi0/Library/Developer/Xcode/DerivedData/Cubstart-ayexsxtwlfvgjsdaguepbghusvfu/Build/Products/Debug-iphoneos/Cubstart.app`

### 4. Installer sur l'iPhone

```bash
xcrun devicectl device install app \
  --device 00008110-00123456789ABCDE \
  "/Users/vivi0/Library/Developer/Xcode/DerivedData/Cubstart-ayexsxtwlfvgjsdaguepbghusvfu/Build/Products/Debug-iphoneos/Cubstart.app"
```

### 5. Lancer l'application

```bash
xcrun devicectl device process launch \
  --device 00008110-00123456789ABCDE \
  com.WellBe.Cubstart
```

---

## 🛠️ Commandes rapides de référence

### Trouver l'UDID
```bash
xcrun devicectl list devices | grep -i iPhone
```

### Trouver le chemin de l'app (après compilation)
```bash
find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d
```

### Tout en une commande (avec variables)
```bash
# Trouver l'UDID
UDID=$(xcrun devicectl list devices | grep -i iPhone | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)

# Trouver l'app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d | head -1)

# Afficher les résultats
echo "UDID: $UDID"
echo "App: $APP_PATH"
```

---

## ⚠️ Dépannage

### "No devices found"

**Problème :** Aucun iPhone détecté

**Solutions :**
1. Vérifiez que l'iPhone est bien connecté au Mac
2. Vérifiez que vous avez fait confiance à l'ordinateur sur l'iPhone
3. Vérifiez que l'iPhone est déverrouillé
4. Essayez de débrancher et rebrancher le câble USB
5. Essayez un autre port USB

### "No such file or directory" pour l'application

**Problème :** L'application n'a pas encore été compilée

**Solution :** Compilez d'abord l'application avec `xcodebuild` (voir étape 2 ci-dessus)

### UDID avec un format différent

**Problème :** L'UDID peut avoir différents formats

**Solutions :**
- Format avec tirets : `00008110-0012-3456-789A-BCDE`
- Format sans tirets : `0000811000123456789ABCDE`
- Les deux formats fonctionnent avec `xcrun devicectl`

---

## ✅ Résumé rapide

1. **UDID** : `xcrun devicectl list devices` → cherchez l'identifiant entre parenthèses
2. **Chemin App** : `find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*"`

Ou utilisez simplement : `./scripts/find-device-info.sh` 🚀

