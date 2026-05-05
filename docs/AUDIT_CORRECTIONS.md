# Audit et corrections - SkinSnap

## Diagnostic

Le projet initial respectait une grande partie du mini-projet ML Kit : il contenait plusieurs services ML Kit, un historique, des preferences, un mode sombre, des sons, vibrations et notifications. Les points non conformes principaux etaient :

- authentification locale avec SharedPreferences au lieu de Firebase Authentication ;
- dependances Firebase manquantes ;
- initialisation Firebase absente dans `main.dart` ;
- configuration Android Firebase incomplete ;
- application encore disponible en mode web ;
- design correct mais pas assez proche des references skincare modernes ;
- petite erreur de code dans `routine_screen.dart` avec un `borderRadius` duplique.

## Corrections realisees

- Ajout de `firebase_core` et `firebase_auth`.
- Ajout de `lib/services/auth_service.dart`.
- Ajout de `lib/firebase_options.dart` a regenerer via FlutterFire CLI.
- Remplacement de l'authentification locale par Firebase Auth.
- Inscription avec `createUserWithEmailAndPassword`.
- Connexion avec `signInWithEmailAndPassword`.
- Deconnexion Firebase.
- Mot de passe oublie par email Firebase.
- Ajout du plugin Gradle Google Services.
- `minSdk` Android passe a 23.
- Ajout de la permission Internet.
- Suppression du dossier `web` du livrable.
- Blocage des plateformes non mobiles dans `main.dart`.
- Refonte visuelle du theme, du dashboard, de la navigation et des formulaires auth.
- Correction du `borderRadius` duplique.
- Mise a jour du cahier de charge.
