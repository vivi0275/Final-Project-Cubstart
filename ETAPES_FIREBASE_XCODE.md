# 🔥 Étapes pour ajouter Firebase dans Xcode

## ✅ Xcode est maintenant ouvert !

Suivez ces étapes **dans l'ordre** :

---

## 📋 Étape 1 : Ajouter le package Firebase

1. **Dans la barre de menu Xcode** (en haut), cliquez sur :
   ```
   File > Add Package Dependencies...
   ```
   
   Ou utilisez le raccourci : `Cmd + Shift + K` puis `Cmd + Shift + Option + K`

2. **Une fenêtre s'ouvre** : "Add Package"

---

## 📋 Étape 2 : Entrer l'URL du package

1. **Dans le champ de recherche** en haut de la fenêtre, collez cette URL :
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```

2. **Appuyez sur Entrée** ou cliquez ailleurs

3. Xcode va chercher le package (quelques secondes)

---

## 📋 Étape 3 : Sélectionner la version

1. **Une fois le package trouvé**, vous verrez :
   - Le nom : "firebase-ios-sdk"
   - Des options de version

2. **Sélectionnez** :
   - ✅ **"Up to Next Major Version"** (recommandé)
   - Version : **11.0.0** (ou la version la plus récente affichée)

3. **Cliquez sur "Add Package"** (en bas à droite)

---

## 📋 Étape 4 : Sélectionner les produits Firebase

1. **Une nouvelle fenêtre s'ouvre** : "Choose Package Products"

2. **Cochez les produits suivants** (minimum requis) :
   - ✅ **FirebaseCore** (OBLIGATOIRE - pour la configuration de base)
   - ✅ **FirebaseFirestore** (recommandé - pour la base de données)
   - ✅ **FirebaseAuth** (recommandé - pour l'authentification)
   - ✅ **FirebaseStorage** (optionnel - pour le stockage de fichiers)

3. **Assurez-vous que le target "Cubstart" est sélectionné** dans la colonne de droite

4. **Cliquez sur "Add Package"** (en bas à droite)

---

## 📋 Étape 5 : Attendre le téléchargement

1. Xcode va automatiquement :
   - Télécharger les dépendances
   - Les résoudre
   - Les ajouter au projet

2. **Cela peut prendre 1-2 minutes** - vous verrez une barre de progression en bas de Xcode

3. **Une fois terminé**, vous verrez "Package resolved successfully" ou similaire

---

## 📋 Étape 6 : Vérifier l'installation

1. **Dans le navigateur de projet** (panneau de gauche), vous devriez voir :
   - Un nouveau dossier "Package Dependencies"
   - Firebase devrait apparaître dedans

2. **Fermez Xcode** (vous pouvez maintenant continuer dans Cursor !)

---

## 📋 Étape 7 : Décommenter le code Firebase

Maintenant que le package est installé, décommentez le code :

### Dans `Cubstart/CubstartApp.swift` :

1. Trouvez la ligne :
   ```swift
   // import FirebaseCore
   ```

2. Remplacez par :
   ```swift
   import FirebaseCore
   ```

3. Trouvez la ligne :
   ```swift
   // FirebaseApp.configure()
   ```

4. Remplacez par :
   ```swift
   FirebaseApp.configure()
   ```

### Dans `Cubstart/FirebaseManager.swift` :

1. Trouvez la ligne :
   ```swift
   // import FirebaseCore
   ```

2. Remplacez par :
   ```swift
   import FirebaseCore
   ```

3. Trouvez les lignes :
   ```swift
   // if FirebaseApp.app() == nil {
   //     FirebaseApp.configure()
   // }
   ```

4. Remplacez par :
   ```swift
   if FirebaseApp.app() == nil {
       FirebaseApp.configure()
   }
   ```

---

## 📋 Étape 8 : Tester

Compilez et lancez l'application :

```bash
./scripts/run-ios-simulator.sh
```

Si tout fonctionne, Firebase est configuré ! 🎉

---

## ⚠️ En cas de problème

### Si le package ne s'affiche pas :
- Vérifiez votre connexion internet
- Réessayez avec l'URL complète : `https://github.com/firebase/firebase-ios-sdk`

### Si l'installation échoue :
- Fermez Xcode
- Supprimez le dossier `Cubstart.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/` (s'il existe)
- Rouvrez Xcode et réessayez

### Si vous voyez des erreurs de compilation :
- Assurez-vous d'avoir décommenté toutes les lignes Firebase
- Vérifiez que FirebaseCore est bien dans "Package Dependencies"

---

## ✅ C'est terminé !

Une fois ces étapes terminées, Firebase sera complètement intégré à votre application.

Vous pouvez maintenant fermer Xcode et continuer à travailler dans Cursor normalement ! 🚀

