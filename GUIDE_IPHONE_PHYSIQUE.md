# 📱 Guide complet : Lancer l'application sur iPhone physique sans Xcode

## 📋 Prérequis

### 1. Compte développeur Apple (gratuit)
- Vous avez besoin d'un **Apple ID** (gratuit)
- Pas besoin d'un compte développeur payant pour tester sur votre propre iPhone

### 2. Matériel requis
- ✅ Mac avec Xcode installé (même si vous ne l'utilisez pas)
- ✅ iPhone avec câble USB ou connexion WiFi
- ✅ iOS 26.0 ou supérieur (selon votre configuration)

---

## 🔧 Configuration initiale (une seule fois)

### Étape 1 : Connecter votre iPhone

1. **Connectez votre iPhone au Mac** avec un câble USB
2. Sur votre iPhone, si une alerte apparaît : **"Faire confiance à cet ordinateur ?"** → Appuyez sur **"Faire confiance"**
3. Entrez votre code PIN si demandé

### Étape 2 : Vérifier la connexion

Ouvrez un terminal et exécutez :

```bash
xcrun devicectl list devices
```

Vous devriez voir votre iPhone dans la liste. Notez son **UDID** (identifiant unique).

### Étape 3 : Configurer le compte développeur dans Xcode (une seule fois)

⚠️ **Cette étape nécessite d'ouvrir Xcode une seule fois pour la configuration initiale**

1. Ouvrez Xcode (une seule fois)
2. Allez dans **Xcode > Settings (ou Preferences) > Accounts**
3. Cliquez sur le **"+"** en bas à gauche
4. Ajoutez votre **Apple ID**
5. Sélectionnez votre compte et cliquez sur **"Download Manual Profiles"**
6. Fermez Xcode (vous n'en aurez plus besoin après)

### Étape 4 : Faire confiance au développeur sur l'iPhone

1. Sur votre iPhone, allez dans **Réglages > Général > Gestion des appareils (ou VPN et gestion de l'appareil)**
2. Trouvez votre profil de développeur (votre nom ou email)
3. Appuyez dessus et appuyez sur **"Faire confiance"**
4. Confirmez en appuyant sur **"Faire confiance"** à nouveau

---

## 🚀 Lancer l'application sur iPhone (méthode automatique)

### Option 1 : Script automatique (recommandé)

Utilisez le script `scripts/run-ios-device.sh` :

```bash
./scripts/run-ios-device.sh
```

Le script va :
1. ✅ Détecter automatiquement votre iPhone connecté
2. ✅ Builder l'application pour iPhone
3. ✅ Installer l'application sur votre iPhone
4. ✅ Lancer l'application automatiquement

### Option 2 : Raccourci Cursor

Appuyez sur **`Cmd + Shift + D`** dans Cursor (ou utilisez la tâche "🚀 Lancer sur iPhone")

---

## 🔨 Méthode manuelle (étape par étape)

### Étape 1 : Trouver l'UDID de votre iPhone

```bash
xcrun devicectl list devices
```

Notez l'UDID de votre iPhone (format : `00008110-XXXXXXXX`)

### Étape 2 : Builder l'application pour iPhone

```bash
cd /Users/vivi0/Cubstarttt/Final-Project-Cubstart

xcodebuild \
  -project Cubstart.xcodeproj \
  -scheme Cubstart \
  -destination "platform=iOS,id=VOTRE_UDID_ICI" \
  -configuration Debug \
  clean build
```

Remplacez `VOTRE_UDID_ICI` par l'UDID de votre iPhone.

### Étape 3 : Trouver le fichier .app compilé

```bash
find ~/Library/Developer/Xcode/DerivedData -name "Cubstart.app" -path "*/Debug-iphoneos/*" -type d
```

### Étape 4 : Installer sur l'iPhone

```bash
xcrun devicectl device install app \
  --device VOTRE_UDID_ICI \
  CHEMIN_VERS_Cubstart.app
```

### Étape 5 : Lancer l'application

```bash
xcrun devicectl device process launch \
  --device VOTRE_UDID_ICI \
  com.WellBe.Cubstart
```

---

## 🛠️ Dépannage

### Problème : "No devices found"

**Solution :**
1. Vérifiez que votre iPhone est bien connecté
2. Vérifiez que vous avez fait confiance à l'ordinateur sur l'iPhone
3. Essayez de débrancher et rebrancher le câble
4. Vérifiez avec : `xcrun devicectl list devices`

### Problème : "Code signing failed"

**Solution :**
1. Ouvrez Xcode une fois et allez dans **Settings > Accounts**
2. Sélectionnez votre compte et cliquez sur **"Download Manual Profiles"**
3. Assurez-vous que votre iPhone apparaît dans **Window > Devices and Simulators**

### Problème : "Untrusted Developer"

**Solution :**
1. Sur votre iPhone : **Réglages > Général > Gestion des appareils**
2. Trouvez votre profil de développeur
3. Appuyez dessus et **"Faire confiance"**

### Problème : "Device not found"

**Solution :**
1. Vérifiez que l'iPhone est déverrouillé
2. Vérifiez que le câble USB fonctionne
3. Essayez un autre port USB
4. Redémarrez votre iPhone si nécessaire

---

## 📝 Commandes utiles

### Lister tous les appareils connectés
```bash
xcrun devicectl list devices
```

### Voir les informations détaillées d'un appareil
```bash
xcrun devicectl device info --device VOTRE_UDID
```

### Voir les applications installées sur l'iPhone
```bash
xcrun devicectl device list apps --device VOTRE_UDID
```

### Désinstaller l'application
```bash
xcrun devicectl device uninstall app \
  --device VOTRE_UDID \
  com.WellBe.Cubstart
```

### Voir les logs de l'application en temps réel
```bash
xcrun devicectl device process launch \
  --device VOTRE_UDID \
  --start-stopped \
  com.WellBe.Cubstart

# Puis dans un autre terminal :
xcrun devicectl device process log \
  --device VOTRE_UDID \
  --process com.WellBe.Cubstart
```

---

## ✅ Checklist rapide

- [ ] iPhone connecté au Mac
- [ ] Confiance accordée à l'ordinateur sur l'iPhone
- [ ] Compte Apple ID ajouté dans Xcode (Settings > Accounts)
- [ ] Profils téléchargés dans Xcode
- [ ] Confiance accordée au développeur sur l'iPhone (Réglages > Général > Gestion des appareils)
- [ ] Script `run-ios-device.sh` exécuté ou commandes manuelles suivies

---

## 🎯 Résumé

Une fois la configuration initiale terminée, vous pouvez lancer votre application sur iPhone en une seule commande :

```bash
./scripts/run-ios-device.sh
```

Ou utilisez le raccourci **`Cmd + Shift + D`** dans Cursor !

