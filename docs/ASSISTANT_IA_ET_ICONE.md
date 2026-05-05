# Assistant IA et icône SkinSnap

L’assistant fonctionne en deux modes.

## Mode sans clé API

L’application répond avec un assistant local spécialisé en skincare, makeup, routine, produits et ingrédients.

Commande :

```powershell
flutter run
```

## Mode IA pour répondre à n’importe quel message

Ajoutez une clé API Gemini au lancement :

```powershell
flutter run --dart-define=GEMINI_API_KEY=VOTRE_CLE_API
```

Pour construire un APK avec l’assistant IA :

```powershell
flutter build apk --dart-define=GEMINI_API_KEY=VOTRE_CLE_API
```

Sans cette clé, l’application reste fonctionnelle mais l’assistant utilise les réponses locales.

## Icône de l’application

L’icône Android a été remplacée par l’image fournie dans :

```text
android/app/src/main/res/mipmap-*/ic_launcher.png
```

L’image est aussi disponible dans :

```text
assets/images/app/app_icon.png
```
