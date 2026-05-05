# SkinSnap - Produits avec images gratuites

Cette version n'utilise pas Firebase Storage pour rester gratuite.
Les images des produits sont dans le projet Flutter :

```text
assets/images/products/skincare/
assets/images/products/makeup/
```

Dans Firestore, le champ `imageUrl` doit contenir un chemin local :

```text
assets/images/products/skincare/cerave_gel_moussant.png
```

L'application affiche automatiquement les chemins `assets/...` avec `Image.asset`.
Si vous mettez une URL `https://...`, elle sera affichée avec `Image.network`.

Guide principal :

```text
docs/GRATUIT_FIRESTORE_ASSETS_GUIDE.md
```
