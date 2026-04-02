# 📦 Versioning & Releases - Tontine App Pro

**Dernière mise à jour :** 2026-04-02  
**Version actuelle :** v0.4.0+7

---

## 🎯 Version actuelle

### **v0.4.0+7** - 2026-04-02

**Statut :** ✅ Production Ready  
**Type :** MINOR (nouvelles fonctionnalités, compatible backward)

### **Fonctionnalités principales**

| Feature | Statut | Description |
|---------|--------|-------------|
| Wave-Products Linking | ✅ Complet | Liaison many-to-many vagues-produits |
| Product Selection Sheet | ✅ Complet | BottomSheet de sélection multi-produits |
| Wave Details Products | ✅ Complet | Section produits dans WaveDetailsPage |
| Product Creation Simplified | ✅ Complet | Formulaire simplifié (sans vague/stock) |
| Loading Spinners | ✅ Complet | Spinners de rafraîchissement UX |

### **Corrections critiques**

- ✅ Toutes les vagues affichaient les mêmes produits
- ✅ Produits ne se chargeaient pas dans Wave Details
- ✅ BottomSheet ne se fermait pas après validation
- ✅ Sélection produits en temps réel

---

## 📜 Historique des versions

### **v0.4.x - Wave Products Management**

| Version | Build | Date | Type | Description |
|---------|-------|------|------|-------------|
| v0.4.0 | +7 | 2026-04-02 | MINOR | Wave-Products linking + Product creation simplification |
| v0.4.0 | +6 | 2026-04-01 | MINOR | Wave-Products many-to-many relationship |
| v0.4.0 | +5 | 2026-04-01 | MINOR | ProductSelectionSheet implementation |
| v0.4.0 | +4 | 2026-04-01 | MINOR | WaveDetailsPage products section |

### **v0.3.x - Wave Orders Linking**

| Version | Build | Date | Type | Description |
|---------|-------|------|------|-------------|
| v0.3.0 | +3 | 2026-04-01 | MINOR | Wave-Orders linking implementation |
| v0.3.0 | +2 | 2026-04-01 | MINOR | OrderController waveId support |
| v0.3.0 | +1 | 2026-04-01 | MINOR | OrderModel waveId field added |

### **v0.2.x - Order Management & Dialogs**

| Version | Build | Date | Type | Description |
|---------|-------|------|------|-------------|
| v0.2.1 | +5 | 2025-12-28 | PATCH | Enhanced dialogs system |
| v0.2.0 | +4 | 2025-12-27 | MINOR | Order cancellation & item removal |

### **v0.1.x - MVP & Foundation**

| Version | Build | Date | Type | Description |
|---------|-------|------|------|-------------|
| v0.1.2 | +3 | 2025-12-23 | MINOR | GetX Bindings implementation |
| v0.1.1 | +2 | 2025-12-22 | PATCH | Fix INSTALL_FAILED_UPDATE_INCOMPATIBLE |
| v0.1.0 | +1 | 2025-12-22 | MAJOR | Initial MVP release |

---

## 📊 Roadmap des versions futures

### **v0.5.0 - WhatsApp Integration** (Prochain)

**Date prévue :** 2026-04-15  
**Statut :** 📋 En planification

| Feature | Priorité | Statut |
|---------|----------|--------|
| Message Templates | 🔴 Haute | ⏳ À faire |
| WhatsApp Export | 🔴 Haute | ⏳ À faire |
| Order Summary Generation | 🟡 Moyenne | ⏳ À faire |
| Custom Message Editor | 🟢 Basse | ⏳ À faire |

### **v0.6.0 - Analytics & Reports**

**Date prévue :** 2026-05-01  
**Statut :** 📋 En planification

| Feature | Priorité | Statut |
|---------|----------|--------|
| Dashboard Analytics | 🔴 Haute | ⏳ À faire |
| PDF Export | 🟡 Moyenne | ⏳ À faire |
| Charts & Graphs | 🟡 Moyenne | ⏳ À faire |
| Monthly Reports | 🟢 Basse | ⏳ À faire |

### **v0.7.0 - Notifications**

**Date prévue :** 2026-05-15  
**Statut :** 📋 En planification

| Feature | Priorité | Statut |
|---------|----------|--------|
| Push Notifications | 🔴 Haute | ⏳ À faire |
| Payment Reminders | 🟡 Moyenne | ⏳ À faire |
| Wave Updates | 🟢 Basse | ⏳ À faire |

### **v1.0.0 - Production Release**

**Date prévue :** 2026-06-01  
**Statut :** 📋 En planification

**Critères de validation :**
- [ ] Toutes les features v0.4.x-v0.7.x implémentées
- [ ] Tests unitaires > 80% coverage
- [ ] Tests E2E sur scénarios critiques
- [ ] Performance : < 3s load time
- [ ] Crash-free rate > 99.5%
- [ ] Documentation complète
- [ ] Google Play Store ready

---

## 🔄 Processus de release

### **Checklist pré-release**

```bash
# 1. Tests & Validation
☐ Tests manuels toutes features
☐ Aucun crash/bug bloquant
☐ Flutter analyze sans erreurs
☐ Performance checks OK

# 2. Documentation
☐ CHANGELOG.md mis à jour
☐ VERSIONING.md mis à jour
☐ README.md à jour
☐ workflow.md à jour

# 3. Versioning
☐ pubspec.yaml version incrémentée
☐ Git tag créé
☐ Git commit avec message conventionnel
☐ Push avec tags
```

### **Commandes de release**

```bash
# 1. Mettre à jour pubspec.yaml
version: 0.4.0+7

# 2. Commit des changements
git add .
git commit -m "chore: release v0.4.0+7

- Wave-Products linking implementation
- Product creation simplification
- Bug fixes and UX improvements"

# 3. Créer le tag
git tag -a v0.4.0+7 -m "Release v0.4.0+7 - Wave Products Management"

# 4. Push avec tags
git push origin main --tags

# 5. Build release
flutter clean
flutter pub get
flutter build appbundle --release --build-name=0.4.0 --build-number=7
```

---

## 📱 Distribution

### **Google Play Store**

| Channel | Version | Statut | Date |
|---------|---------|--------|------|
| Internal Test | v0.4.0+7 | ⏳ En attente | - |
| Closed Beta | v0.4.0+7 | ⏳ En attente | - |
| Open Beta | v0.4.0+7 | ⏳ En attente | - |
| Production | v0.4.0+7 | ⏳ En attente | - |

### **Builds disponibles**

| Version | Type | Location | Taille |
|---------|------|----------|--------|
| v0.4.0+7 | AAB | `build/app/outputs/bundle/release/` | ~ MB |
| v0.4.0+7 | APK | `build/app/outputs/flutter-apk/` | ~ MB |

---

## 🐛 Known Issues

### **Issues en cours**

| ID | Issue | Sévérité | Statut | Version fix |
|----|-------|----------|--------|-------------|
| #001 | - | 🟡 Moyenne | 🔍 Investigation | v0.4.1 |
| #002 | - | 🟢 Basse | 📋 Backlog | v0.5.0 |

### **Issues résolues (v0.4.0)**

| ID | Issue | Sévérité | Fixé dans |
|----|-------|----------|-----------|
| #040 | All waves showing same products | 🔴 Critique | v0.4.0+6 |
| #041 | Products not loading in WaveDetails | 🔴 Critique | v0.4.0+6 |
| #042 | BottomSheet not closing | 🟡 Moyenne | v0.4.0+5 |
| #043 | Selection state not real-time | 🟡 Moyenne | v0.4.0+5 |

---

## 📈 Métriques de version

### **Adoption des versions**

```
v0.4.0+7  ████████████████████  100% (current)
v0.3.x    ░░░░░░░░░░░░░░░░░░░░    0%
v0.2.x    ░░░░░░░░░░░░░░░░░░░░    0%
v0.1.x    ░░░░░░░░░░░░░░░░░░░░    0%
```

### **Temps entre versions**

| From | To | Days |
|------|-----|------|
| v0.1.0 | v0.2.0 | 5 days |
| v0.2.0 | v0.3.0 | 95 days |
| v0.3.0 | v0.4.0 | 1 day |

**Moyenne :** 33.7 jours entre versions mineures

---

## 🔗 Liens utiles

- [CHANGELOG.md](CHANGELOG.md) - Journal des changements détaillé
- [workflow.md](workflow.md) - Workflow de développement et déploiement
- [README.md](README.md) - Documentation du projet
- [Git Tags](../../tags) - Liste des tags Git
- [Google Play Console](https://play.google.com/console) - Console de déploiement

---

## 📞 Contact & Support

**Développeur :** hbddevos  
**Email :** davidhida108@gmail.com  
**Repository :** github.com/hbddevos/tontine_app_pro

---

**Document maintenu à jour à chaque release.**  
*Dernière modification : 2026-04-02*
