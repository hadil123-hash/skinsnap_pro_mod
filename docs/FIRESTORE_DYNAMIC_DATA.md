# SkinSnap - Donnees dynamiques Firestore

Cette version ne code plus les donnees des pages principales en dur dans Flutter.
Les pages lisent les donnees depuis Cloud Firestore.

## 1. Activer Firestore

Firebase Console > Build > Firestore Database > Create database.

Pour les tests en classe, vous pouvez commencer en mode test. Pour une vraie app, securisez les regles.

## 2. Collections utilisees

### categories
Champs :
- title: string
- icon: string (`spa`, `makeup`, `hair`, `health`, `sun`, `cleanser`, `serum`)
- colorHex: string, exemple `#E5007E`
- rank: number

### products
Champs :
- name: string
- subtitle: string
- description: string
- matchScore: number
- rating: number
- reviewCount: number
- imageUrl: string optionnel
- colorHex: string
- icon: string
- skinTypes: array<string>
- concerns: array<string>
- texture: string
- rank: number

### ingredients
Champs :
- name: string
- note: string
- penaltyLevel: number (`0` pas de penalite, `1` faible, `2` moyenne, `3` forte)
- rank: number

### assistant_questions
Champs :
- question: string
- rank: number

### routine_steps
Champs :
- title: string
- description: string
- productName: string
- moment: string (`morning` ou `evening`)
- rank: number

### assistant_messages
Cette collection est alimentee automatiquement quand l'utilisateur envoie une question.

## 3. Exemple de donnees a ajouter dans Firebase Console

### categories
- title: Skincare | icon: spa | colorHex: #32BDF2 | rank: 1
- title: Makeup | icon: makeup | colorHex: #FF8A00 | rank: 2
- title: Coiffure | icon: hair | colorHex: #E5007E | rank: 3
- title: Bien etre | icon: health | colorHex: #00B870 | rank: 4

### products
- name: CeraVe Gel Moussant Nettoyant
- subtitle: 473 ml
- description: Nettoyant doux pour retirer l exces de sebum sans agresser la barriere cutanee.
- matchScore: 95
- rating: 5
- reviewCount: 158
- imageUrl: laisser vide ou mettre une URL image
- colorHex: #007D3F
- icon: cleanser
- skinTypes: ["Mixte", "Grasse"]
- concerns: ["Exces de sebum", "Acne"]
- texture: Gel doux
- rank: 1

### ingredients
- name: LACTIC ACID | note: Hydratant et exfoliant doux | penaltyLevel: 0 | rank: 1
- name: LIMONENE | note: Parfum, peut irriter les peaux sensibles | penaltyLevel: 1 | rank: 2
- name: PHENOXYETHANOL | note: Conservateur autorise mais a surveiller | penaltyLevel: 2 | rank: 3
- name: 2-BROMO-2-NITROPROPANE-1 | note: Ingredient a eviter | penaltyLevel: 3 | rank: 4

### assistant_questions
- question: Quelle routine pour une peau grasse ? | rank: 1
- question: Comment appliquer SPF et hydratant ? | rank: 2
- question: Quels ingredients eviter pour peau sensible ? | rank: 3

### routine_steps
- title: Etape 1 - Nettoyant | description: Nettoyer sans agresser la barriere cutanee. | productName: CeraVe Gel Moussant 473 ml | moment: morning | rank: 1
- title: Etape 2 - Hydratant | description: Hydrater la peau avant la protection solaire. | productName: Avene Hydrance creme legere 40 ml | moment: morning | rank: 2
- title: Etape 3 - Ecran Solaire | description: Proteger contre les UV tous les matins. | productName: Kuora Ecran solaire SPF50+ 200 ml | moment: morning | rank: 3
- title: Etape 1 - Demaquillage | description: Retirer SPF, maquillage et pollution. | productName: Huile demaquillante douce | moment: evening | rank: 1
- title: Etape 2 - Serum | description: Apaiser et reparer la peau pendant la nuit. | productName: Serum Niacinamide 5% | moment: evening | rank: 2
- title: Etape 3 - Creme | description: Sceller l hydratation. | productName: Creme barriere ceramides | moment: evening | rank: 3

## 4. Pourquoi certaines valeurs restent dans le code ?

Les couleurs du theme, les titres des boutons et les libelles d interface restent dans Flutter, car ce sont des elements UI.
Les donnees metier affichables comme produits, ingredients, categories, questions rapides et etapes de routine sont dans Firestore.
