# 🔍 Guide de Diagnostic Firestore

Ce guide vous aide à identifier pourquoi les données ne s'affichent pas dans Firestore.

## 📋 Étapes de diagnostic

### 1. Vérifier les logs dans Xcode

Les logs détaillés ont été ajoutés au code. Suivez ces étapes :

1. **Ouvrez Xcode**
2. **Lancez l'application** dans le simulateur (⌘R)
3. **Ouvrez la console** : View → Debug Area → Activate Console (ou ⌘⇧Y)
4. **Créez une nouvelle tâche** dans l'app
5. **Regardez les messages dans la console**

#### Messages attendus (si tout fonctionne) :

```
🔥 [AppDelegate] Configuration de Firebase...
✅ [AppDelegate] Firebase configuré avec succès!
🚀 [CubstartApp] Application démarrée, initialisation de la synchronisation Firestore...
✅ [CubstartApp] Firebase est initialisé
🔄 [CubstartApp] Démarrage de l'écoute Firestore...
🔄 [CubstartApp] Synchronisation initiale des tâches...
✅ [AddTaskView] Tâche sauvegardée localement: [Titre de votre tâche]
🔄 [AddTaskView] Démarrage de la synchronisation avec Firestore...
🔄 [TaskSyncService] Début de la synchronisation de la tâche: [Titre]
🔥 [FirestoreService] Tentative de sauvegarde de la tâche: [UUID]
🔥 [FirestoreService] Titre: [Titre]
🔥 [FirestoreService] Dictionnaire créé: [...]
🔥 [FirestoreService] Collection: tasks
🔥 [FirestoreService] Document ID: [UUID]
✅ [FirestoreService] Tâche sauvegardée avec succès dans Firestore!
✅ [TaskSyncService] Synchronisation réussie pour: [Titre]
```

### 2. Problèmes courants et solutions

#### ❌ Problème : "Firebase n'est pas initialisé"

**Message d'erreur :**
```
❌ [AppDelegate] Erreur: Firebase n'a pas pu être configuré!
❌ [CubstartApp] Firebase n'est pas initialisé!
```

**Solutions :**
1. Vérifiez que le fichier `GoogleService-Info.plist` est présent dans le projet
2. Vérifiez que le fichier est ajouté au target "Cubstart"
3. Vérifiez que le Bundle ID correspond dans Xcode et Firebase

#### ❌ Problème : "Permission denied" ou erreur de règles

**Message d'erreur :**
```
❌ [FirestoreService] Erreur lors de la sauvegarde: Permission denied
Code d'erreur: 7
```

**Solutions :**
1. Allez dans Firebase Console → Firestore → Règles
2. Assurez-vous d'avoir ces règles :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

3. Cliquez sur **"Publier"**

#### ❌ Problème : Package FirebaseFirestore non installé

**Message d'erreur :**
```
No such module 'FirebaseFirestore'
```

**Solutions :**
1. Dans Xcode, allez dans **File > Add Package Dependencies...**
2. URL : `https://github.com/firebase/firebase-ios-sdk`
3. Sélectionnez **FirebaseFirestore** dans les produits
4. Cliquez sur **Add Package**

#### ❌ Problème : Collection "Tasks" au lieu de "tasks"

**Symptôme :** Les données ne s'affichent pas mais pas d'erreur dans les logs

**Solution :**
1. Supprimez la collection "Tasks" (avec majuscule) dans Firebase si elle existe
2. Le code utilise "tasks" (minuscule) - la collection sera créée automatiquement

### 3. Vérifier les règles de sécurité Firestore

1. **Ouvrez Firebase Console** : https://console.firebase.google.com
2. **Sélectionnez votre projet** : "Cubstart"
3. **Allez dans Firestore Database → Règles**
4. **Vérifiez que vous avez** :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Important** : Ces règles permettent à TOUS d'accéder aux données. Pour la production, ajoutez l'authentification.

### 4. Test manuel dans Firebase Console

Pour vérifier que Firestore fonctionne :

1. **Dans Firebase Console → Firestore → Données**
2. **Cliquez sur "+ Commencer une collection"**
3. **Collection ID** : `tasks`
4. **Document ID** : Laissez vide (auto-généré)
5. **Ajoutez un champ** :
   - Champ : `test`
   - Type : `string`
   - Valeur : `hello`
6. **Sauvegardez**

Si cela fonctionne, Firestore est bien configuré. Le problème vient du code de l'app.

### 5. Vérifier la connexion internet

Assurez-vous que :
- Le simulateur/appareil a accès à Internet
- Aucun firewall ne bloque Firebase
- Vous n'êtes pas en mode avion

### 6. Nettoyer et reconstruire

Parfois, un nettoyage du projet résout les problèmes :

1. Dans Xcode : **Product → Clean Build Folder** (⇧⌘K)
2. Fermez Xcode
3. Supprimez le dossier `DerivedData` :
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Cubstart-*
   ```
4. Rouvrez Xcode et reconstruisez

## 📊 Checklist de vérification

Cochez chaque point :

- [ ] Le fichier `GoogleService-Info.plist` est présent dans le projet
- [ ] Le package `FirebaseFirestore` est installé dans Xcode
- [ ] Les règles Firestore permettent l'écriture (`allow read, write: if true`)
- [ ] La base de données Firestore est créée dans Firebase Console
- [ ] Les logs Xcode montrent "Firebase configuré avec succès"
- [ ] Les logs Xcode montrent "Tâche sauvegardée avec succès dans Firestore"
- [ ] La collection `tasks` (minuscule) est utilisée dans le code
- [ ] L'appareil/simulateur a accès à Internet

## 🆘 Si rien ne fonctionne

Si après avoir suivi toutes ces étapes, les données ne s'affichent toujours pas :

1. **Copiez tous les messages de la console Xcode** (surtout ceux avec ❌)
2. **Vérifiez les règles Firestore** et faites une capture d'écran
3. **Vérifiez que FirebaseFirestore est bien installé** dans Package Dependencies

Les logs détaillés vous indiqueront exactement où le problème se situe !

