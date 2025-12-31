import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import '../core/database/database_helper.dart';
import '../models/app_settings.dart';

/// Service de gestion des licences - Client HTTP simple
class LicenseService {
  // URL du backend pour l'activation
  static const String _activationUrl = 'https://magasinlicence.onrender.com/api/license/activate';
  
  /// Active la licence via le backend
  static Future<LicenseActivationResult> activateLicense(String licenseKey) async {
    if (licenseKey.trim().isEmpty) {
      return LicenseActivationResult(
        success: false,
        message: 'Veuillez saisir une licence',
        canContinue: false,
      );
    }

    try {
      // Générer device_id unique automatiquement
      final deviceId = await _getDeviceId();
      
      final response = await http.post(
        Uri.parse(_activationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'license_key': licenseKey.trim(),
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      final success = data['success'] == true;
      final message = data['message'] ?? '';
      
      if (success) {
        // Backend dit OK - stocker et continuer
        await _storeLicenseInDatabase(licenseKey.trim());
        return LicenseActivationResult(
          success: true,
          message: message,
          canContinue: true,
        );
      } else {
        // Backend dit NON - bloquer
        return LicenseActivationResult(
          success: false,
          message: message,
          canContinue: false,
        );
      }
    } catch (e) {
      return LicenseActivationResult(
        success: false,
        message: 'Impossible de vérifier les mises à jour',
        canContinue: false,
      );
    }
  }
  
  /// Stocke la licence dans SQLite
  static Future<void> _storeLicenseInDatabase(String license) async {
    try {
      final existing = await DatabaseHelper.instance.getAppSettings();
      if (existing != null) {
        await DatabaseHelper.instance.updateAppSettings(AppSettings(
          id: 1,
          license: license,
          firstLaunchDone: existing.firstLaunchDone,
          updatedAt: DateTime.now().toIso8601String(),
        ));
      } else {
        await DatabaseHelper.instance.updateAppSettings(AppSettings(
          id: 1,
          license: license,
          firstLaunchDone: false,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ));
      }
    } catch (e) {
      throw Exception('Erreur stockage licence: $e');
    }
  }
  
  /// Génère un device_id unique et stable basé sur l'appareil
  static Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String rawData = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        rawData = '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}_${androidInfo.device}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        rawData = '${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemName}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        rawData = '${windowsInfo.computerName}_${windowsInfo.numberOfCores}_${windowsInfo.systemMemoryInMegabytes}_${windowsInfo.userName}_${windowsInfo.majorVersion}_${windowsInfo.minorVersion}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        rawData = '${linuxInfo.machineId}_${linuxInfo.name}_${linuxInfo.version}_${linuxInfo.id}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        rawData = '${macInfo.systemGUID}_${macInfo.model}_${macInfo.kernelVersion}_${macInfo.osRelease}';
      } else {
        rawData = 'UNKNOWN_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Créer un hash SHA-256 stable et unique
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);
      return digest.toString().toUpperCase().substring(0, 32);
    } catch (e) {
      // Fallback en cas d'erreur
      final fallback = 'FALLBACK_${DateTime.now().millisecondsSinceEpoch}';
      final bytes = utf8.encode(fallback);
      final digest = sha256.convert(bytes);
      return digest.toString().toUpperCase().substring(0, 32);
    }
  }
  
  /// Génère une licence de test
  static String generateTestLicense() {
    return 'LIC-8A866EC50BF9580E-14101F42F9FEBE21';
  }
}

/// Résultat de l'activation de licence
class LicenseActivationResult {
  final bool success;
  final String message;
  final bool canContinue;

  LicenseActivationResult({
    required this.success,
    required this.message,
    required this.canContinue,
  });
}