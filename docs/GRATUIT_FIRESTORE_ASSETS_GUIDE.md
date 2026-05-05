# SkinSnap - Version gratuite Firestore + images locales

Cette version permet de travailler en classe avec :

```powershell
flutter run
```

sans activer Firebase Storage et sans passer au plan Blaze.

## Services utilisés

- Firebase Authentication : comptes utilisateurs.
- Cloud Firestore : produits, catégories, assistant, routine, historique utilisateur.
- Images locales Flutter : dossier `assets/images/...`.

## Images produits incluses

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

## Champ imageUrl dans Firestore

Dans chaque document `products`, mettez le chemin local dans `imageUrl` :

```text
assets/images/products/skincare/cerave_gel_moussant.png
```

ou pour makeup :

```text
assets/images/products/makeup/maybelline_fit_me_foundation.png
```

L'application sait afficher automatiquement :

- `assets/...` avec `Image.asset` ;
- `https://...` avec `Image.network`.

## Fallback demo

Si Firestore est vide ou indisponible, l'application affiche des données demo locales pour que les boutons restent fonctionnels :

- Dashboard,
- Scan produit,
- Meilleur match,
- Makeup,
- Assistant beauté,
- My Routine.

Quand vous ajoutez vos documents dans Firestore, ils remplacent automatiquement les données demo.

## Collections recommandées

- `products`
- `categories`
- `ingredients`
- `assistant_questions`
- `routine_steps`
- `users/{uid}/routine_products`
- `users/{uid}/history`

