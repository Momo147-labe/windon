import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/store_info.dart';
import '../models/user.dart';
import '../services/license_service.dart';
import '../core/database/database_helper.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // License form
  final _licenseController = TextEditingController();
  bool _isValidatingLicense = false;
  String? _licenseError;
  
  // Store form
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isCreatingStore = false;
  String? _storeError;

  @override
  void dispose() {
    _pageController.dispose();
    _licenseController.dispose();
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _validateLicense() async {
    final license = _licenseController.text.trim();
    
    if (license.isEmpty) {
      setState(() => _licenseError = 'Veuillez saisir une licence');
      return;
    }

    setState(() {
      _isValidatingLicense = true;
      _licenseError = null;
    });

    try {
      final result = await LicenseService.activateLicense(license);
      
      if (!result.canContinue) {
        setState(() {
          _licenseError = result.message;
          _isValidatingLicense = false;
        });
        return;
      }

      // Sauvegarder la licence validée
      final settings = AppSettings(
        license: license,
        firstLaunchDone: false,
      );
      await DatabaseHelper.instance.updateAppSettings(settings);
      
      setState(() => _isValidatingLicense = false);
      _nextPage();
    } catch (e) {
      setState(() {
        _licenseError = 'Erreur lors de l\'activation: $e';
        _isValidatingLicense = false;
      });
    }
  }

  Future<void> _createStoreAndAdmin() async {
    // Validation
    if (_storeNameController.text.trim().isEmpty ||
        _ownerNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _adminUsernameController.text.trim().isEmpty ||
        _adminPasswordController.text.trim().isEmpty) {
      setState(() => _storeError = 'Tous les champs sont obligatoires');
      return;
    }

    if (_adminPasswordController.text != _confirmPasswordController.text) {
      setState(() => _storeError = 'Les mots de passe ne correspondent pas');
      return;
    }

    if (_adminPasswordController.text.length < 6) {
      setState(() => _storeError = 'Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() {
      _isCreatingStore = true;
      _storeError = null;
    });

    try {
      // Créer les informations du magasin
      final storeInfo = StoreInfo(
        name: _storeNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        location: _locationController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertStoreInfo(storeInfo);

      // Créer le compte administrateur avec mot de passe hashé
      final hashedPassword = sha256.convert(utf8.encode(_adminPasswordController.text)).toString();
      final adminUser = User(
        username: _adminUsernameController.text.trim(),
        password: hashedPassword,
        fullName: 'Administrateur',
        role: 'admin',
        createdAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.insertUser(adminUser);

      // Marquer le premier lancement comme terminé
      final settings = AppSettings(
        license: _licenseController.text.trim(),
        firstLaunchDone: true,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.updateAppSettings(settings);

      // Rediriger vers la page de login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _storeError = 'Erreur lors de la création: $e';
        _isCreatingStore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(6, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildWelcomePage(),
                _buildFeaturesPage(),
                _buildLicenseInfoPage(),
                _buildLicenseInstructionsPage(),
                _buildLicenseActivationPage(),
                _buildStoreCreationPage(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Précédent'),
                  )
                else
                  const SizedBox(),
                
                if (_currentPage < 4)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Suivant'),
                  )
                else if (_currentPage == 4)
                  ElevatedButton(
                    onPressed: _isValidatingLicense ? null : _validateLicense,
                    child: _isValidatingLicense
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Activer'),
                  )
                else
                  ElevatedButton(
                    onPressed: _isCreatingStore ? null : _createStoreAndAdmin,
                    child: _isCreatingStore
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Terminer'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 100, color: Colors.blue),
          const SizedBox(height: 30),
          Text(
            'Bienvenue dans Gestion moderne de magasin',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Votre solution complète de gestion de magasin. Gérez vos produits, ventes, achats et bien plus encore.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fonctionnalités Principales',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureItem(Icons.inventory, 'Gestion des Produits', 'Stock, prix, catégories'),
          _buildFeatureItem(Icons.shopping_cart, 'Ventes & Achats', 'Transactions complètes'),
          _buildFeatureItem(Icons.people, 'Clients & Fournisseurs', 'Gestion des contacts'),
          _buildFeatureItem(Icons.analytics, 'Rapports & Statistiques', 'Analyses détaillées'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 80, color: Colors.green),
          const SizedBox(height: 30),
          Text(
            'Licence et Conditions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gestion moderne de magasin nécessite une licence valide pour fonctionner. '
            'Votre licence garantit l\'accès à toutes les fonctionnalités et au support technique.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'En utilisant ce logiciel, vous acceptez les conditions d\'utilisation et la politique de confidentialité.',
              style: TextStyle(color: Colors.blue.shade700),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseInstructionsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.key, size: 80, color: Colors.orange),
          const SizedBox(height: 30),
          Text(
            'Activation de la Licence',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pour activer votre licence, vous aurez besoin d\'une clé de licence valide.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Format de licence:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'LIC-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseActivationPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key, size: 80, color: Colors.blue),
          const SizedBox(height: 30),
          Text(
            'Saisissez votre Licence',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _licenseController,
            decoration: InputDecoration(
              labelText: 'Clé de licence',
              hintText: 'LIC-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX',
              border: OutlineInputBorder(),
              errorText: _licenseError,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Générer une licence de test
              _licenseController.text = LicenseService.generateTestLicense();
            },
            child: const Text('Utiliser une licence de test'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCreationPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Configuration du Magasin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            
            if (_storeError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _storeError!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            
            // Informations du magasin
            Text(
              'Informations du Magasin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du magasin *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du propriétaire *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lieu du magasin *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            // Compte administrateur
            Text(
              'Compte Administrateur',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _adminUsernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _adminPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}