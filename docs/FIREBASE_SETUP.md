# Configuration Firebase obligatoire

Le code est pret pour Firebase Authentication, mais les cles Firebase sont propres a votre compte. Avant de lancer l'application :

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project YOUR_PROJECT_ID
flutter pub get
flutter run
```

Dans Firebase Console :

1. Ouvrir Authentication.
2. Aller dans Sign-in method.
3. Activer Email/Password.
4. Ajouter l'application Android avec le package `com.example.skinsnap`.
5. Telecharger `google-services.json` si vous configurez manuellement.
6. Verifier que `lib/firebase_options.dart` a ete regenere.

Le fichier `lib/firebase_options.dart` fourni dans le livrable contient des valeurs placeholder pour garder la structure complete. Il doit etre remplace par FlutterFire CLI.
