# 🔥 Activer Firebase après installation du package

## ✅ État actuel

Le code Firebase est prêt mais **commenté temporairement** pour permettre la compilation sans le package Firebase installé.

## 📋 Étapes pour activer Firebase

### 1. Ajouter le package Firebase dans Xcode

```bash
open Cubstart.xcodeproj
```

Puis dans Xcode :
- **File > Add Package Dependencies...**
- URL : `https://github.com/firebase/firebase-ios-sdk`
- Version : **Up to Next Major Version** avec `11.0.0`
- Sélectionnez : **FirebaseCore** (minimum requis)
- Cliquez sur **Add Package**

### 2. Décommenter le code Firebase

Une fois le package ajouté, décommenter les lignes suivantes :

#### Dans `Cubstart/CubstartApp.swift` :

```swift
// Remplacer ces lignes :
// import FirebaseCore

// Par :
import FirebaseCore
```

Et dans la méthode `application` :

```swift
// Remplacer :
// FirebaseApp.configure()

// Par :
FirebaseApp.configure()
```

#### Dans `Cubstart/FirebaseManager.swift` :

```swift
// Remplacer :
// import FirebaseCore

// Par :
import FirebaseCore
```

Et dans la méthode `configure()` :

```swift
// Remplacer :
// if FirebaseApp.app() == nil {
//     FirebaseApp.configure()
// }

// Par :
if FirebaseApp.app() == nil {
    FirebaseApp.configure()
}
```

### 3. Vérifier que tout fonctionne

```bash
./scripts/run-ios-simulator.sh
```

Si Firebase est correctement configuré, vous verrez dans les logs :
```
Firebase configured successfully
```

## 🎯 Résumé

- ✅ Code Firebase prêt et commenté
- ✅ Fichier `GoogleService-Info.plist` en place
- ⏳ En attente : Ajout du package Firebase via Xcode
- ⏳ En attente : Décommenter le code Firebase

Une fois ces deux étapes terminées, Firebase sera complètement fonctionnel !

