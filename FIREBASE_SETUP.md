# Configuration Firebase

## Problème résolu

L'application peut maintenant fonctionner **sans Firebase** en mode local uniquement. Si vous souhaitez activer la synchronisation cloud avec Firestore, suivez les instructions ci-dessous.

## Comment ajouter Firebase à votre projet

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Suivez les étapes pour créer votre projet

### 2. Ajouter votre application iOS

1. Dans la console Firebase, cliquez sur l'icône iOS pour ajouter une application iOS
2. Entrez votre **Bundle ID** (vous pouvez le trouver dans Xcode dans les paramètres du projet)
3. Téléchargez le fichier `GoogleService-Info.plist`

### 3. Ajouter le fichier au projet Xcode

1. Ouvrez votre projet dans Xcode
2. Faites glisser le fichier `GoogleService-Info.plist` dans le dossier `Cubstart` de votre projet
3. **Important** : Cochez "Copy items if needed" et assurez-vous que le fichier est ajouté à la cible "Cubstart"
4. Vérifiez que le fichier apparaît dans le navigateur de projet

### 4. Vérifier la configuration

Une fois le fichier ajouté, l'application devrait automatiquement détecter Firebase au prochain lancement. Vous verrez dans les logs :
- `✅ [AppDelegate] Firebase configured successfully!`
- `✅ [CubstartApp] Firebase is initialized, starting Firestore synchronization...`

## Mode sans Firebase

Si vous n'ajoutez pas le fichier `GoogleService-Info.plist`, l'application fonctionnera en mode local uniquement :
- Toutes les fonctionnalités locales fonctionnent normalement
- Les données sont stockées localement avec SwiftData
- La synchronisation cloud est désactivée
- Vous verrez des messages d'avertissement dans les logs mais l'application fonctionnera

## Dépannage

### L'application affiche toujours un écran blanc

1. Vérifiez les logs dans la console Xcode
2. Assurez-vous que le fichier `GoogleService-Info.plist` est bien dans le bundle de l'application
3. Vérifiez que le Bundle ID dans Firebase correspond à celui de votre projet Xcode

### Erreur "GoogleService-Info.plist not found"

C'est normal si vous n'avez pas encore ajouté Firebase. L'application fonctionnera en mode local.


