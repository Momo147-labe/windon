import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/database/database_helper.dart';
import '../models/app_settings.dart';

/// Service de gestion des licences avec activation backend
class LicenseService {
  // Format de licence: LIC-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX
  static final RegExp _licenseRegex = RegExp(r'^LIC-[A-F0-9]{16}-[A-F0-9]{16}$');
  
  // URL du backend pour l'activation
  static const String _activationUrl = 'https://magasinlicence.onrender.com/api/license/activate';
  
  /// Valide le format de la licence
  static bool isValidFormat(String license) {
    return _licenseRegex.hasMatch(license.toUpperCase());
  }
  
  /// Active la licence sur l'appareil via le backend
  static Future<LicenseActivationResult> activateLicense(String licenseKey) async {
    if (!isValidFormat(licenseKey)) {
      return LicenseActivationResult(
        success: false,
        message: 'Format de licence invalide',
        canContinue: false,
      );
    }

    try {
      // Générer device_id unique
      final deviceId = await _getDeviceId();
      
      final response = await http.post(
        Uri.parse(_activationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'license_key': licenseKey.toUpperCase(),
          'client_id': 'CLIENT_1023',
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] == true;
        final message = data['message'] ?? '';
        
        if (success && message == 'Licence activée') {
          // CRITIQUE: Stocker la licence dans SQLite immédiatement
          await _storeLicenseInDatabase(licenseKey.toUpperCase());
          return LicenseActivationResult(
            success: true,
            message: 'Licence activée avec succès',
            canContinue: true,
          );
        } else if (success && message == 'Licence déjà activée') {
          return LicenseActivationResult(
            success: false,
            message: 'Cette licence a déjà été utilisée sur un autre appareil',
            canContinue: false,
          );
        } else {
          return LicenseActivationResult(
            success: false,
            message: message.isNotEmpty ? message : 'Licence falsifiée',
            canContinue: false,
          );
        }
      } else {
        return LicenseActivationResult(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          canContinue: false,
        );
      }
    } catch (e) {
      return LicenseActivationResult(
        success: false,
        message: 'Erreur de connexion: Vérifiez votre connexion internet',
        canContinue: false,
      );
    }
  }
  
  /// Stocke la licence dans SQLite (OBLIGATOIRE)
  static Future<void> _storeLicenseInDatabase(String license) async {
    try {
      final existing = await DatabaseHelper.instance.getAppSettings();
      if (existing != null) {
        // Mise à jour avec INSERT OR REPLACE
        await DatabaseHelper.instance.updateAppSettings(AppSettings(
          id: 1,
          license: license,
          firstLaunchDone: existing.firstLaunchDone,
          updatedAt: DateTime.now().toIso8601String(),
        ));
      } else {
        // Création nouvelle entrée
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
  
  /// Génère un device_id unique basé sur l'appareil
  static Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'ANDROID_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'IOS_${iosInfo.identifierForVendor}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return 'WIN_${windowsInfo.computerName}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return 'LINUX_${linuxInfo.machineId}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return 'MAC_${macInfo.systemGUID}';
      } else {
        return 'DEVICE_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      return 'DEVICE_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  /// Génère une licence de test
  static String generateTestLicense() {
    return 'LIC-8A866EC50BF9580E-14101F42F9FEBE21';
  }
  
  /// Formate la licence pour l'affichage
  static String formatLicense(String license) {
    return license.toUpperCase();
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