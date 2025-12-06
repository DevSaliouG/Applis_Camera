import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class ServiceImagesWeb {
  // Convertir une URL blob en base64 pour le web
  static Future<String?> convertirBlobEnBase64(String blobUrl) async {
    try {
      if (!blobUrl.startsWith('blob:')) return blobUrl;

      final html.HttpRequest request = await html.HttpRequest.request(
        blobUrl,
        responseType: 'blob',
      );

      final html.Blob blob = request.response as html.Blob;

      final completer = Completer<String?>();
      final html.FileReader reader = html.FileReader();

      reader.onLoad.listen((event) {
        final String base64 = reader.result as String;
        completer.complete(base64);
      });

      reader.onError.listen((event) {
        completer.complete(null);
      });

      reader.readAsDataUrl(blob);

      return await completer.future;

    } catch (e) {
      print('Erreur conversion blob en base64: $e');
      return null;
    }
  }

  // Convertir une URL blob en Uint8List (pour les vidéos)
  static Future<Uint8List?> convertirBlobEnUint8List(String blobUrl) async {
    try {
      if (!blobUrl.startsWith('blob:')) return null;

      final html.HttpRequest request = await html.HttpRequest.request(
        blobUrl,
        responseType: 'blob',
      );

      final html.Blob blob = request.response as html.Blob;
      final completer = Completer<Uint8List?>();
      final html.FileReader reader = html.FileReader();

      reader.onLoad.listen((event) {
        completer.complete(reader.result as Uint8List);
      });

      reader.onError.listen((event) {
        completer.complete(null);
      });

      reader.readAsArrayBuffer(blob);

      return await completer.future;
    } catch (e) {
      print('Erreur conversion blob en Uint8List: $e');
      return null;
    }
  }

  // Créer un widget Image depuis différents types de sources
  static Widget creerImageWidget(String source, {BoxFit fit = BoxFit.cover}) {
    if (source.startsWith('blob:')) {
      // URL blob (temporaire sur le web)
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _creerPlaceholder();
        },
      );
    } else if (source.startsWith('data:image')) {
      // Data URL base64
      return Image.memory(
        _extractBase64Data(source),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _creerPlaceholder();
        },
      );
    } else if (source.startsWith('http')) {
      // URL réseau
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _creerPlaceholder();
        },
      );
    } else {
      // Autres cas (doit être base64 sans préfixe)
      try {
        return Image.memory(
          base64Decode(source),
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _creerPlaceholder();
          },
        );
      } catch (e) {
        return _creerPlaceholder();
      }
    }
  }

  // Extraire les données base64 d'une data URL
  static Uint8List _extractBase64Data(String dataUrl) {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex != -1) {
      return base64Decode(dataUrl.substring(commaIndex + 1));
    }
    return base64Decode(dataUrl);
  }

  static Widget _creerPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.photo, size: 40, color: Colors.grey),
      ),
    );
  }

  // Vérifier si une source est une image valide
  static bool estImageValide(String source) {
    if (source.isEmpty) return false;
    return source.startsWith('blob:') ||
        source.startsWith('data:image') ||
        source.startsWith('http');
  }

  // Gestion du stockage IndexedDB pour les vidéos web
  static Future<String?> sauvegarderVideoDansIndexedDB(String blobUrl) async {
    try {
      final Uint8List? videoData = await convertirBlobEnUint8List(blobUrl);
      if (videoData == null) return null;

      // Créer un ID unique pour la vidéo
      final id = 'video_${DateTime.now().millisecondsSinceEpoch}';

      // Stocker dans localStorage comme solution temporaire
      final String base64Video = base64Encode(videoData);
      if (base64Video.length < 5000000) { // 5MB limite pour localStorage
        html.window.localStorage['video_$id'] = base64Video;

        // Retourner une URL data pour la vidéo
        return 'data:video/mp4;base64,$base64Video';
      } else {
        print(' Vidéo trop volumineuse pour localStorage: ${base64Video.length} bytes');
        return null;
      }
    } catch (e) {
      print('Erreur sauvegarde vidéo: $e');
      return null;
    }
  }

  // Charger une vidéo depuis le stockage web
  static Future<String?> chargerVideoDepuisStockageWeb(String id) async {
    try {
      // Vérifier d'abord dans localStorage
      final storedData = html.window.localStorage['video_$id'];
      if (storedData != null) {
        return 'data:video/mp4;base64,$storedData';
      }

      // Si pas trouvé, vérifier si c'est déjà une URL valide
      if (id.startsWith('blob:') || id.startsWith('data:video') || id.startsWith('http')) {
        return id;
      }

      return null;
    } catch (e) {
      print('Erreur chargement vidéo: $e');
      return null;
    }
  }

  // Méthode pour vérifier si une URL blob est toujours valide
  static Future<bool> verifierUrlBlobValide(String blobUrl) async {
    try {
      if (!blobUrl.startsWith('blob:')) return true;

      final request = await html.HttpRequest.request(
        blobUrl,
        method: 'HEAD',
      );
      return request.status == 200;
    } catch (e) {
      return false;
    }
  }
}