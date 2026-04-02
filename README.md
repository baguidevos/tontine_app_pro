# 💰 Paya

**Paya - La tontine simplifiée**

Paya est une plateforme B2B2C conçue pour les commerçants de détail utilisant des systèmes de paiement échelonnés (ventes à tempérament, tontines). L'application permet de suivre précisément les paiements des clients, article par article, de gérer les stocks et de superviser les vagues de livraison.

## 🚀 Fonctionnalités Clés

- **Gestion des Commandes Multi-articles** : Suivi granulaire des paiements pour chaque article d'une commande.
- **Paiements Flexibles** : Enregistrement des transactions avec historique complet et sécurité anti-surpaiement.
- **Gestion des Clients** : Annuaire client isolé par vendeur pour une gestion personnalisée.
- **Tableau de Bord en Temps Réel** : Statistiques sur le chiffre d'affaires, la dette totale, les commandes en cours et les vagues actives.
- **Gestion des Produits et Vagues** : Organisation des ventes par "vagues" (batches) et catalogue produits personnalisable.
- **Mode Hors-ligne** : Détection automatique de la connectivité avec alertes utilisateurs.
- **Système de Souscription** : Contrôle d'accès basé sur des plans (Gratuit vs Premium) avec limites dynamiques.

## 🛠️ Stack Technique

- **Framework** : [Flutter](https://flutter.dev)
- **State Management & Routing** : [GetX](https://pub.dev/packages/get)
- **Backend** : [Firebase](https://firebase.google.com) (Auth, Firestore)
- **Architecture** : Clean Architecture simplifiée pour une meilleure maintenabilité.

## 📱 Design & UX

- **Esthétique Moderne** : Palette de couleurs pastel, coins arrondis et design minimaliste.
- **Feedback Utilisateur** : Système standardisé de snackbars pour confirmer les actions et signaler les erreurs.
- **Navigation Fluide** : Layout principal avec onglets réactifs et gestion automatique du cycle de vie des contrôleurs.

## 🏁 Installation

1. Clonez le dépôt.
2. Assurez-vous d'avoir Flutter installé (`flutter doctor`).
3. Installez les dépendances : `flutter pub get`.
4. Configurez votre projet Firebase et ajoutez les fichiers `google-services.json` (Android) et `GoogleService-Info.plist` (iOS).
5. Lancez l'application : `flutter run`.
