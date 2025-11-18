# 🔥 Guide d'installation Firebase

## ✅ Fichier GoogleService-Info.plist

Le fichier `GoogleService-Info.plist` a été ajouté au projet dans le dossier `Cubstart/`.

**Vérification :**
- ✅ Fichier copié : `Cubstart/GoogleService-Info.plist`
- ✅ Bundle ID correspond : `com.WellBe.Cubstart`
- ✅ Projet Firebase : `cubstart-4846d`

## 📦 Installation des dépendances Firebase

### Méthode 1 : Via Xcode (Recommandé)

1. **Ouvrez le projet dans Xcode**
   ```bash
   open Cubstart.xcodeproj
   ```

2. **Ajoutez le package Firebase**
   - Dans Xcode, allez dans **File > Add Package Dependencies...**
   - Entrez l'URL : `https://github.com/firebase/firebase-ios-sdk`
   - Sélectionnez la version (recommandé : **Up to Next Major Version** avec `11.0.0`)
   - Cliquez sur **Add Package**

3. **Sélectionnez les produits Firebase nécessaires**
   - ✅ **FirebaseCore** (obligatoire)
   - ✅ **FirebaseFirestore** (pour la base de données)
   - ✅ **FirebaseAuth** (pour l'authentification)
   - ✅ **FirebaseStorage** (pour le stockage de fichiers)
   - Cliquez sur **Add Package**

### Méthode 2 : Via Package.swift (si vous utilisez Swift Package Manager)

Ajoutez dans votre `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0")
]
```

## 🔧 Configuration dans le code

### ✅ Déjà configuré

Le fichier `CubstartApp.swift` a été modifié pour initialiser Firebase :

```swift
import FirebaseCore

@main
struct CubstartApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ...
}
```

Firebase sera automatiquement configuré au démarrage de l'application en utilisant le fichier `GoogleService-Info.plist`.

## 🧪 Vérification

Une fois les dépendances installées, vous pouvez tester Firebase :

1. **Compilez le projet**
   ```bash
   ./scripts/run-ios-simulator.sh
   ```

2. **Vérifiez les logs**
   - Si Firebase est correctement configuré, vous verrez dans les logs :
     ```
     Firebase configured successfully
     ```

## 📚 Services Firebase disponibles

Avec votre configuration actuelle, vous avez accès à :

- ✅ **Firebase Core** - Configuration de base
- ✅ **Firebase Authentication** - Authentification des utilisateurs
- ✅ **Firebase Cloud Messaging (GCM)** - Notifications push
- ✅ **Firebase Storage** - Stockage de fichiers
- ✅ **Firebase Firestore** - Base de données NoSQL (à ajouter si besoin)

## 🚀 Prochaines étapes

### Pour utiliser Firestore (base de données)

1. Ajoutez le package **FirebaseFirestore** (voir étape 3 ci-dessus)
2. Importez dans vos fichiers :
   ```swift
   import FirebaseFirestore
   ```
3. Utilisez Firestore :
   ```swift
   let db = Firestore.firestore()
   ```

### Pour utiliser Firebase Authentication

1. Le package **FirebaseAuth** est déjà disponible
2. Importez dans vos fichiers :
   ```swift
   import FirebaseAuth
   ```
3. Utilisez l'authentification :
   ```swift
   Auth.auth().signInAnonymously { result, error in
       // Gérer le résultat
   }
   ```

## ⚠️ Notes importantes

- Le fichier `GoogleService-Info.plist` contient des clés sensibles
- **Ne le commitez JAMAIS** publiquement si vous partagez votre code
- Il est déjà dans `.gitignore` pour éviter les fuites accidentelles
- Pour la production, utilisez des variables d'environnement ou des secrets

## 🔗 Ressources

- [Documentation Firebase iOS](https://firebase.google.com/docs/ios/setup)
- [Firebase iOS SDK GitHub](https://github.com/firebase/firebase-ios-sdk)
- [Console Firebase](https://console.firebase.google.com/project/cubstart-4846d)

