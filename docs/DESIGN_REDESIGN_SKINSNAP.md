# Redesign SkinSnap - version beauty app

Cette version applique un design inspiré des références envoyées : rose/magenta/orange, cartes arrondies, mockups téléphone, dashboard orienté scan visage, scan produit, routine et match produit.

## Pages redesignées

- Splash screen
- Onboarding en 5 écrans
- Accueil / Dashboard
- Scan visage ML Kit
- Résultat d'analyse + routine personnalisée
- Routine skincare matin/soir
- Scan produit / sécurité des ingrédients
- Détail produit / match parfait
- Assistant beauté
- Makeup advisor
- Login / Register / Forgot password
- Profil / Paramètres / Historique / À propos

## Corrections techniques incluses

- `flutter_local_notifications` : remplacement de `exactAllowWhileIdle` par `inexactAllowWhileIdle` pour éviter `exact_alarms_not_permitted`.
- `android/app/build.gradle.kts` : activation de `coreLibraryDesugaring` et ajout de `desugar_jdk_libs`.
- Design unifié dans `lib/widgets/beauty_ui.dart`.

## Firebase

Si vous remplacez tout le projet par ce zip, relancez :

```powershell
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure --project=skinsnap-99d0f
flutter clean
flutter pub get
flutter run
```

Ou copiez vos fichiers déjà générés :

- `lib/firebase_options.dart`
- `android/app/google-services.json`
