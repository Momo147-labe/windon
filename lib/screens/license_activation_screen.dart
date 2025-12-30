import 'package:flutter/material.dart';
import '../services/license_service.dart';

class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({Key? key}) : super(key: key);

  @override
  State<LicenseActivationScreen> createState() => _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _licenseController = TextEditingController();
  bool _isActivating = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _activateLicense() async {
    final license = _licenseController.text.trim();
    
    if (license.isEmpty) {
      setState(() => _error = 'Veuillez saisir une licence');
      return;
    }

    setState(() {
      _isActivating = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await LicenseService.activateLicense(license);
      
      if (result.canContinue) {
        // Seule la réponse "Licence activée" permet de continuer
        setState(() => _success = result.message);
        
        // Attendre un peu pour afficher le message de succès
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // "Licence déjà activée" ou "Licence falsifiée" bloquent l'accès
        setState(() {
          _error = result.message;
          _isActivating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'activation: $e';
        _isActivating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              
              Text(
                'Activation de Licence',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              Text(
                'Veuillez saisir votre clé de licence pour activer l\'application sur cet appareil.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _success!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              TextField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'Clé de licence',
                  hintText: 'LIC-12345678-ABCDEF1234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace'),
                enabled: !_isActivating,
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isActivating ? null : _activateLicense,
                  child: _isActivating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Activation en cours...'),
                          ],
                        )
                      : const Text('Activer'),
                ),
              ),
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: _isActivating ? null : () {
                  _licenseController.text = LicenseService.generateTestLicense();
                },
                child: const Text('Utiliser une licence de test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}