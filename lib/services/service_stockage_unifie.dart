import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../modeles/modele_media.dart';
import 'service_images_web.dart';


class ServiceStockageUnifie {
  static final ServiceStockageUnifie _instance = ServiceStockageUnifie._internal();
  factory ServiceStockageUnifie() => _instance;
  ServiceStockageUnifie._internal();

  // Clés pour le stockage
  static const String _cleMedias = 'silicapture_medias';
  static const String _cleBibliotheques = 'silicapture_bibliotheques';

  /// Sauvegarder un média (fonctionne sur web et mobile)
  Future<void> sauvegarderMedia(ElementMedia media) async {
    try {
      print(' Début sauvegarde média de type: ${media.type}');

      String cheminFinal = media.cheminLocal;

      // Traitement spécial pour le web
      if (kIsWeb) {
        if (media.type == 'video' && media.cheminLocal.startsWith('blob:')) {
          // Pour les vidéos web, sauvegarder dans localStorage
          final urlSauvegardee = await ServiceImagesWeb.sauvegarderVideoDansIndexedDB(media.cheminLocal);
          if (urlSauvegardee != null) {
            cheminFinal = urlSauvegardee;
          } else {
            // Fallback: conserver l'URL blob originale
            print('⚠ Utilisation de l\'URL blob originale pour la vidéo');
          }
        } else if (media.type == 'image' && media.cheminLocal.startsWith('blob:')) {
          // Convertir l'image en base64
          final converted = await ServiceImagesWeb.convertirBlobEnBase64(media.cheminLocal);
          if (converted != null) {
            cheminFinal = converted;
          }
        }
      }

      final mediaMisAJour = ElementMedia(
        id: media.id ?? DateTime.now().millisecondsSinceEpoch,
        type: media.type,
        cheminLocal: cheminFinal,
        etiquettes: media.etiquettes,
        dateCreation: media.dateCreation,
        annotations: media.annotations,
        dossier: media.dossier ?? 'General',
        estFavori: media.estFavori,
        miniature: media.miniature,
      );

      final prefs = await SharedPreferences.getInstance();
      final List<ElementMedia> mediasExistants = await chargerMedias();

      // Supprimer l'ancien média si existe
      if (media.id != null) {
        mediasExistants.removeWhere((m) => m.id == media.id);
      }

      mediasExistants.add(mediaMisAJour);

      final String mediasJson = jsonEncode(
          mediasExistants.map((m) => m.versMap()).toList()
      );

      await prefs.setString(_cleMedias, mediasJson);

      print(' Média sauvegardé: ${media.type} (ID: ${mediaMisAJour.id})');
    } catch (e) {
      print(' Erreur sauvegarde média: $e');
      rethrow;
    }
  }

  /// Charger tous les médias
  Future<List<ElementMedia>> chargerMedias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? mediasJson = prefs.getString(_cleMedias);

      if (mediasJson == null || mediasJson.isEmpty) {
        return [];
      }

      final List<dynamic> mediasList = jsonDecode(mediasJson);

      // Pour le web, vérifier les URLs blob
      final List<ElementMedia> medias = [];
      for (var json in mediasList) {
        final media = ElementMedia.depuisMap(Map<String, dynamic>.from(json));

        if (kIsWeb && media.type == 'video') {
          // Vérifier si l'URL blob est toujours valide
          final estValide = await ServiceImagesWeb.verifierUrlBlobValide(media.cheminLocal);
          if (!estValide) {
            // Essayer de recharger depuis le stockage web
            final nouvelleUrl = await ServiceImagesWeb.chargerVideoDepuisStockageWeb(media.cheminLocal);
            if (nouvelleUrl != null) {
              media.cheminLocal = nouvelleUrl;
            } else {
              print('⚠ Vidéo invalide et non récupérable: ${media.cheminLocal}');
              continue; // Ignorer ce média
            }
          }
        }

        medias.add(media);
      }

      return medias;
    } catch (e) {
      print(' Erreur chargement médias: $e');
      return [];
    }
  }

  /// Supprimer un média
  Future<void> supprimerMedia(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<ElementMedia> medias = await chargerMedias();

      final mediaASupprimer = medias.firstWhere((m) => m.id == id, orElse: () => ElementMedia(
        id: -1,
        type: '',
        cheminLocal: '',
        dateCreation: DateTime.now(),
      ));

      if (mediaASupprimer.id != -1) {
        // Pour le web, nettoyer aussi le localStorage
        if (kIsWeb && mediaASupprimer.type == 'video') {
          final idVideo = 'video_${mediaASupprimer.id}';
          html.window.localStorage.remove(idVideo);
        }

        medias.removeWhere((media) => media.id == id);

        final String mediasJson = jsonEncode(
            medias.map((m) => m.versMap()).toList()
        );

        await prefs.setString(_cleMedias, mediasJson);
        print( ' Média supprimé: $id');
      } else {
        print(' Média non trouvé pour suppression: $id');
      }
    } catch (e) {
      print(' Erreur suppression média: $e');
      rethrow;
    }
  }

  /// Vider tous les médias
  Future<void> viderTousMedias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cleMedias);

      // Pour le web, nettoyer aussi localStorage
      if (kIsWeb) {
        final keys = <String>[];
        for (var i = 0; i < html.window.localStorage.length; i++) {
          final key = html.window.localStorage.keys.elementAt(i);
          if (key.startsWith('video_')) {
            keys.add(key);
          }
        }

        for (var key in keys) {
          html.window.localStorage.remove(key);
        }
      }

      print(' Tous les médias vidés');
    } catch (e) {
      print(' Erreur vidage médias: $e');
      rethrow;
    }
  }

  /// Obtenir le nombre de médias
  Future<int> obtenirNombreMedias() async {
    final medias = await chargerMedias();
    return medias.length;
  }

  /// Ajouter un média à une bibliothèque
  Future<void> ajouterMediaABibliotheque(int mediaId, String nomBibliotheque) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger les bibliothèques existantes
      final String? biblioJson = prefs.getString(_cleBibliotheques);
      Map<String, List<int>> bibliotheques = {};

      if (biblioJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(biblioJson);
        decoded.forEach((key, value) {
          bibliotheques[key] = List<int>.from(value);
        });
      }

      // Initialiser la bibliothèque si elle n'existe pas
      if (!bibliotheques.containsKey(nomBibliotheque)) {
        bibliotheques[nomBibliotheque] = [];
      }

      // Ajouter le média à la bibliothèque
      if (!bibliotheques[nomBibliotheque]!.contains(mediaId)) {
        bibliotheques[nomBibliotheque]!.add(mediaId);
      }

      // Sauvegarder les bibliothèques
      await prefs.setString(_cleBibliotheques, jsonEncode(bibliotheques));

      print(' Média $mediaId ajouté à la bibliothèque: $nomBibliotheque');
    } catch (e) {
      print(' Erreur ajout à bibliothèque: $e');
      rethrow;
    }
  }

  /// Obtenir toutes les bibliothèques
  Future<List<String>> obtenirBibliotheques() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? biblioJson = prefs.getString(_cleBibliotheques);

      if (biblioJson == null) {
        return [];
      }

      final Map<String, dynamic> decoded = jsonDecode(biblioJson);
      return decoded.keys.toList();
    } catch (e) {
      print(' Erreur obtention bibliothèques: $e');
      return [];
    }
  }

  /// Obtenir les médias d'une bibliothèque spécifique
  Future<List<ElementMedia>> obtenirMediasParBibliotheque(String nomBibliotheque) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? biblioJson = prefs.getString(_cleBibliotheques);

      if (biblioJson == null) {
        return [];
      }

      final Map<String, dynamic> decoded = jsonDecode(biblioJson);
      if (!decoded.containsKey(nomBibliotheque)) {
        return [];
      }

      final List<int> idsMedias = List<int>.from(decoded[nomBibliotheque]);
      final List<ElementMedia> tousMedias = await chargerMedias();

      return tousMedias.where((media) =>
      media.id != null && idsMedias.contains(media.id)
      ).toList();
    } catch (e) {
      print(' Erreur obtention médias par bibliothèque: $e');
      return [];
    }
  }

  /// Supprimer une bibliothèque
  Future<void> supprimerBibliotheque(String nomBibliotheque) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? biblioJson = prefs.getString(_cleBibliotheques);

      if (biblioJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(biblioJson);
        decoded.remove(nomBibliotheque);

        await prefs.setString(_cleBibliotheques, jsonEncode(decoded));
        print(' Bibliothèque supprimée: $nomBibliotheque');
      }
    } catch (e) {
      print(' Erreur suppression bibliothèque: $e');
      rethrow;
    }
  }

  /// Mettre à jour le favori d'un média
  Future<void> mettreAJourFavori(int mediaId, bool estFavori) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<ElementMedia> medias = await chargerMedias();

      final index = medias.indexWhere((media) => media.id == mediaId);
      if (index != -1) {
        medias[index].estFavori = estFavori;

        final String mediasJson = jsonEncode(
            medias.map((m) => m.versMap()).toList()
        );

        await prefs.setString(_cleMedias, mediasJson);
        print(' Favori mis à jour pour média: $mediaId');
      }
    } catch (e) {
      print(' Erreur mise à jour favori: $e');
      rethrow;
    }
  }

  /// Méthode utilitaire pour obtenir un chemin de fichier (mobile seulement)
  static Future<String> obtenirCheminStockageMobile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Créer un dossier (mobile seulement)
  static Future<String> creerDossierMobile(String nomDossier) async {
    String cheminBase = await obtenirCheminStockageMobile();
    Directory dossier = Directory('$cheminBase/$nomDossier');

    if (!await dossier.exists()) {
      await dossier.create(recursive: true);
    }

    return dossier.path;
  }
}