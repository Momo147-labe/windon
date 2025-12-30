import 'package:flutter/material.dart';
import '../services/license_service.dart';

class LicenseActivationPage extends StatefulWidget {
  final VoidCallback onLicenseValidated;

  const LicenseActivationPage({
    Key? key,
    required this.onLicenseValidated,
  }) : super(key: key);

  @override
  State<LicenseActivationPage> createState() => _LicenseActivationPageState();
}

class _LicenseActivationPageState extends State<LicenseActivationPage> {
  final _licenseController = TextEditingController();
  bool _isValidating = false;
  String? _error;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _validateLicense() async {
    final license = _licenseController.text.trim();
    
    if (license.isEmpty) {
      setState(() => _error = 'Veuillez saisir une licence');
      return;
    }

    if (!LicenseService.isValidFormat(license)) {
      setState(() => _error = 'Format de licence invalide');
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    try {
      final result = await LicenseService.activateLicense(license);
      
      if (result.canContinue) {
        widget.onLicenseValidated();
      } else {
        setState(() {
          _error = result.message;
          _isValidating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'activation: $e';
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key, size: 100, color: Colors.blue.shade600),
          const SizedBox(height: 32),
          Text(
            'Activation de la Licence',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Saisissez votre clé de licence pour continuer',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _licenseController,
              decoration: InputDecoration(
                labelText: 'Clé de licence',
                hintText: 'LIC-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                enabled: !_isValidating,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: _isValidating ? null : _validateLicense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: _isValidating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Activer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          TextButton(
            onPressed: _isValidating ? null : () {
              _licenseController.text = LicenseService.generateTestLicense();
            },
            child: const Text('Utiliser une licence de test'),
          ),
        ],
      ),
    );
  }
}