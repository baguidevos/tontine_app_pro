# Règles du projet

## Intégration de l'API SasPay

- Utilisez la documentation officielle : `https://docs.saspay.me/llms.txt`.
- Utilisez la spécification OpenAPI : `https://docs.saspay.me/api-reference/openapi.json`.
- Utilisez l'URL de base `https://api.saspay.me/api/v1`.
- Effectuez toutes les requêtes SasPay depuis le backend.
- Stockez la clé API dans un gestionnaire de secrets ou une variable d'environnement (`SASPAY_API_KEY`, `SASPAY_WEBHOOK_SECRET`).
- Ne placez jamais la clé API dans le frontend, les logs ou le dépôt Git.
- Envoyez la clé avec `Authorization: Bearer sk_test_...` en développement, `sk_live_...` en production.
- Montants : chaînes décimales (`"2500.00"`), jamais de flottants.
- Envoyez un `Idempotency-Key` sur `POST /payments/softpay/`, `POST /payouts/initialize/`, `POST /wallet-transfers/` et `POST /payments/{payment_id}/retry/`.
- Ne livrez un produit ou n'activez un accès/abonnement que lorsque `GET /payments/{payment_id}/verify/` ou le webhook vérifié renvoie `SUCCESS`.
- Si `checkout_url` est non vide après un softpay, redirigez le client vers cette URL.
- Vérifiez la signature des webhooks (`X-Webhook-Signature`, `X-Webhook-Timestamp`) sur le corps brut (`f"{timestamp}.{raw_body}"` via HMAC-SHA256), et rejetez un horodatage de plus de 300 secondes.
- Pour un retrait (payout), whitelistez l'IP du serveur dans le dashboard SasPay ; sinon l'appel renvoie `403 ip_not_whitelisted`.
- Gérez les réponses `401`, `403`, `404`, `409`, `422` et `429` selon l'endpoint ; en cas de `429`, espacez les appels.
- N'inventez aucun endpoint, champ, statut ou événement absent de la spécification OpenAPI.
