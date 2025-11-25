# Voice Recognition Setup

## Configuration des permissions dans Xcode

Le projet utilise la génération automatique du fichier Info.plist (`GENERATE_INFOPLIST_FILE = YES`). Pour ajouter les permissions de reconnaissance vocale et microphone, vous devez ajouter les clés dans les Build Settings :

### Étapes détaillées :

1. **Ouvrez le projet dans Xcode**

2. **Sélectionnez le projet "Cubstart"** dans le Project Navigator (l'icône bleue en haut)

3. **Sélectionnez le target "Cubstart"** dans la liste des targets

4. **Allez dans l'onglet "Info"** (pas "Build Settings")

5. **Dans la section "Custom iOS Target Properties"**, cliquez sur le bouton **"+"** en bas à gauche pour ajouter deux nouvelles clés :

   **Clé 1:**
   - Cliquez sur "+" → Sélectionnez "Privacy - Speech Recognition Usage Description" dans le menu déroulant
   - OU tapez manuellement : `NSSpeechRecognitionUsageDescription`
   - Type: String
   - Value: `This app needs access to speech recognition to create tasks by voice.`

   **Clé 2:**
   - Cliquez sur "+" → Sélectionnez "Privacy - Microphone Usage Description" dans le menu déroulant
   - OU tapez manuellement : `NSMicrophoneUsageDescription`
   - Type: String
   - Value: `This app needs access to your microphone to record voice commands for creating tasks.`

### Alternative : Via Build Settings

Si vous ne trouvez pas l'onglet "Info", vous pouvez aussi :

1. Allez dans l'onglet **"Build Settings"**
2. Dans la barre de recherche en haut, tapez : `INFOPLIST_KEY`
3. Vous verrez des options comme `INFOPLIST_KEY_UIApplicationSceneManifest_Generation`
4. Cliquez sur le bouton **"+"** à côté de ces clés
5. Ajoutez :
   - `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` = `This app needs access to speech recognition to create tasks by voice.`
   - `INFOPLIST_KEY_NSMicrophoneUsageDescription` = `This app needs access to your microphone to record voice commands for creating tasks.`

## Utilisation

1. Ouvrez l'application
2. Allez dans l'onglet "Tasks"
3. Appuyez sur le bouton "+" en haut à droite
4. Sélectionnez "Voice Task"
5. Appuyez sur "Start Recording"
6. Dictez votre tâche (exemple : "Give medication to patient P-001 in room 12 at 3 PM, urgent priority")
7. Appuyez sur "Stop"
8. Vérifiez l'aperçu de la tâche
9. Appuyez sur "Create Task" pour créer la tâche

## Exemples de phrases vocales

- "Administer medication to patient P-001 in 30 minutes, urgent"
- "Document patient care for room 5, important priority"
- "Team meeting at 2 PM today"
- "Check rounds for patient in room 10"
- "Give pills to patient in room 3 at 4 PM"

Le système analysera automatiquement le texte pour extraire :
- La catégorie (medication, documentation, rounds, etc.)
- La priorité (urgent, important, normal)
- L'ID du patient (si mentionné)
- L'heure d'échéance (si mentionnée)

