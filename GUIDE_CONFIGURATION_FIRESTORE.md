# 🔥 Guide de Configuration Firestore

Ce guide vous explique comment configurer Firestore dans la console Firebase pour connecter votre application iOS à la base de données cloud.

## 📋 Prérequis

- ✅ Firebase est déjà configuré dans votre projet (voir `ETAPES_FIREBASE_XCODE.md`)
- ✅ Le fichier `GoogleService-Info.plist` est présent dans votre projet
- ✅ Le package Firebase est installé dans Xcode

## 🎯 Étape 1 : Créer la base de données Firestore

### Dans la console Firebase :

1. **Ouvrez la console Firebase** : https://console.firebase.google.com
2. **Sélectionnez votre projet** : "Cubstart"
3. **Dans le menu de gauche**, cliquez sur **"Firestore Database"**
4. **Cliquez sur "Créer une base de données"** (ou "Create database")

### Configuration de la base de données :

1. **Choisissez le mode** :
   - ✅ **Mode production** (recommandé pour une vraie app)
   - ⚠️ **Mode test** (pour tester rapidement - expire après 30 jours)

2. **Sélectionnez l'emplacement** :
   - Choisissez la région la plus proche de vos utilisateurs
   - Exemple : `europe-west` pour l'Europe

3. **Cliquez sur "Activer"**

## 🎯 Étape 2 : Configurer les règles de sécurité

### Règles par défaut (Mode test) :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 18);
    }
  }
}
```

⚠️ **Ces règles expirent après 30 jours et permettent à n'importe qui de lire/écrire !**

### Règles recommandées pour la production :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection des tâches
    match /tasks/{taskId} {
      // Permettre la lecture et l'écriture à tous les utilisateurs authentifiés
      // Pour l'instant, on permet à tous (vous pouvez ajouter l'authentification plus tard)
      allow read, write: if true;
      
      // Ou avec authentification :
      // allow read, write: if request.auth != null;
    }
  }
}
```

### Comment modifier les règles :

1. Dans Firestore Database, cliquez sur l'onglet **"Règles"** (Rules)
2. Remplacez le contenu par les règles ci-dessus
3. Cliquez sur **"Publier"** (Publish)

## 🎯 Étape 3 : Structure de la base de données

Votre application créera automatiquement une collection `tasks` avec la structure suivante :

```
tasks/
  └── {taskId}/
      ├── id: string (UUID)
      ├── title: string
      ├── taskDescription: string
      ├── isCompleted: boolean
      ├── priority: string ("Urgent", "Important", "Normal")
      ├── category: string ("Soins patients", "Médications", etc.)
      ├── patientId: string? (optionnel)
      ├── dueTime: timestamp? (optionnel)
      ├── createdAt: timestamp
      └── completedAt: timestamp? (optionnel)
```

## 🎯 Étape 4 : Vérifier la connexion

### Dans votre application :

1. **Lancez l'application** dans le simulateur ou sur un appareil
2. **Ajoutez une tâche** via l'interface
3. **Retournez dans la console Firebase** → Firestore Database → Données
4. **Vous devriez voir** :
   - Une collection `tasks` apparaître
   - Des documents avec les IDs de vos tâches
   - Les données de vos tâches dans chaque document

### Test de synchronisation :

1. **Ajoutez une tâche dans l'app**
2. **Vérifiez qu'elle apparaît dans Firestore** (actualisez la page)
3. **Modifiez une tâche dans Firestore** (cliquez sur un document, modifiez un champ, sauvegardez)
4. **Retournez dans l'app** - la modification devrait apparaître automatiquement (synchronisation en temps réel)

## 🔧 Dépannage

### Problème : Les données n'apparaissent pas dans Firestore

**Solutions :**
1. Vérifiez que Firebase est bien configuré dans `CubstartApp.swift`
2. Vérifiez les logs Xcode pour voir s'il y a des erreurs
3. Vérifiez que les règles Firestore permettent l'écriture
4. Vérifiez que le package `FirebaseFirestore` est bien installé

### Problème : Erreur "Permission denied"

**Solutions :**
1. Vérifiez les règles Firestore (onglet "Règles")
2. Assurez-vous que les règles permettent la lecture/écriture
3. Si vous utilisez l'authentification, vérifiez que l'utilisateur est connecté

### Problème : La synchronisation ne fonctionne pas

**Solutions :**
1. Vérifiez votre connexion internet
2. Vérifiez que `TaskSyncService.shared.startSyncing()` est appelé dans `CubstartApp.swift`
3. Vérifiez les logs Xcode pour les erreurs

## 📱 Test sur plusieurs appareils

Pour tester la synchronisation entre appareils :

1. **Installez l'app sur deux appareils/simulateurs différents**
2. **Ajoutez une tâche sur le premier appareil**
3. **La tâche devrait apparaître automatiquement sur le second appareil** (synchronisation en temps réel)

## 🎉 C'est terminé !

Votre application est maintenant connectée à Firestore ! Toutes les tâches seront :
- ✅ Sauvegardées localement (SwiftData)
- ✅ Synchronisées avec Firestore (cloud)
- ✅ Disponibles sur tous vos appareils
- ✅ Synchronisées en temps réel

## 📚 Ressources supplémentaires

- [Documentation Firestore](https://firebase.google.com/docs/firestore)
- [Règles de sécurité Firestore](https://firebase.google.com/docs/firestore/security/get-started)
- [Guide iOS Firestore](https://firebase.google.com/docs/firestore/quickstart#ios)

