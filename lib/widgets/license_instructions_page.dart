import 'package:flutter/material.dart';

class LicenseInstructionsPage extends StatelessWidget {
  const LicenseInstructionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.key, size: 100, color: Colors.orange.shade600),
          const SizedBox(height: 32),
          Text(
            'Instructions d\'Activation',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Pour activer votre licence, vous aurez besoin d\'une clé de licence valide.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  'Format de licence requis:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'LIC-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInstructionStep(
            '1',
            'Obtenez votre licence',
            'Contactez votre fournisseur pour obtenir une clé de licence valide.',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '2',
            'Saisissez la licence',
            'Entrez votre clé de licence dans le champ prévu à cet effet.',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '3',
            'Validation automatique',
            'Le système vérifiera automatiquement la validité de votre licence.',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}