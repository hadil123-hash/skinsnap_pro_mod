# Rapport Livrable - SkinSnap

## 1. Présentation du projet

SkinSnap est une application mobile Flutter qui exploite plusieurs services Google ML Kit pour analyser un selfie directement sur l'appareil. L'application met l'accent sur une expérience simple, interactive et hors ligne.

## 2. Services ML Kit utilisés

### 2.1 Face Detection

- détection du visage principal,
- récupération du sourire,
- estimation de l'ouverture des yeux,
- lecture de certains indicateurs du visage.

### 2.2 Image Labeling

- extraction des éléments visuels présents dans l'image,
- tri des labels par niveau de confiance,
- affichage des principaux résultats dans l'écran de détail.

### 2.3 Selfie Segmentation

- séparation du sujet et de l'arrière-plan,
- validation qu'une segmentation est bien possible sur la photo.

### 2.4 Language Identification

- analyse d'une note utilisateur optionnelle,
- détection automatique de la langue saisie,
- affichage de la langue détectée dans le résultat.

## 3. Choix techniques

### 3.1 Framework

- Flutter pour l'interface mobile multiplateforme.

### 3.2 Gestion d'état

- `provider` pour les préférences globales : thème, langue, son, vibration, notifications.

### 3.3 Persistance locale

- `shared_preferences` pour l'historique et les réglages utilisateur.

### 3.4 Notifications

- `flutter_local_notifications` pour les rappels quotidiens.

### 3.5 Expérience utilisateur

- `flutter_animate` pour des transitions légères,
- `percent_indicator` pour le score circulaire,
- `google_fonts` pour l'identité visuelle,
- `vibration` et sons système pour le feedback.

## 4. Structure de l'application

### 4.1 Dossiers

- `lib/models` : modèles de données,
- `lib/providers` : état global,
- `lib/screens` : écrans principaux,
- `lib/services` : accès ML Kit, stockage, notifications, feedback,
- `lib/widgets` : composants réutilisables,
- `lib/utils` : thème et traductions.

### 4.2 Parcours utilisateur

1. L'utilisateur ouvre l'application.
2. Il accède à l'écran d'analyse.
3. Il prend un selfie ou choisit une image depuis la galerie.
4. Il peut ajouter une note optionnelle dans la langue de son choix.
5. L'application exécute les services ML Kit.
6. Le résultat détaillé s'affiche.
7. Le résultat peut être sauvegardé et consulté plus tard dans l'historique.

## 5. Fonctionnalités conformes au cahier des charges

- écran d'accueil,
- écran À propos,
- utilisation d'au moins 2 services ML Kit,
- affichage clair des résultats,
- historique local,
- notifications,
- mode clair / sombre,
- son,
- vibration,
- multilingue,
- paramètres.

## 6. Captures d'écran à insérer

Ajouter ici :

- capture de l'écran d'accueil,
- capture de l'écran d'analyse,
- capture de l'écran de résultat,
- capture de l'historique,
- capture de la page paramètres.

## 7. Tests et validation

- `flutter analyze` : projet sans problème d'analyse,
- `flutter test` : test automatisé passant,
- permissions Android et iOS configurées pour caméra et galerie.

## 8. Pistes d'amélioration

- améliorer la pertinence métier du score peau,
- enrichir l'historique avec filtres ou recherche,
- ajouter export ou partage du résultat,
- ajouter captures d'écran finales et vidéo de démonstration.
