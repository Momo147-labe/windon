# Système de Gestion des Achats - Guinnermagasin

## Vue d'ensemble

Le système de gestion des achats permet de gérer complètement les achats de produits auprès des fournisseurs, avec support des paiements directs et à crédit.

## Fonctionnalités Principales

### 1. Page Principale des Achats (`PurchasesContent`)
- **Header professionnel** avec nom du magasin et utilisateur connecté
- **Bouton "Nouvel Achat"** pour créer un nouvel achat
- **Tableau des achats** avec colonnes :
  - Numéro d'achat
  - Fournisseur (nom complet)
  - Date d'achat
  - Total en GNF
  - Mode de paiement (Direct/Dette)
  - Actions (Détails, Supprimer)
- **Recherche et tri** par numéro, fournisseur ou montant
- **Tri par colonnes** avec indicateurs visuels

### 2. Création d'Achat (`NewPurchaseScreen`)
- **Interface à deux panneaux** :
  - **Gauche** : Liste des produits disponibles avec recherche
  - **Droite** : Panier des produits sélectionnés
- **Gestion des quantités** avec boutons +/- 
- **Calcul automatique** des sous-totaux et total
- **Informations d'achat** : nombre d'articles, total en GNF

### 3. Modes de Paiement
- **Paiement Direct** : Paiement immédiat
- **Paiement à Crédit** :
  - Sélection du fournisseur via modal avec recherche
  - Date d'échéance configurable
  - Remise optionnelle
  - Mise à jour automatique du solde fournisseur

### 4. Gestion des Fournisseurs
- **Solde automatique** : Suivi des dettes par fournisseur
- **Recherche rapide** dans la sélection de fournisseur
- **Affichage du solde** dans la liste de sélection

## Structure de la Base de Données

### Table `purchases`
```sql
CREATE TABLE purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_id INTEGER,
  user_id INTEGER,
  purchase_date TEXT DEFAULT CURRENT_TIMESTAMP,
  total_amount REAL,
  payment_type TEXT DEFAULT 'direct',
  due_date TEXT,
  discount REAL,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Table `purchase_lines`
```sql
CREATE TABLE purchase_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  purchase_price REAL NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (purchase_id) REFERENCES purchases(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### Table `suppliers` (mise à jour)
```sql
ALTER TABLE suppliers ADD COLUMN balance REAL DEFAULT 0;
```

## Modèles de Données

### Purchase
- `id`: Identifiant unique
- `supplierId`: Référence au fournisseur
- `userId`: Utilisateur qui a effectué l'achat
- `purchaseDate`: Date de l'achat
- `totalAmount`: Montant total en GNF
- `paymentType`: 'direct' ou 'debt'
- `dueDate`: Date d'échéance (si crédit)
- `discount`: Remise appliquée

### PurchaseLine
- `id`: Identifiant unique
- `purchaseId`: Référence à l'achat
- `productId`: Référence au produit
- `quantity`: Quantité achetée
- `purchasePrice`: Prix d'achat unitaire
- `subtotal`: Sous-total de la ligne

### Supplier (mis à jour)
- `balance`: Solde du fournisseur (dettes)

## Utilisation

### Créer un Nouvel Achat
1. Cliquer sur "Nouvel Achat"
2. Rechercher et sélectionner des produits
3. Ajuster les quantités dans le panier
4. Choisir le mode de paiement
5. Si crédit : sélectionner fournisseur et date d'échéance
6. Enregistrer l'achat

### Consulter les Achats
1. Utiliser la recherche pour filtrer
2. Cliquer sur les en-têtes pour trier
3. Utiliser "Détails" pour voir les informations complètes
4. Utiliser "Supprimer" pour annuler un achat

## Design et UX

### Responsive Desktop
- Interface optimisée pour les écrans Desktop
- Tableaux avec scroll horizontal si nécessaire
- Cartes et espacements professionnels

### Thème Dark/Light
- Compatible avec les deux modes
- Couleurs adaptatives selon le thème
- Contrastes optimisés pour la lisibilité

### Feedback Utilisateur
- Messages de succès/erreur avec SnackBar
- Confirmations pour les suppressions
- Indicateurs de chargement

## Intégration

Le système s'intègre parfaitement avec :
- **Sidebar** : Navigation inchangée
- **Dashboard** : Affichage des statistiques d'achats
- **Gestion des stocks** : Mise à jour automatique
- **Fournisseurs** : Gestion des soldes et dettes

## Données d'Exemple

Utilisez `SampleDataInitializer.initializeSampleData()` pour créer :
- 3 fournisseurs d'exemple
- 6 produits dans différentes catégories
- Données réalistes pour la Guinée (GNF)

## Sécurité

- Association automatique à l'utilisateur connecté
- Validation des données avant enregistrement
- Gestion des erreurs avec try/catch
- Transactions pour maintenir la cohérence des données