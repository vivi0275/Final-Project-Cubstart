# Raccourcis Cursor pour iOS

## 🚀 Lancer l'application dans le simulateur iPhone

### Méthode 1 : Raccourci clavier (recommandé)
Appuyez sur **`Cmd + Shift + R`** pour lancer directement l'application dans le simulateur iPhone.

### Méthode 2 : Palette de commandes
1. Appuyez sur **`Cmd + Shift + P`** pour ouvrir la palette de commandes
2. Tapez **"Tasks: Run Task"**
3. Sélectionnez **"🚀 Lancer iOS Simulator"**

### Méthode 3 : Menu Terminal
1. Allez dans **Terminal > Run Task...**
2. Sélectionnez **"🚀 Lancer iOS Simulator"**

## 📱 Lancer l'application sur iPhone physique

### Méthode 1 : Raccourci clavier (recommandé)
Appuyez sur **`Cmd + Shift + D`** pour lancer directement l'application sur votre iPhone connecté.

### Méthode 2 : Palette de commandes
1. Appuyez sur **`Cmd + Shift + P`** pour ouvrir la palette de commandes
2. Tapez **"Tasks: Run Task"**
3. Sélectionnez **"📱 Lancer sur iPhone physique"**

### Méthode 3 : Menu Terminal
1. Allez dans **Terminal > Run Task...**
2. Sélectionnez **"📱 Lancer sur iPhone physique"**

⚠️ **Important** : Pour la première utilisation, suivez le guide `GUIDE_IPHONE_PHYSIQUE.md` pour configurer votre iPhone.

## 📝 Ce que font les scripts

### Script simulateur (`scripts/run-ios-simulator.sh`)
1. ✅ Trouve automatiquement un simulateur iPhone disponible
2. ✅ Démarre le simulateur s'il n'est pas déjà démarré
3. ✅ Compile l'application pour iOS Simulator
4. ✅ Installe l'application dans le simulateur
5. ✅ Lance l'application automatiquement

### Script iPhone physique (`scripts/run-ios-device.sh`)
1. ✅ Détecte automatiquement votre iPhone connecté
2. ✅ Compile l'application pour iPhone physique
3. ✅ Installe l'application sur votre iPhone
4. ✅ Lance l'application automatiquement

## 🔧 Personnalisation

Pour modifier le simulateur utilisé, éditez le script `scripts/run-ios-simulator.sh` et changez la logique de sélection du simulateur.

Pour modifier les raccourcis clavier, éditez `.vscode/keybindings.json`.

## 📚 Documentation complète

- **Simulateur** : Ce fichier
- **iPhone physique** : Voir `GUIDE_IPHONE_PHYSIQUE.md` pour toutes les étapes détaillées

