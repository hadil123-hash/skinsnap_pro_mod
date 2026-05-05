# SkinSnap - Données temps réel Firestore

Cette version n'utilise plus les produits/catégories statiques du code pour l'accueil, les catégories, le makeup et les recommandations.

## Collections nécessaires

### categories
Champs recommandés :
- title: string
- iconName: string (`health`, `hair`, `spa`, `makeup`)
- colorHex: string
- imageUrl: string (`assets/...` ou `https://...`)
- rank: number
- isActive: boolean

### products
Champs recommandés :
- name: string
- brand: string
- category: string
- subtitle: string
- description: string
- type: string (`skincare` ou `makeup`)
- usage: string
- routineStep: string
- matchScore: number
- rating: number
- reviewCount: number
- imageUrl: string (`assets/...` ou URL publique)
- colorHex: string
- iconName: string
- skinTypes: array (`grasse`, `mixte`, `seche`, `sensible`, `normale`)
- concerns: array
- texture: string
- rank: number
- isActive: boolean

### routine_steps
Champs recommandés :
- title: string
- description: string
- productName: string
- moment: string (`morning` ou `evening`)
- rank: number
- isActive: boolean

### users/{uid}/favorites
Créé automatiquement quand l'utilisateur ajoute un favori.

### users/{uid}/routine_products
Créé automatiquement quand l'utilisateur ajoute un produit à sa routine.

## Important
Si Firestore est vide, l'application affiche un message demandant d'ajouter les documents. C'est normal : les données ne viennent plus du code statique.
