# TontineManager Pro - Documentation Complète

> **Version** : 0.2.1  
> **Framework** : Flutter 3.10.4+  
> **Architecture** : Clean Architecture avec GetX  

---

## Table des Matières

1. [Présentation](#présentation)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Modèles de Données](#modèles-de-données)
5. [Fonctionnalités](#fonctionnalités)
6. [Services Core](#services-core)
7. [Controllers](#controllers)
8. [Navigation](#navigation)
9. [Design System](#design-system)
10. [Règles Métier](#règles-métier)
11. [Workflow Utilisateur](#workflow-utilisateur)
12. [Améliorations Prévues](#améliorations-prévues)

---

## Présentation

### Contexte

**TontineManager Pro** 

### Public Cible

- Commerçants de détail africains pratiquant la vente à crédit
- Gestionnaires de tontines commerciales
- Boutiques de vêtements, électroménager, matériaux de construction

### Problème Résolu

Les commerçants ont besoin d'un outil simple pour :
- Suivre les dettes clients de manière granulaire
- Organiser les ventes par vagues (campagnes)
- Éviter les erreurs de calcul lors des paiements partiels
- Avoir une vue d'ensemble de leur chiffre d'affaires

---

## Architecture

### Structure du Projet

```
tontine_app_pro/
├── lib/
│   ├── core/                     # Couche métier & services transverses
│   │   ├── middleware/           # Guards de sécurité (subscription_guard.dart)
│   │   ├── services/             # Services globaux singleton
│   │   │   ├── auth_service.dart
│   │   │   ├── subscription_service.dart
│   │   │   ├── connectivity_service.dart
│   │   │   └── notification_service.dart
│   │   └── theme/
│   │       └── app_theme.dart    # Design system
│   │
│   ├── data/                     # Couche d'accès aux données
│   │   ├── models/               # Modèles de données + sérialisation
│   │   │   ├── vendor_model.dart
│   │   │   ├── customer_model.dart
│   │   │   ├── wave_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── order_model.dart
│   │   │   └── payment_transaction_model.dart
│   │   └── repositories/         # CRUD Firestore
│   │       ├── vendor_repository.dart
│   │       ├── customer_repository.dart
│   │       ├── wave_repository.dart
│   │       ├── product_repository.dart
│   │       ├── order_repository.dart
│   │       └── payment_repository.dart
│   │
│   ├── presentation/             # Couche UI (Pattern GetX)
│   │   ├── bindings/             # Injection de dépendances
│   │   │   ├── main_layout_binding.dart
│   │   │   ├── dashboard_binding.dart
│   │   │   ├── order_binding.dart
│   │   │   ├── inventory_binding.dart
│   │   │   ├── customer_binding.dart
│   │   │   └── profil_controller.dart
│   │   ├── controllers/          # State management
│   │   │   ├── auth_controller.dart
│   │   │   ├── main_layout_controller.dart
│   │   │   ├── dashboard_controller.dart
│   │   │   ├── order_controller.dart
│   │   │   ├── payment_controller.dart
│   │   │   ├── wave_controller.dart
│   │   │   ├── product_controller.dart
│   │   │   ├── customer_controller.dart
│   │   │   └── profile_controller.dart
│   │   ├── pages/                # Écrans principaux
│   │   │   ├── auth/
│   │   │   ├── dashboard_page.dart
│   │   │   ├── orders/
│   │   │   ├── products/
│   │   │   ├── customers/
│   │   │   ├── waves/
│   │   │   ├── profile_page.dart
│   │   │   └── subscription_page.dart
│   │   └── widgets/              # Composants réutilisables
│   │       ├── main_layout.dart
│   │       ├── connectivity_overlay.dart
│   │       ├── confirmation_dialog.dart
│   │       └── subscription_limit_dialog.dart
│   │
│   ├── firebase_options.dart     # Configuration Firebase
│   └── main.dart                 # Point d'entrée
│
├── test/                         # Tests unitaires et widgets
├── android/                      # Configuration Android
├── ios/                          # Configuration iOS
└── pubspec.yaml                  # Dépendances
```

### Diagramme de Flux

```
┌─────────────────────────────────────────────────────────────┐
│                         main.dart                           │
│  • Initialisation Firebase                                  │
│  • Initialisation Services (Auth, Subscription, Connectivity)│
│  • Configuration GetMaterialApp + Routes                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │ Controllers │  │     Bindings        │ │
│  │  (Widgets)  │◄─┤   (GetX)    │◄─┤  (DI Lifecycle)     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│         │                │                                  │
│         ▼                ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Widgets                              ││
│  │  • Dialogs (Confirmation, Payment, Quantity)            ││
│  │  • MainLayout (Bottom Navigation)                       ││
│  │  • ConnectivityOverlay                                  ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │ Repositories│  │   Firebase          │ │
│  │ (toMap/from)│◄─┤  (CRUD)     │─►│   (Firestore/Auth)  │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Core Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Theme     │  │  Services   │  │    Middleware       │ │
│  │ (AppTheme)  │  │ (Singleton) │  │  (SubscriptionGuard)│ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Installation

### Prérequis

- Flutter SDK >= 3.10.4
- Dart >= 3.0
- Compte Firebase avec projet configuré
- Fichiers de configuration Firebase :
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

### Étapes

```bash
# 1. Cloner le dépôt
git clone <repository-url>
cd tontine_app_pro

# 2. Installer les dépendances
flutter pub get

# 3. Ajouter les fichiers Firebase (non versionnés)
# Placer google-services.json et GoogleService-Info.plist

# 4. Lancer l'application
flutter run
```

### Configuration Firebase

**Firestore Collections :**

| Collection | Description |
|------------|-------------|
| `vendors` | Comptes commerçants |
| `customers` | Clients (sous-collection par vendor) |
| `waves` | Vagues de produits |
| `products` | Catalogue produits |
| `orders` | Commandes |
| `payment_transactions` | Historique des paiements |
| `subscription_requests` | Demandes d'upgrade premium |

**Règles de Sécurité (extrait) :**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Vendors - accès propriétaire uniquement
    match /vendors/{vendorId} {
      allow read, write: if request.auth != null && request.auth.uid == vendorId;
    }
    
    // Customers - isolés par vendor
    match /customers/{customerId} {
      allow read, write: if request.auth != null && 
        resource.data.vendorId == request.auth.uid;
    }
    
    // Orders - même logique
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        resource.data.vendorId == request.auth.uid;
    }
  }
}
```

---

## Modèles de Données

### VendorModel (Commerçant)

```dart
class VendorModel {
  final String id;              // UID Firebase Auth
  final String email;
  final String businessName;    // Nom de la boutique
  final String phone;
  final String plan;            // 'free' ou 'premium'
  final DateTime? premiumExpiryDate;
  final int waveLimit;          // 5 (free) ou 999 (premium)
  final int productLimit;       // 10 (free) ou 999 (premium)
  final DateTime createdAt;
  
  bool get isPremium;           // Calculé dynamiquement
}
```

### CustomerModel (Client)

```dart
class CustomerModel {
  final String id;
  final String vendorId;        // Isolation par vendeur
  final String name;
  final String phone;
  final String? email;
  final DateTime createdAt;
}
```

### WaveModel (Vague)

```dart
enum WaveStatus { draft, active, closed }

class WaveModel {
  final String id;
  final String name;            // Ex: "Vague Janvier 2026"
  final WaveStatus status;
  final DateTime createdAt;
}
```

### ProductModel (Produit)

```dart
class ProductModel {
  final String id;
  final String vendorId;
  final String waveId;          // Lien vers la vague
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final DateTime createdAt;
}
```

### OrderModel (Commande)

```dart
class OrderModel {
  final String id;
  final String vendorId;
  final String customerId;
  final List<OrderItemModel> items;  // Multi-articles
  final double totalAmount;
  final double totalPaid;
  final String status;               // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;
}

class OrderItemModel {
  final String id;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double paidAmount;           // Suivi individuel
  
  double get totalPrice => unitPrice * quantity;
  double get balance => totalPrice - paidAmount;
  bool get isReadyForDelivery => balance <= 0;
}
```

### PaymentTransactionModel (Transaction)

```dart
class PaymentTransactionModel {
  final String id;
  final String orderId;
  final String orderItemId;     // Lien vers l'article payé
  final double amount;
  final String method;          // 'cash', 'mobile_money', 'bank'
  final DateTime date;
}
```

---

## Fonctionnalités

### 1. Authentification

| Écran | Route | Description |
|-------|-------|-------------|
| Splash | `/splash` | Vérifie l'état de connexion, route vers login ou dashboard |
| Login | `/login` | Email + mot de passe avec Firebase Auth |
| Registration | `/register` | Création compte vendor avec businessName |

**AuthService :**
- `signIn(email, password)`
- `register(email, password, businessName)`
- `logout()`
- `Stream<VendorModel?>` - Observable du vendor connecté

---

### 2. Dashboard

**Route :** `/` (onglet 1)

**Statistiques en temps réel :**
- Revenus mensuels (somme des paiements du mois)
- Dette pendante (total des balances non payées)
- Vagues actives (count wave.status == active)
- Total commandes

**Actions rapides :**
- Nouvelle vague
- Nouvelle commande
- Nouveau client
- Voir clients

---

### 3. Gestion des Commandes

**Route :** `/` (onglet 2)

#### Création de Commande (`/orders/create`)

1. Sélection du client (liste ou nouveau)
2. Ajout d'articles depuis le catalogue
3. Saisie des quantités (dialog avec compteur)
4. Validation avec récapitulatif

#### Liste des Commandes

**Filtres par statut :**
- Tous
- En attente (pending)
- Payées (completed)
- Annulées (cancelled)

**Affichage :**
```
Client: [Nom] (#ID)
[Statut] • [Montant total] • [Date]
```

#### Détail d'une Commande (`/orders/details`)

**Sections :**
1. En-tête : Info client + statut + actions (Annuler)
2. Liste des articles avec :
   - Nom du produit
   - Prix unitaire × Quantité
   - Montant payé / Total
   - Bouton "Payer" (si solde > 0)
   - Bouton "Supprimer" (si non payé)
3. Historique des paiements (expandable)
4. Total général + Reste à payer

**Actions :**
- `recordPayment()` - Enregistre un paiement partiel
- `removeItemFromOrder()` - Supprime un article
- `cancelOrder()` - Annule toute la commande

---

### 4. Gestion des Paiements

**Controller :** `PaymentController`

#### Enregistrement d'un Paiement

```dart
Future<void> recordPayment({
  required String orderId,
  required String orderItemId,  // Article ciblé
  required double amount,
  required String method,       // cash, mobile_money, bank
})
```

**Validations :**
- ✅ Montant ≤ Reste à payer sur l'article
- ✅ Article existe dans la commande
- ✅ Commande existe

**Effets de bord :**
1. Crée la transaction dans `payment_transactions`
2. Met à jour `paidAmount` de l'article
3. Recalcule `totalPaid` de la commande
4. Passe le statut à `completed` si totalement payé

#### Suppression d'un Paiement

```dart
Future<void> deleteTransaction(
  String transactionId,
  String orderId,
  String orderItemId,
  double amount,
)
```

**Effets de bord :**
1. Supprime la transaction
2. Soustrait le montant de `paidAmount`
3. Recalcule les totaux
4. Repasse le statut à `pending` si nécessaire

---

### 5. Gestion des Vagues (Waves)

**Route :** `/` (onglet 3 - Inventaire)

#### Création d'une Vague

**Dialog :** `CreateWaveDialog`
- Nom de la vague
- Statut initial (draft/active) via chips
- Validation avec limite d'abonnement

#### Liste des Vagues

**Affichage :**
- Nom + Statut (badge couleur)
- Date de création
- Menu contextuel (Edit, Close, Delete)

**Actions :**
- `createWave()` - Vérifie limite subscription
- `updateWave()` - Modifie nom/statut
- `deleteWave()` - Confirmation requise
- `closeWave()` - Passe en statut 'closed'

---

### 6. Gestion des Produits

**Route :** `/` (onglet 3 - Inventaire)

#### Création d'un Produit

1. Sélection de la vague
2. Nom + Description + Prix
3. Quantité en stock
4. Option : Dupliquer depuis un produit existant

#### Duplication de Produit

**Dialog :** `WaveSelectionDialog`
- Sélection de la vague cible
- Copie des infos produit
- Ajustement du stock si nécessaire

---

### 7. Gestion des Clients

**Route :** `/` (onglet 4)

#### Liste des Clients

- Isolés par `vendorId`
- Recherche par nom/téléphone
- Nombre de commandes par client

#### Ajout d'un Client

```dart
class CreateCustomerPage {
  // Formulaire :
  - Nom (required)
  - Téléphone (required)
  - Email (optionnel)
}
```

---

### 8. Profil & Abonnement

**Route :** `/` (onglet 5)

#### Informations Business

- Nom de la boutique (éditable)
- Email (lecture seule)
- Téléphone (éditable)

#### Statut d'Abonnement

**Plan Gratuit :**
- 5 vagues maximum
- 10 produits maximum
- Statistiques de base

**Plan Premium :**
- Vagues illimitées
- Produits illimités
- Support prioritaire
- Statistiques avancées (à venir)

**Demande d'Upgrade :**
- Formulaire de demande
- Envoi dans `subscription_requests`
- Activation manuelle par admin

---

## Services Core

### AuthService

```dart
class AuthService extends GetxService {
  // Stream du vendor connecté
  Rx<VendorModel?> currentVendor = Rx<VendorModel?>(null);
  
  String? get currentVendorId;
  
  Future<AuthService> init();  // Écoute authChanges()
  Future<void> signIn(...);
  Future<void> register(...);
  Future<void> logout();
}
```

### SubscriptionService

```dart
class SubscriptionService extends GetxService {
  RxString currentPlan = 'free'.obs;
  RxInt waveLimit = 5.obs;
  RxInt productLimit = 10.obs;
  
  bool canCreateWave(int currentCount);
  bool canCreateProduct(int currentCount);
  Future<void> requestActivation(String plan, String duration);
}
```

### ConnectivityService

```dart
class ConnectivityService extends GetxService {
  RxBool isOnline = true.obs;
  
  Future<ConnectivityService> init();  // Stream de connectivité
}
```

### NotificationService

```dart
class NotificationService extends GetxService {
  // À implémenter :
  // - Notifications locales (paiements reçus)
  // - Rappels (dettes en retard)
}
```

---

## Controllers

### MainLayoutController

Gère la navigation entre les 5 onglets :
1. Dashboard
2. Commandes
3. Inventaire (Produits + Vagues)
4. Clients
5. Profil

**État :**
```dart
RxInt currentIndex = 0.obs;
void changeTab(int index);
```

### DashboardController

Calcule les statistiques en temps réel :

```dart
RxDouble monthlyRevenue = 0.0.obs;
RxDouble pendingDebt = 0.0.obs;
RxInt activeWavesCount = 0.obs;
RxInt totalOrdersCount = 0.obs;
List<OrderModel> recentOrders = [];

Future<void> loadStats();  // Agrège depuis repositories
```

### OrderController

```dart
RxList<OrderModel> orders = <OrderModel>[].obs;
RxBool isLoading = false.obs;

Future<void> createOrder({customerId, items});
Future<void> updateOrder(OrderModel order);
Future<void> deleteOrder(String orderId);
Future<void> cancelOrder(String orderId);
Future<void> removeItemFromOrder(String orderId, String itemId);
Future<OrderModel?> getOrder(String orderId);
```

### PaymentController

```dart
RxList<PaymentTransactionModel> transactions = <PaymentTransactionModel>[].obs;
RxBool isLoading = false.obs;

Future<void> recordPayment({orderId, orderItemId, amount, method});
Future<void> loadTransactionHistory(String orderItemId);
void watchTransactionHistory(String orderItemId);
Future<void> deleteTransaction(...);
```

### WaveController

```dart
RxList<WaveModel> waves = <WaveModel>[].obs;
RxBool isLoading = false.obs;

Future<void> createWave(String name, WaveStatus status);
Future<void> updateWave(WaveModel wave);
Future<void> deleteWave(String waveId);
Future<void> closeWave(String waveId);
```

### ProductController

```dart
RxList<ProductModel> products = <ProductModel>[].obs;
RxBool isLoading = false.obs;

Future<void> createProduct({...});
Future<void> updateProduct(ProductModel product);
Future<void> deleteProduct(String productId);
Future<void> duplicateProduct(String productId, String targetWaveId);
```

### CustomerController

```dart
RxList<CustomerModel> customers = <CustomerModel>[].obs;
RxBool isLoading = false.obs;

Future<void> createCustomer({name, phone, email});
Future<void> updateCustomer(CustomerModel customer);
Future<void> deleteCustomer(String customerId);
Future<CustomerModel?> getCustomer(String customerId);
```

---

## Navigation

### Routes Déclarées (main.dart)

| Route | Page | Binding |
|-------|------|---------|
| `/splash` | SplashPage | - |
| `/login` | LoginPage | - |
| `/register` | RegistrationPage | - |
| `/` | MainLayout | MainLayoutBinding |
| `/subscription` | SubscriptionPage | - |
| `/products/create` | CreateProductPage | InventoryBinding |
| `/products/edit` | CreateProductPage | InventoryBinding |
| `/orders/create` | CreateOrderPage | OrderBinding |
| `/customers` | CustomersPage | CustomerBinding |
| `/customers/create` | CreateCustomerPage | CustomerBinding |
| `/orders/details` | OrderDetailsPage | OrderBinding |

### Navigation GetX

```dart
// Navigation simple
Get.toNamed('/orders/create');

// Navigation avec arguments
Get.toNamed('/orders/details', arguments: order);

// Récupération d'arguments
final order = Get.arguments as OrderModel;

// Dialogs
Get.dialog(const CreateWaveDialog());
Get.back();  // Fermer dialog/page

// Snackbars (standardisées)
Get.snackbar(
  'Succès',
  'Commande créée avec succès',
  backgroundColor: AppTheme.successGreen,
  colorText: Colors.white,
);
```

---

## Design System

### Palette de Couleurs

```dart
class AppTheme {
  static const Color sageGreen = Color(0xFFB2AC88);    // Vert doux
  static const Color softBlue = Color(0xFFA8DADC);     // Bleu clair
  static const Color warmCream = Color(0xFFF1FAEE);    // Fond principal
  static const Color deepBlue = Color(0xFF457B9D);     // Primaire
  static const Color softRed = Color(0xFFE63946);      // Erreurs/Annulations
  static const Color successGreen = Color(0x9209C06B); // Succès (transparent)
  static const Color darkerBlue = Color(0xFF1D3557);   // Texte
}
```

### Composants Thémés

**Boutons :**
- Arrondis (radius: 24)
- Hauteur : 56px
- Pleine largeur par défaut

**Cartes :**
- Fond blanc
- Ombre légère
- Coins arrondis (radius: 24)

**Champs de formulaire :**
- Fond blanc
- Bordures arrondies (radius: 24)
- Focus : bordure deepBlue 2px

**Typography :**
- Titres : darkerBlue, bold
- Corps : darkerBlue, regular

---

## Règles Métier

### 1. Isolation des Données

Chaque vendor ne voit que :
- Ses clients (`vendorId` match)
- Ses produits
- Ses vagues
- Ses commandes

### 2. Limites d'Abonnement

| Action | Gratuit | Premium |
|--------|---------|---------|
| Vagues max | 5 | ∞ |
| Produits max | 10 | ∞ |
| Clients | ∞ | ∞ |
| Commandes | ∞ | ∞ |

### 3. Paiements

- ❌ Interdit de payer plus que le reste dû d'un article
- ✅ Possibilité de payer un article sans payer les autres
- ✅ Historique complet des transactions conservé

### 4. Statuts de Commande

```
pending ──[totalPaid >= totalAmount]──> completed
   │
   └──[action utilisateur]────────────> cancelled
```

### 5. Suppression d'Article

Si un article est supprimé d'une commande :
1. Recalcul de `totalAmount` et `totalPaid`
2. Si `totalPaid >= totalAmount` → statut `completed`
3. Sinon → statut reste `pending`
4. Si aucun article restant → statut `cancelled`

---

## Workflow Utilisateur

### Scénario : Vente à Tempérament

```
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 1 : Créer une vague                                   │
│ "Vague Janvier 2026"                                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 2 : Ajouter des produits                              │
│ • Chemise Homme - 15 000 FCFA - Stock: 50                   │
│ • Pantalon Jean - 25 000 FCFA - Stock: 30                   │
│ • Chaussures - 35 000 FCFA - Stock: 20                      │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 3 : Client passe commande                             │
│ Client : Jean Kouassi                                       │
│ Commande :                                                  │
│   • 2 Chemises = 30 000 FCFA                                │
│   • 1 Pantalon = 25 000 FCFA                                │
│   ──────────────────────────────                            │
│   Total : 55 000 FCFA                                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 4 : Paiements échelonnés                              │
│ Jour 1 : Jean paie 20 000 FCFA (sur les chemises)           │
│ Jour 5 : Jean paie 15 000 FCFA (sur le pantalon)            │
│ Jour 10: Jean paie 20 000 FCFA (reste chemises)             │
│ Jour 15: Jean paie 10 000 FCFA (reste pantalon)             │
│                                                             │
│ → Commande marquée "Payée" automatiquement                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 5 : Livraison                                         │
│ Tous les articles sont "Prêt pour livraison"                │
│ Le vendor peut livrer la commande                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Améliorations Prévues

### Court Terme (idée.md)

- [ ] **Lien Commandes ↔ Vagues**
  - Ajouter `waveId` dans `OrderModel`
  - Afficher le nom de la vague sur chaque commande
  - Filtrer les commandes par vague

- [ ] **Détail de Vague**
  - Page dédiée `/waves/{id}`
  - Liste des commandes liées à la vague
  - Statistiques par vague (CA, taux de paiement)

### Moyen Terme

- [ ] **Notifications Push**
  - Rappel de paiement (dettes > 7 jours)
  - Confirmation de paiement reçu
  - Notification de livraison

- [ ] **Export de Données**
  - PDF : Reçu de commande
  - Excel : Historique des ventes
  - Rapport mensuel

- [ ] **Recherche Avancée**
  - Recherche multi-critères (client, date, montant)
  - Filtres combinables

### Long Terme

- [ ] **Mode Multi-Vendeurs**
  - Comptes employés (vendeur, admin, owner)
  - Permissions granulaires

- [ ] **Intégration Mobile Money**
  - Paiement direct dans l'app
  - Webhooks Orange Money, MTN Money, Wave

- [ ] **Analytics Dashboard**
  - Graphiques d'évolution (CA, dettes)
  - Top clients
  - Produits les plus vendus

---

## Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Routing
  get: ^4.6.6
  
  # Backend
  firebase_core: ^3.10.1
  cloud_firestore: ^5.6.2
  firebase_auth: ^5.5.1
  
  # Utilities
  path_provider: ^2.1.5      # Fichiers locaux
  intl: ^0.19.0              # Internationalisation
  connectivity_plus: ^6.1.1  # Détection réseau
  cached_network_image: ^3.4.1  # Cache images
  image_picker: ^1.2.1       # Sélection photos
```

---

## Tests

**Structure :**

```
test/
├── unit/
│   ├── models_test.dart
│   └── controllers_test.dart
└── widget/
    ├── dashboard_test.dart
    └── order_details_test.dart
```

**Lancer les tests :**

```bash
# Tous les tests
flutter test

# Avec coverage
flutter test --coverage
```

---

## Déploiement

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ipa --release
```

---

## Contribution

### Workflow de Développement

1. Créer une branche feature
2. Implémenter les changements
3. Mettre à jour le CHANGELOG.md
4. Commit avec message descriptif
5. Push et Pull Request

### Conventions de Code

- **Nommage** : camelCase pour variables, PascalCase pour classes
- **Controllers** : Suffixe `Controller` (ex: `OrderController`)
- **Widgets** : Fichiers séparés dans `widgets/` si réutilisables
- **Comments** : Uniquement pour logique complexe (en anglais)

---

## Licence

© 2025 TontineManager Pro - Tous droits réservés

---

## Contact

**Développeur** : Zash Code  
**Email** : contact@zashcode.com  
**Documentation générée** : 1 avril 2026
