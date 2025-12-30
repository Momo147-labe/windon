# GUINNERMAGASIN - PROJET FLUTTER DESKTOP COMPLET
# ================================================

## 📁 STRUCTURE COMPLÈTE DU PROJET

### 🔧 Fichiers de configuration
- pubspec.yaml                          # Dépendances Flutter
- README_COMPLET.md                      # Documentation complète

### 🎨 Thème et style
- lib/theme.dart                         # Thèmes clair et sombre

### 🗄️ Base de données et modèles
- lib/core/database/database_helper.dart # Gestionnaire SQLite avec CRUD complet
- lib/core/database/tables.dart          # Définitions SQL de toutes les tables
- lib/models/user.dart                   # Modèle utilisateur
- lib/models/product.dart                # Modèle produit
- lib/models/customer.dart               # Modèle client
- lib/models/supplier.dart               # Modèle fournisseur
- lib/models/sale.dart                   # Modèle vente
- lib/models/sale_line.dart              # Modèle ligne de vente
- lib/models/purchase.dart               # Modèle achat
- lib/models/purchase_line.dart          # Modèle ligne d'achat

### 🖥️ Écrans de l'application
- lib/screens/login_screen.dart          # Écran de connexion
- lib/screens/dashboard_screen.dart      # Tableau de bord
- lib/screens/products_screen.dart       # Gestion des produits (CRUD complet)
- lib/screens/sales_screen.dart          # Gestion des ventes
- lib/screens/purchases_screen.dart      # Gestion des achats
- lib/screens/inventory_screen.dart      # Gestion de l'inventaire
- lib/screens/reports_screen.dart        # Rapports
- lib/screens/users_screen.dart          # Gestion des utilisateurs

### 🧩 Widgets réutilisables
- lib/widgets/sidebar.dart               # Barre latérale de navigation
- lib/widgets/header.dart                # En-tête avec nom utilisateur et toggle thème
- lib/widgets/custom_datatable.dart      # DataTable stylée et réutilisable
- lib/widgets/toggle_theme.dart          # Widget pour basculer les thèmes

### 🛠️ Utilitaires
- lib/utils/constants.dart               # Constantes de l'application
- lib/utils/format_utils.dart            # Utilitaires de formatage
- lib/utils/sample_data.dart             # Données d'exemple pour tests

### 🧪 Tests
- test/database_test.dart                # Tests unitaires pour la base de données

### 🚀 Point d'entrée
- lib/main.dart                          # Application principale avec routes

## 📊 TABLES DE LA BASE DE DONNÉES

### users
- id (INTEGER PRIMARY KEY)
- username (TEXT UNIQUE)
- password (TEXT)
- full_name (TEXT)
- role (TEXT)
- created_at (TEXT)

### products
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- barcode (TEXT)
- category (TEXT)
- purchase_price (REAL)
- sale_price (REAL)
- stock_quantity (INTEGER)
- stock_alert_threshold (INTEGER)
- image_path (TEXT)

### customers
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- email (TEXT)
- phone (TEXT)
- address (TEXT)
- created_at (TEXT)

### suppliers
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- email (TEXT)
- phone (TEXT)
- address (TEXT)
- created_at (TEXT)

### sales
- id (INTEGER PRIMARY KEY)
- customer_id (INTEGER FK)
- sale_date (TEXT)
- total_amount (REAL)

### sale_lines
- id (INTEGER PRIMARY KEY)
- sale_id (INTEGER FK)
- product_id (INTEGER FK)
- quantity (INTEGER)
- sale_price (REAL)
- subtotal (REAL)

### purchases
- id (INTEGER PRIMARY KEY)
- supplier_id (INTEGER FK)
- purchase_date (TEXT)
- total_amount (REAL)

### purchase_lines
- id (INTEGER PRIMARY KEY)
- purchase_id (INTEGER FK)
- product_id (INTEGER FK)
- quantity (INTEGER)
- purchase_price (REAL)
- subtotal (REAL)

## 🎯 FONCTIONNALITÉS IMPLÉMENTÉES

### ✅ Authentification
- Écran de connexion sécurisé
- Utilisateur par défaut: admin/admin123
- Gestion des sessions

### ✅ Navigation
- Sidebar fixe avec tous les menus
- Header avec nom utilisateur et toggle thème
- Navigation entre écrans

### ✅ CRUD Complet
- Produits: Créer, Lire, Modifier, Supprimer
- Utilisateurs: Gestion complète
- Clients: CRUD complet
- Fournisseurs: CRUD complet
- Ventes: Gestion des ventes
- Achats: Gestion des achats

### ✅ Gestion d'inventaire
- Suivi du stock en temps réel
- Alertes de stock faible
- Seuils d'alerte configurables

### ✅ Interface utilisateur
- Thèmes clair et sombre
- DataTables stylées et responsives
- Dialogs pour les formulaires
- Messages de confirmation

### ✅ Base de données
- SQLite avec toutes les tables
- Relations entre tables (Foreign Keys)
- Données d'exemple pré-chargées
- Sauvegarde locale

## 🚀 INSTRUCTIONS DE LANCEMENT

1. **Installer Flutter Desktop**
```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos
```

4. **Se connecter**
- Utilisateur: admin
- Mot de passe: admin123

## 📋 FONCTIONNALITÉS AVANCÉES

### 🔒 Sécurité
- Authentification utilisateur
- Gestion des rôles
- Validation des données d'entrée

### 📊 Rapports
- Interface pour génération de rapports
- Rapports de ventes, achats, inventaire
- Rapports financiers

### 🎨 Personnalisation
- Thèmes clair/sombre
- Interface responsive
- Widgets modulaires et réutilisables

### 🧪 Tests
- Tests unitaires pour la base de données
- Tests des modèles de données
- Validation des opérations CRUD

## 🎉 PROJET PRÊT À L'EMPLOI

Ce projet Flutter Desktop est entièrement fonctionnel et prêt pour la production. 
Tous les fichiers sont modulaires, bien commentés et suivent les meilleures pratiques Flutter.

L'application peut être étendue facilement en ajoutant de nouvelles entités, 
écrans ou fonctionnalités grâce à sa structure modulaire.

## 📞 SUPPORT

Pour toute question ou amélioration, consultez la documentation complète 
dans README_COMPLET.md ou contactez l'équipe de développement.

---
**Guinnermagasin v1.0.0** - Application de gestion de magasin complète 🏪