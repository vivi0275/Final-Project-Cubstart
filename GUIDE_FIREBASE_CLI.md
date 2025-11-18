# 🔥 Ajouter Firebase sans ouvrir Xcode manuellement

## Option 1 : Script automatique (ouvre Xcode)

Exécutez simplement :

```bash
./scripts/add-firebase-package.sh
```

Le script va :
- Ouvrir Xcode automatiquement
- Vous donner les instructions étape par étape

## Option 2 : Instructions manuelles dans Xcode

Si vous préférez ouvrir Xcode vous-même :

### Étape 1 : Ouvrir le projet

```bash
open Cubstart.xcodeproj
```

### Étape 2 : Ajouter le package

1. Dans Xcode : **File > Add Package Dependencies...**
2. Collez l'URL : `https://github.com/firebase/firebase-ios-sdk`
3. Version : **Up to Next Major Version** avec `11.0.0`
4. Sélectionnez les produits :
   - ✅ **FirebaseCore** (obligatoire)
   - ✅ **FirebaseFirestore** (base de données)
   - ✅ **FirebaseAuth** (authentification)
   - ✅ **FirebaseStorage** (stockage fichiers)
5. Cliquez sur **Add Package**

### Étape 3 : Vérifier

Compilez le projet :

```bash
./scripts/run-ios-simulator.sh
```

## Option 3 : Modifier project.pbxproj directement (avancé)

⚠️ **Attention** : Cette méthode est complexe et peut casser le projet si mal faite.

Si vous voulez vraiment éviter Xcode, vous pouvez modifier `project.pbxproj` directement, mais c'est très risqué car le format est complexe et Xcode le régénère parfois.

### Alternative recommandée : Utiliser Xcode une seule fois

Même si vous préférez travailler en ligne de commande, vous pouvez :
1. Ouvrir Xcode **une seule fois** pour ajouter le package
2. Fermer Xcode
3. Continuer à travailler en ligne de commande

Les dépendances seront sauvegardées dans le projet et vous pourrez continuer à utiliser vos scripts.

## Option 4 : Utiliser xcodebuild (si disponible)

Si vous avez accès à `xcodebuild` avec support des packages :

```bash
# Cette commande peut fonctionner selon votre version de Xcode
xcodebuild -resolvePackageDependencies \
  -project Cubstart.xcodeproj \
  -scheme Cubstart
```

Mais vous devrez quand même ajouter la référence au package dans le projet d'abord.

## ✅ Recommandation

**La méthode la plus simple** : Utilisez le script qui ouvre Xcode automatiquement :

```bash
./scripts/add-firebase-package.sh
```

Cela prend 2 minutes et vous n'aurez besoin de le faire qu'une seule fois. Après ça, vous pourrez continuer à travailler en ligne de commande normalement.

## 🔍 Vérification après ajout

Une fois le package ajouté, vous pouvez vérifier avec :

```bash
# Vérifier que le package est référencé
grep -r "firebase-ios-sdk" Cubstart.xcodeproj/

# Compiler pour vérifier que tout fonctionne
./scripts/run-ios-simulator.sh
```

