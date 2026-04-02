# 🎨 Paya - Logo & Icône Guide

**Version :** 1.0  
**Date :** 2026-04-02  
**Statut :** Prêt pour production

---

## 📋 Spécifications techniques

### **Format requis**

| Plateforme | Taille | Format | Notes |
|------------|--------|--------|-------|
| **Android** | 1024x1024 | PNG | Fond transparent ou coloré |
| **iOS** | 1024x1024 | PNG | Coins arrondis auto |
| **Google Play** | 512x512 | PNG | Pour la fiche du store |
| **App Store** | 1024x1024 | PNG | Sans transparence |

### **Couleurs officielles Paya**

```
Primaire : #1a237e (Deep Blue - payaBlue)
Secondaire : #534ba6 (Light Blue - payaLightBlue)
Fond : #faf7f0 (Warm Cream - payaCream)
Blanc : #ffffff (payaWhite)
```

---

## 🎨 Concepts de logo

### **Concept 1 : Lettre P stylisée** ⭐ **RECOMMANDÉ**

```
┌─────────────┐
│             │
│   ┌─────┐   │
│   │  P  │   │  ← P blanc, gras, moderne
│   └─────┘   │
│             │  ← Fond bleu deep (#1a237e)
└─────────────┘

Description :
- Lettre "P" majuscule, police géométrique
- Épaisseur uniforme
- Coins légèrement arrondis
- Minimaliste et moderne
```

**Spécifications :**
- Police : Poppins Bold ou Montserrat Bold
- Lettre P : Blanche (#ffffff)
- Fond : Bleu deep (#1a237e)
- Marge : 20% du bord

---

### **Concept 2 : Icône abstraite**

```
┌─────────────┐
│             │
│    ╱╲       │
│   ╱  ╲      │  ← Forme de vague/pièce
│  ╱    ╲     │
│   ╲  ╱      │
│    ╲╱       │
│             │  ← Fond bleu deep
└─────────────┘

Description :
- Forme circulaire stylisée
- Évoque une pièce de monnaie
- Ou une vague (référence aux vagues de produits)
- Moderne et abstrait
```

---

### **Concept 3 : Sac d'argent minimaliste**

```
┌─────────────┐
│             │
│    ┌─┐      │
│   ╱   ╲     │  ← Sac d'argent stylisé
│  │  $  │    │
│   ╲   ╱     │
│    └─┘      │
│             │  ← Fond bleu deep
└─────────────┘

Description :
- Sac d'argent simplifié
- Symbole dollar ou franc au centre
- Évoque l'argent, l'épargne
- Clair et reconnaissable
```

---

### **Concept 4 : Mains jointes (solidarité)**

```
┌─────────────┐
│             │
│    \_/      │  ← Mains jointes stylisées
│   (___)     │
│             │
│             │  ← Fond bleu deep
└─────────────┘

Description :
- Deux mains qui se joignent
- Symbolise l'entraide, la tontine
- Communauté, solidarité
- Chaleureux et humain
```

---

## 🛠️ Comment créer ton logo

### **Option 1 : DIY avec Canva** (Gratuit) ⭐ **RECOMMANDÉ**

**Étapes :**

1. **Ouvrir Canva**
   - Va sur canva.com
   - Crée un design personnalisé : 1024x1024 px

2. **Créer le fond**
   - Rectangle plein
   - Couleur : #1a237e (Deep Blue)

3. **Ajouter la lettre P**
   - Texte → Ajouter "P"
   - Police : Poppins Bold ou Montserrat Bold
   - Couleur : Blanc (#ffffff)
   - Taille : ~60% du canvas
   - Centrer horizontalement et verticalement

4. **Exporter**
   - Télécharger → PNG
   - Fond transparent : NON (garder le fond bleu)
   - Taille : 1024x1024

**Template Canva prêt à l'emploi :**
- Recherche : "App Icon" ou "Logo Android"
- Choisir un template minimaliste
- Personnaliser avec couleurs Paya

---

### **Option 2 : Fiverr** ($50-200)

**Comment procéder :**

1. Va sur fiverr.com
2. Recherche : "App icon design" ou "Logo design"
3. Choisis un designer avec :
   - ⭐ 4.8+ étoiles
   - 100+ avis
   - Portfolio avec icônes d'apps

4. Commande avec ce brief :
```
Titre : Logo pour application mobile - Paya

Description :
Je cherche un logo minimaliste et moderne pour une application 
de gestion de tontine appelée "Paya".

Spécifications :
- Format : 1024x1024 px
- Style : Minimaliste, moderne, professionnel
- Couleurs : Bleu deep (#1a237e) et Blanc (#ffffff)
- Éléments : Lettre "P" stylisée ou icône abstraite
- Usage : App mobile (Android + iOS)

Inspirations :
- Revolut (simple, lettre)
- N26 (minimaliste)
- Wave (moderne, africain)

Livraison attendue :
- Fichier source (AI, PSD, Figma)
- PNG 1024x1024
- PNG 512x512
- Variantes sur fond clair/sombre
```

---

### **Option 3 : 99designs** ($299+)

**Processus :**
1. Crée un concours sur 99designs.com
2. Décris ton brief (comme ci-dessus)
3. Les designers proposent des concepts
4. Tu choisis le gagnant
5. Reçois tous les fichiers sources

**Avantage :** Plusieurs concepts, choix plus large

---

## 📱 Générer les icônes avec Flutter Launcher Icons

### **Étape 1 : Ajouter le package**

Dans `pubspec.yaml` (dev_dependencies) :

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### **Étape 2 : Configuration**

À la fin de `pubspec.yaml` :

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/paya_icon.png"
  adaptive_icon_background: "#1a237e"
  adaptive_icon_foreground: "assets/icon/paya_icon_foreground.png"
  min_sdk_android: 21
```

### **Étape 3 : Placer ton icône**

```bash
# Créer le dossier
mkdir -p assets/icon

# Copier ton icône 1024x1024
# Nomme-le : paya_icon.png
```

### **Étape 4 : Générer**

```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## ✅ Checklist de validation

### **Avant de valider le logo**

```
☐ Taille : 1024x1024 pixels minimum
☐ Format : PNG
☐ Couleurs : #1a237e (bleu) + #ffffff (blanc)
☐ Lisible en petite taille (test 48x48 px)
☐ Pas de texte (juste icône/lettre)
☐ Fond uni ou transparent
☐ Test sur fond clair et sombre
☐ Pas de détails trop fins
```

### **Test de lisibilité**

```
1. Réduire à 48x48 px (taille icône Android)
2. Vérifier que c'est encore lisible
3. Tester sur fond blanc
4. Tester sur fond noir
5. Tester en noir et blanc
```

---

## 🎨 Exemple de design final

### **Icône principale (1024x1024)**

```
┌──────────────────────────────┐
│                              │
│                              │
│                              │
│         ┌─────────┐          │
│         │         │          │
│         │    P    │          │  ← P blanc, gras
│         │         │          │
│         └─────────┘          │
│                              │
│                              │
│    Fond: #1a237e (Deep Blue) │
│                              │
└──────────────────────────────┘
```

### **Dans l'app (Splash Screen)**

```
┌──────────────────────────────┐
│                              │
│    #faf7f0 (Warm Cream)      │
│                              │
│         [Logo Paya]          │
│                              │
│         PAYA                 │  ← Texte optionnel
│                              │
│   La tontine simplifiée      │  ← Tagline optionnelle
│                              │
└──────────────────────────────┘
```

---

## 📦 Fichiers à fournir au designer

Si tu fais appel à un designer, fournis-lui :

```
1. Nom : Paya
2. Tagline : "La tontine simplifiée"
3. Couleurs :
   - Primaire : #1a237e (Deep Blue)
   - Secondaire : #534ba6 (Light Blue)
   - Fond : #faf7f0 (Warm Cream)
4. Style : Minimaliste, moderne, professionnel
5. Éléments : Lettre P ou icône abstraite
6. Formats requis :
   - 1024x1024 PNG (principal)
   - 512x512 PNG (Google Play)
   - Fichiers sources (AI, PSD, Figma)
7. Usage : App mobile Android + iOS
8. Inspirations : Revolut, N26, Wave
```

---

## 🚀 Prêt à lancer ?

### **Checklist finale**

```
☐ Logo créé (1024x1024 PNG)
☐ Couleurs respectées (#1a237e + #ffffff)
☐ Test de lisibilité OK (48x48 px)
☐ Fichiers sources sauvegardés
☐ Placé dans assets/icon/paya_icon.png
☐ flutter_launcher_icons configuré
☐ Commande générée : flutter pub run flutter_launcher_icons
☐ Test sur émulateur OK
☐ Prêt pour Google Play
```

---

## 💡 Tips pro

1. **Garde-le simple** : Moins c'est plus pour les icônes d'app
2. **Évite le texte** : Illisible en petite taille
3. **Teste en noir et blanc** : Doit être reconnaissable sans couleur
4. **Pense à l'international** : Pas de symboles culturellement spécifiques
5. **Versionne** : Garde les anciennes versions au cas où

---

**Prochaine étape : Créer ton logo et le placer dans `assets/icon/paya_icon.png` !** 🎨

*Document créé le 2026-04-02*  
*Version 1.0*
