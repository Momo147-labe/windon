# Guinnermagasin - Application de Gestion de Magasin

Une application Flutter Desktop complète pour la gestion de magasin avec base de données SQLite.

## 🚀 Fonctionnalités

- **Authentification** : Système de connexion sécurisé
- **Gestion des Produits** : CRUD complet avec gestion du stock
- **Gestion des Ventes** : Suivi des ventes et lignes de vente
- **Gestion des Achats** : Suivi des achats et fournisseurs
- **Gestion des Clients** : Base de données clients
- **Gestion des Fournisseurs** : Base de données fournisseurs
- **Inventaire** : Suivi du stock avec alertes
- **Rapports** : Génération de rapports
- **Utilisateurs** : Gestion multi-utilisateurs
- **Thèmes** : Mode clair/sombre

## 📁 Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── theme.dart                   # Configuration des thèmes
├── core/
│   └── database/
│       ├── database_helper.dart # Gestionnaire SQLite
│       └── tables.dart          # Définitions des tables SQL
├── models/                      # Modèles de données
│   ├── user.dart
│   ├── product.dart
│   ├── customer.dart
│   ├── supplier.dart
│   ├── sale.dart
│   ├── sale_line.dart
│   ├── purchase.dart
│   └── purchase_line.dart
├── screens/                     # Écrans de l'application
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── products_screen.dart
│   ├── sales_screen.dart
│   ├── purchases_screen.dart
│   ├── inventory_screen.dart
│   ├── reports_screen.dart
│   └── users_screen.dart
└── widgets/                     # Widgets réutilisables
    ├── sidebar.dart
    ├── header.dart
    ├── custom_datatable.dart
    └── toggle_theme.dart
```

## 🛠️ Installation

### Prérequis
- Flutter SDK (≥ 3.9.2)
- Dart SDK
- Un IDE (VS Code, Android Studio, etc.)

### Étapes d'installation

1. **Cloner le projet** (ou copier les fichiers)
```bash
git clone <votre-repo>
cd guinnermagasin
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Activer le support Desktop**
```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
```

4. **Lancer l'application**
```bash
# Pour Windows
flutter run -d windows

# Pour Linux
flutter run -d linux

# Pour macOS
flutter run -d macos
```

## 📊 Base de Données

L'application utilise SQLite avec les tables suivantes :

### Tables principales
- **users** : Utilisateurs du système
- **products** : Produits du magasin
- **customers** : Clients
- **suppliers** : Fournisseurs
- **sales** : Ventes
- **sale_lines** : Lignes de vente
- **purchases** : Achats
- **purchase_lines** : Lignes d'achat

### Données par défaut
- **Utilisateur admin** : `admin` / `admin123`
- **Produits d'exemple** : Café, Pain de mie
- **Fournisseur d'exemple**
- **Client d'exemple**

## 🎯 Utilisation

### Connexion
1. Lancez l'application
2. Utilisez les identifiants par défaut : `admin` / `admin123`
3. Accédez au tableau de bord

### Navigation
- **Sidebar** : Navigation entre les différents modules
- **Header** : Informations utilisateur et toggle thème
- **Dashboard** : Vue d'ensemble avec statistiques

### Gestion des Produits
1. Allez dans "Produits"
2. Cliquez sur "Ajouter" pour créer un nouveau produit
3. Remplissez les informations (nom, code-barres, prix, stock, etc.)
4. Utilisez les boutons "Modifier" et "Supprimer" pour gérer les produits

### Gestion des Ventes
1. Allez dans "Ventes"
2. Créez une nouvelle vente
3. Ajoutez des lignes de vente avec les produits

### Inventaire
- Consultez l'état du stock
- Visualisez les alertes de stock faible
- Suivez les seuils d'alerte

## 🎨 Personnalisation

### Thèmes
L'application supporte les thèmes clair et sombre. Utilisez le bouton dans l'en-tête pour basculer.

### Couleurs
Modifiez les couleurs dans `lib/theme.dart` :
```dart
static const Color primaryColor = Color(0xFF2196F3);
static const Color secondaryColor = Color(0xFF03DAC6);
```

## 🔧 Développement

### Ajouter une nouvelle entité
1. Créez le modèle dans `lib/models/`
2. Ajoutez la table SQL dans `lib/core/database/tables.dart`
3. Implémentez les méthodes CRUD dans `database_helper.dart`
4. Créez l'écran de gestion dans `lib/screens/`
5. Ajoutez la route dans `main.dart`

### Structure des modèles
Chaque modèle doit implémenter :
- `toMap()` : Conversion vers Map pour SQLite
- `fromMap()` : Création depuis Map SQLite
- `copyWith()` : Copie avec modifications

## 📱 Plateformes Supportées

- ✅ Windows Desktop
- ✅ Linux Desktop  
- ✅ macOS Desktop
- ⚠️ Web (avec limitations SQLite)
- ⚠️ Mobile (nécessite adaptations UI)

## 🚀 Build de Production

### Windows
```bash
flutter build windows --release
```

### Linux
```bash
flutter build linux --release
```

### macOS
```bash
flutter build macos --release
```

## 📝 Fonctionnalités Avancées

### Rapports
- Rapports de ventes
- Rapports d'achats
- Rapports d'inventaire
- Rapports financiers

### Sécurité
- Authentification utilisateur
- Gestion des rôles
- Validation des données

### Performance
- Base de données optimisée
- Interface responsive
- Gestion mémoire efficace

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Contactez l'équipe de développement

---

**Guinnermagasin** - Votre solution complète de gestion de magasin 🏪