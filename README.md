# SkinSnap

Application Flutter mobile d'analyse skincare avec **Firebase Authentication**, **Cloud Firestore**, images produits locales gratuites et **Google ML Kit**.

## Version corrigee gratuite

Cette version est faite pour travailler en classe avec :

```powershell
flutter run
```

sans Firebase Storage et sans plan Blaze.

## Corrections principales

- Firebase Auth email/mot de passe.
- Cloud Firestore pour produits, categories, ingredients, assistant, routine et historique user.
- Images produits dans `assets/images/products/...` pour rester gratuit.
- Affichage automatique : `Image.asset` si `imageUrl` commence par `assets/`, sinon `Image.network`.
- Fallback demo local si Firestore est vide : tous les boutons restent testables.
- Assistant beaute fonctionnel avec reponses rapides + generation simple de conseils.
- Scan produit fonctionnel avec camera/galerie + score ingredients + produits compatibles.
- Makeup look avec 3 produits makeup demo/fallback.
- Routine : ajout de produits dans `users/{uid}/routine_products`.
- Historique : sauvegarde dans `users/{uid}/history` + fallback local.
- Notifications corrigees avec alarmes inexactes pour eviter `exact_alarms_not_permitted`.
- Categories : Bien etre, Coiffure, Skincare, Makeup.
- Application limitee au telephone Android/iOS.

## Configuration Firebase une seule fois

```powershell
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure --project=skinsnap-99d0f
flutter pub get
flutter run
```

Ensuite :

```powershell
flutter run
```

## Firebase Console

Activez seulement :

- Authentication > Email/Password
- Firestore Database

Firebase Storage n'est pas obligatoire dans cette version.

## Images incluses

```text
assets/images/products/skincare/cerave_gel_moussant.png
assets/images/products/skincare/avene_hydrance_light.png
assets/images/products/skincare/la_roche_posay_effaclar_gel.png
assets/images/products/makeup/maybelline_fit_me_foundation.png
assets/images/products/makeup/rare_beauty_blush.png
assets/images/products/makeup/nyx_butter_gloss.png
assets/images/categories/bien_etre.png
assets/images/categories/coiffure.png
assets/images/categories/skincare.png
assets/images/categories/makeup.png
```

## Collections principales

```text
products
categories
ingredients
assistant_questions
routine_steps
users/{uid}/routine_products
users/{uid}/history
```

Consultez :

```text
docs/GRATUIT_FIRESTORE_ASSETS_GUIDE.md
docs/firestore_seed_examples.json
```
