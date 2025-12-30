import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/store_info.dart';
import '../models/user.dart';
import '../services/license_service.dart';
import '../core/database/database_helper.dart';
import '../widgets/welcome_page.dart';
import '../widgets/features_page.dart';
import '../widgets/license_info_page.dart';
import '../widgets/license_instructions_page.dart';
import '../widgets/license_activation_page.dart';
import '../widgets/store_creation_page.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _validatedLicense;
  
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

  Future<void> _onLicenseValidated() async {
    // Stocker la licence validée
    try {
      final settings = AppSettings(
        license: _validatedLicense,
        firstLaunchDone: false,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.updateAppSettings(settings);
      _nextPage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _onStoreCreated() async {
    try {
      // Marquer le premier lancement comme terminé
      final settings = AppSettings(
        license: _validatedLicense,
        firstLaunchDone: true,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseHelper.instance.updateAppSettings(settings);
      
      // Rediriger vers login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Configuration Initiale',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(6, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage 
                              ? Colors.blue 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Étape ${_currentPage + 1} sur 6',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(), // Empêcher le swipe
              children: [
                const WelcomePage(),
                const FeaturesPage(),
                const LicenseInfoPage(),
                const LicenseInstructionsPage(),
                LicenseActivationPage(onLicenseValidated: _onLicenseValidated),
                StoreCreationPage(onStoreCreated: _onStoreCreated),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Précédent
                if (_currentPage > 0 && _currentPage < 4)
                  TextButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  )
                else
                  const SizedBox(width: 100),
                
                // Indicateur de page
                Text(
                  _getPageTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Bouton Suivant
                if (_currentPage < 4)
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Suivant'),
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0: return 'Bienvenue';
      case 1: return 'Fonctionnalités';
      case 2: return 'Licence';
      case 3: return 'Instructions';
      case 4: return 'Activation';
      case 5: return 'Configuration';
      default: return '';
    }
  }
}