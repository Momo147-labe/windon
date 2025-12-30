import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.hasUpdate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json, String currentVersion) {
    final latestVersion = json['latest_version'] as String;
    return UpdateInfo(
      latestVersion: latestVersion,
      downloadUrl: json['download_url'] as String,
      hasUpdate: _compareVersions(currentVersion, latestVersion) < 0,
    );
  }

  static int _compareVersions(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (currentPart < latestPart) return -1;
      if (currentPart > latestPart) return 1;
    }
    return 0;
  }
}

class UpdateService {
  static const String _updateUrl = 'https://raw.githubusercontent.com/Momo147-labe/gestionmagasin/main/update.json';
  final Dio _dio = Dio();

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(_updateUrl);
      if (response.statusCode == 200) {
        return UpdateInfo.fromJson(response.data, currentVersion);
      }
      return null;
    } catch (e) {
      throw UpdateException('Impossible de vérifier les mises à jour: ${e.toString()}');
    }
  }

  Future<String> downloadUpdate(String downloadUrl, Function(double) onProgress) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = downloadUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';

      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } catch (e) {
      throw UpdateException('Échec du téléchargement: ${e.toString()}');
    }
  }

  Future<void> installUpdate(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.start(filePath, [], mode: ProcessStartMode.detached);
        exit(0);
      } else {
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw UpdateException('Impossible de lancer l\'installateur');
        }
      }
    } catch (e) {
      throw UpdateException('Erreur lors de l\'installation: ${e.toString()}');
    }
  }
}

class UpdateException implements Exception {
  final String message;
  UpdateException(this.message);
  
  @override
  String toString() => message;
}