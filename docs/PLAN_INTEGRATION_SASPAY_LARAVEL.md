# Plan d'intégration Backend Laravel — SasPay (Abonnements & Encaissements)

> **Objectif :** Créer un backend Laravel dédié au sein du projet pour gérer les formules d'abonnements, les paiements SasPay (Mobile Money & Carte), la vérification d'état et le traitement sécurisé des webhooks.

---

## Vue d'ensemble de l'architecture

```
[ Application Mobile / Web ]
         │
         │ 1. Choix formule d'abonnement
         ▼
[ Backend Laravel (dossier /backend) ]
   ├── Controller : /api/subscriptions/checkout
   └── Service : SasPayService (HTTP POST /checkout-sessions/)
         │
         │ 2. Crée la session & retourne checkout_url
         ▼
    [ SasPay API ]
         │
         │ 3. Client paye (MTN, Moov, Orange, Wave, Carte)
         ▼
[ Webhook SasPay ] ──(POST /api/webhooks/saspay)──> [ SasPayWebhookController ]
                                                     ├── Valide HMAC-SHA256 + Timestamp (300s)
                                                     └── Active l'abonnement (Idempotent)
```

---

## Étapes détaillées d'implémentation

### Étape 1 : Initialisation du dossier Backend Laravel
- [ ] Créer le sous-dossier `backend/` à la racine avec `composer create-project laravel/laravel backend`.
- [ ] Configurer la base de données (SQLite pour démarrage rapide / MySQL ou PostgreSQL).
- [ ] Déclarer les variables d'environnement dans `.env` :
  ```env
  SASPAY_BASE_URL=https://api.saspay.me/api/v1
  SASPAY_API_KEY=sk_test_xxxxxxxxxxxxxxxxxxxx
  SASPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxx
  ```
- [ ] Créer le fichier de configuration `config/saspay.php`.

### Étape 2 : Modèles & Migrations de données
- [ ] **Table `plans`** :
  * `id`, `name`, `slug`, `price` (décimal/string, ex: `"5000.00"`), `currency` (`XOF`), `duration_days`, `features` (json), `is_active`.
- [ ] **Table `subscriptions`** :
  * `id`, `user_id`, `plan_id`, `status` (`pending`, `active`, `expired`, `cancelled`), `starts_at`, `expires_at`.
- [ ] **Table `payments`** :
  * `id`, `user_id`, `subscription_id`, `amount`, `currency`, `saspay_payment_id`, `checkout_url`, `status` (`PENDING`, `SUCCESS`, `FAILED`), `idempotency_key`, `raw_payload`.

### Étape 3 : Service Client SasPay (`App\Services\SasPayService`)
- [ ] Encapsuler l'API REST SasPay avec `Illuminate\Support\Facades\Http` :
  * Header `Authorization: Bearer {SASPAY_API_KEY}`
  * Header `Idempotency-Key: {uuid}` pour les opérations financières
  * Montants garantis sous format chaîne décimale (`number_format($amount, 2, '.', '')`)
- [ ] Implémenter les méthodes :
  * `createCheckoutSession(array $payload)` : appel `POST /checkout-sessions/`
  * `initiateSoftpay(array $payload)` : appel `POST /payments/softpay/`
  * `verifyPayment(string $paymentId)` : appel `GET /payments/{payment_id}/verify/`
  * `retryPayment(string $paymentId)` : appel `POST /payments/{payment_id}/retry/`
- [ ] Gestion fine des codes HTTP (401, 403, 404, 409, 422, 429).

### Étape 4 : Traitement sécurisé des Webhooks (`App\Http\Controllers\SasPayWebhookController`)
- [ ] Route `POST /api/webhooks/saspay` exclue du middleware CSRF.
- [ ] Vérification stricte des en-têtes :
  * `X-Webhook-Timestamp` : rejet si `|now - timestamp| > 300` secondes.
  * `X-Webhook-Signature` : recalcul HMAC-SHA256 sur le corps brut (`$request->getContent()`) avec `f"{timestamp}.{raw_body}"` et comparaison via `hash_equals()`.
- [ ] Dispatching des événements :
  * `transaction.success` : validation du paiement, activation ou reconduction de l'abonnement utilisateur de manière **idempotente**.
  * `transaction.failed` : mise à jour du statut en échec.
- [ ] Réponse rapide HTTP 200 pour libérer l'émetteur SasPay.

### Étape 5 : Contrôleurs & Routes API pour l'application cliente
- [ ] `GET /api/plans` : liste les plans disponibles.
- [ ] `POST /api/subscriptions/checkout` : valide le choix de l'utilisateur, crée l'enregistrement local en `PENDING`, appelle SasPay et renvoie la `checkout_url`.
- [ ] `GET /api/subscriptions/status/{paymentId}` : vérification à la demande lors du retour du client.
- [ ] `GET /api/subscriptions/current` : renvoie l'abonnement actif et la date d'expiration de l'utilisateur authentifié.

### Étape 6 : Validation et Tests
- [ ] Tests unitaires sur le calcul de signature HMAC.
- [ ] Commande artisan de test de connectivité SasPay (`php artisan saspay:test-connection`).
- [ ] Test d'un cycle complet avec la clé `sk_test_...`.
