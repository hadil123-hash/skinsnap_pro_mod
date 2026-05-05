# Cahier de charge - Application SkinSnap

## 1. Identification du projet

**Nom de l'application :** SkinSnap  
**Type :** Application mobile Flutter Android/iOS  
**Domaine :** Beauty-tech, analyse de peau, routine skincare et recommandation makeup  
**Public cible :** utilisateurs souhaitant analyser leur peau, suivre une routine de soins et obtenir des conseils beaute personnalises.

## 2. Contexte

SkinSnap repond au besoin d'une application mobile moderne capable de combiner intelligence artificielle embarquee, authentification cloud et experience utilisateur premium. L'application s'inspire des interfaces de skincare modernes : cartes arrondies, couleurs pastel, navigation mobile, scan de visage et suivi quotidien.

## 3. Objectif general

Concevoir et developper une application Flutter professionnelle permettant a l'utilisateur de creer un compte, scanner son visage, obtenir un diagnostic simplifie, recevoir une routine skincare personnalisee et suivre son evolution dans un historique.

## 4. Objectifs specifiques

- Integrer **Firebase Authentication** avec email et mot de passe.
- Exploiter au minimum deux services **Google ML Kit**.
- Proposer un design mobile moderne inspire des maquettes fournies.
- Garder l'application limitee aux telephones Android/iOS.
- Afficher des resultats clairs apres analyse.
- Sauvegarder l'historique et les preferences utilisateur.
- Ajouter les fonctionnalites complementaires demandees : mode clair/sombre, notifications, son, vibration, langues et parametres.

## 5. Perimetre fonctionnel

### 5.1 Authentification

- Ecran de bienvenue.
- Inscription via Firebase `createUserWithEmailAndPassword`.
- Connexion via Firebase `signInWithEmailAndPassword`.
- Deconnexion via Firebase `signOut`.
- Reinitialisation du mot de passe par email Firebase.

### 5.2 Onboarding

- Presentation du scan intelligent.
- Presentation de la routine skincare.
- Presentation du module makeup.
- Boutons passer, continuer et terminer.

### 5.3 Accueil / Dashboard

- Message de bienvenue personnalise.
- Carte hero skincare.
- Bouton de scan IA.
- Acces rapide a la routine, au makeup, a l'historique et aux parametres.
- Affichage de la progression quotidienne et de la serie de jours.
- Activite recente.

### 5.4 Scan de peau

- Prise de photo avec la camera.
- Import depuis la galerie.
- Note utilisateur optionnelle.
- Analyse ML Kit.
- Score peau sur 100.
- Feedback clair et recommandations.

### 5.5 Services ML Kit utilises

- Face Detection : detection du visage, sourire, yeux, orientation.
- Image Labeling : identification des elements visuels.
- Selfie Segmentation : verification de la segmentation du sujet.
- Language Identification : detection de la langue de la note utilisateur.

### 5.6 Resultats

- Score visuel.
- Diagnostic synthetique.
- Labels detectes.
- Informations sur le visage.
- Recommandations skincare.
- Sauvegarde du resultat.
- Application d'une routine generee.

### 5.7 Routine skincare

- Routine du matin.
- Routine du soir.
- Etapes cocheables.
- Produits recommandes.
- Progression quotidienne.
- Reset de la journee.
- Suivi de la serie.

### 5.8 Makeup advisor

- Choix du type d'evenement.
- Choix du style.
- Look recommande.
- Conseils teint, yeux, levres, finition.
- Palette de couleurs.

### 5.9 Historique

- Liste des analyses sauvegardees.
- Ouverture du detail d'un resultat.
- Suppression d'un resultat.
- Suppression totale de l'historique.

### 5.10 Profil et parametres

- Profil utilisateur Firebase.
- Modification du nom.
- Mode clair/sombre.
- Langues : francais, anglais, arabe.
- Activation/desactivation des notifications.
- Activation/desactivation du son.
- Activation/desactivation de la vibration.

## 6. Exigences non fonctionnelles

- Interface mobile uniquement.
- Orientation portrait forcee.
- Navigation fluide.
- Composants arrondis et lisibles.
- Respect des permissions camera, notification et vibration.
- Donnees locales conservees avec SharedPreferences.
- Authentification geree dans Firebase, pas par mot de passe local.

## 7. Architecture technique

- `lib/models` : modeles de donnees.
- `lib/providers` : etat global et preferences.
- `lib/screens` : ecrans de l'application.
- `lib/services` : Firebase Auth, ML Kit, stockage, notifications, son.
- `lib/utils` : theme et traductions.
- `lib/widgets` : composants reutilisables.

## 8. Technologies

- Flutter / Dart.
- Firebase Core.
- Firebase Authentication.
- Google ML Kit : Face Detection, Image Labeling, Selfie Segmentation, Language ID.
- Provider.
- SharedPreferences.
- Flutter Local Notifications.
- Vibration.
- Google Fonts.
- Flutter Animate.

## 9. Contraintes

- L'application ne doit etre lancee que sur telephone Android/iOS.
- La plateforme web a ete retiree du livrable.
- Un ecran de blocage est prevu si le projet est lance sur une plateforme non mobile.
- Le fichier `lib/firebase_options.dart` doit etre regenere avec `flutterfire configure` pour utiliser les vraies cles Firebase.

## 10. Criteres d'acceptation

Le projet est accepte si :

- l'application demarre sur emulateur ou telephone Android/iOS ;
- l'inscription et la connexion Firebase fonctionnent ;
- l'utilisateur connecte arrive sur le dashboard ;
- au moins deux services ML Kit sont utilises ;
- le scan affiche un resultat clair ;
- l'historique sauvegarde les analyses ;
- la routine est generable et suivable ;
- le mode clair/sombre, les langues, les notifications, le son et la vibration sont disponibles ;
- le design correspond a une application mobile moderne et professionnelle.

## 11. Livrables

- Code Flutter complet.
- Cahier de charge.
- Rapport technique.
- Instructions de configuration Firebase.
- Projet zip nettoye sans dossiers de build.
