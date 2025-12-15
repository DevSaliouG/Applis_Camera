import 'dart:io';
import 'package:intl/intl.dart';

class UtilsMedia {
  // Formateurs de date
  static final DateFormat _dateFormatComplet = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateFormatCourt = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateFormatHeure = DateFormat('HH:mm');
  static final DateFormat _dateFormatRelative = DateFormat('E d MMM', 'fr_FR');

  // Extensions supportées
  static const List<String> _extensionsImages = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'heic'
  ];

  static const List<String> _extensionsVideos = [
    'mp4', 'avi', 'mov', 'mkv', 'webm', 'flv', 'wmv', 'm4v', '3gp'
  ];

  static const List<String> _extensionsAudio = [
    'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a'
  ];

  static const List<String> _extensionsDocuments = [
    'pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'
  ];

  // Formats de date
  static String formaterDate(DateTime date) {
    return _dateFormatComplet.format(date);
  }

  static String formaterDateCourt(DateTime date) {
    return _dateFormatCourt.format(date);
  }

  static String formaterHeure(DateTime date) {
    return _dateFormatHeure.format(date);
  }

  static String formaterDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateDay).inDays;

    if (difference == 0) {
      return 'Aujourd\'hui, ${formaterHeure(date)}';
    } else if (difference == 1) {
      return 'Hier, ${formaterHeure(date)}';
    } else if (difference < 7) {
      return '${difference} jours, ${formaterHeure(date)}';
    } else {
      return _dateFormatRelative.format(date);
    }
  }

  static String formaterDateAvecJour(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  // Extraction de nom de fichier
  static String obtenirNomFichier(String chemin) {
    if (chemin.isEmpty) return 'Fichier sans nom';

    try {
      // Gestion des chemins web (URL)
      if (chemin.startsWith('http://') || chemin.startsWith('https://')) {
        final uri = Uri.parse(chemin);
        final path = uri.path;
        if (path.isNotEmpty) {
          return path.split('/').last;
        }
        return uri.host;
      }

      // Gestion des chemins locaux
      if (chemin.contains('/')) {
        return chemin.split('/').last;
      }

      if (chemin.contains('\\')) {
        return chemin.split('\\').last;
      }

      return chemin;
    } catch (e) {
      return 'Fichier invalide';
    }
  }

  static String obtenirNomSansExtension(String chemin) {
    final nomFichier = obtenirNomFichier(chemin);
    final lastDotIndex = nomFichier.lastIndexOf('.');

    if (lastDotIndex != -1) {
      return nomFichier.substring(0, lastDotIndex);
    }
    return nomFichier;
  }

  static String obtenirExtension(String chemin) {
    final nomFichier = obtenirNomFichier(chemin);
    final lastDotIndex = nomFichier.lastIndexOf('.');

    if (lastDotIndex != -1 && lastDotIndex < nomFichier.length - 1) {
      return nomFichier.substring(lastDotIndex + 1).toLowerCase();
    }
    return '';
  }

  static String obtenirDossierParent(String chemin) {
    try {
      if (chemin.contains('/')) {
        final segments = chemin.split('/');
        if (segments.length > 1) {
          return segments[segments.length - 2];
        }
      }

      if (chemin.contains('\\')) {
        final segments = chemin.split('\\');
        if (segments.length > 1) {
          return segments[segments.length - 2];
        }
      }
    } catch (e) {
      // Ignorer l'erreur et retourner 'Inconnu'
    }
    return 'Inconnu';
  }

  // Vérification des types de média
  static bool estImage(String chemin) {
    final extension = obtenirExtension(chemin);
    return _extensionsImages.contains(extension);
  }

  static bool estVideo(String chemin) {
    final extension = obtenirExtension(chemin);
    return _extensionsVideos.contains(extension);
  }

  static bool estAudio(String chemin) {
    final extension = obtenirExtension(chemin);
    return _extensionsAudio.contains(extension);
  }

  static bool estDocument(String chemin) {
    final extension = obtenirExtension(chemin);
    return _extensionsDocuments.contains(extension);
  }

  static String obtenirTypeMime(String chemin) {
    final extension = obtenirExtension(chemin);

    if (estImage(chemin)) return 'image/$extension';
    if (estVideo(chemin)) return 'video/$extension';
    if (estAudio(chemin)) return 'audio/$extension';
    if (estDocument(chemin)) {
      switch (extension) {
        case 'pdf': return 'application/pdf';
        case 'doc': return 'application/msword';
        case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        default: return 'application/octet-stream';
      }
    }

    return 'application/octet-stream';
  }

  static String obtenirIconeType(String chemin) {
    if (estImage(chemin)) return '🖼️';
    if (estVideo(chemin)) return '🎥';
    if (estAudio(chemin)) return '🎵';
    if (estDocument(chemin)) return '📄';
    return '📁';
  }

  // Gestion des tailles de fichier (si disponible)
  static String formaterTaille(int octets) {
    if (octets < 1024) return '$octets octets';

    final kilos = octets / 1024;
    if (kilos < 1024) return '${kilos.toStringAsFixed(1)} Ko';

    final megas = kilos / 1024;
    if (megas < 1024) return '${megas.toStringAsFixed(1)} Mo';

    final gigas = megas / 1024;
    return '${gigas.toStringAsFixed(2)} Go';
  }

  // Validation et nettoyage
  static bool estCheminValide(String chemin) {
    if (chemin.isEmpty) return false;

    // Vérifier les caractères interdits (selon l'OS)
    if (Platform.isWindows) {
      final forbiddenChars = r'<>:"/\|?*';
      if (chemin.contains(RegExp('[$forbiddenChars]'))) return false;
    } else {
      if (chemin.contains('/') && !chemin.startsWith('/')) return false;
    }

    return true;
  }

  static String nettoyerNomFichier(String nom) {
    // Remplacer les caractères problématiques
    return nom.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String genererNomUnique(String nomBase, {String? extension}) {
    final maintenant = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(maintenant);
    final nomNettoye = nettoyerNomFichier(nomBase);

    if (extension != null && extension.isNotEmpty) {
      return '${nomNettoye}_$timestamp.$extension';
    }
    return '${nomNettoye}_$timestamp';
  }

  // Utilitaires pour les durées (vidéo/audio)
  static String formaterDuree(Duration duree) {
    final heures = duree.inHours;
    final minutes = duree.inMinutes.remainder(60);
    final secondes = duree.inSeconds.remainder(60);

    if (heures > 0) {
      return '${heures.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secondes.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secondes.toString().padLeft(2, '0')}';
    }
  }

  static String formaterDureeCourte(Duration duree) {
    if (duree.inHours > 0) {
      return '${duree.inHours}h ${duree.inMinutes.remainder(60)}min';
    } else if (duree.inMinutes > 0) {
      return '${duree.inMinutes}min ${duree.inSeconds.remainder(60)}s';
    } else {
      return '${duree.inSeconds}s';
    }
  }

  // Comparaison et tri
  static int comparerParDate(DateTime a, DateTime b) {
    return b.compareTo(a); // Du plus récent au plus ancien
  }

  static int comparerParNom(String a, String b) {
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  static int comparerParType(String a, String b) {
    final typeA = obtenirTypeMime(a);
    final typeB = obtenirTypeMime(b);
    return typeA.compareTo(typeB);
  }

  // Gestion des métadonnées
  static Map<String, String> extraireMetadonneesNom(String nomFichier) {
    final result = <String, String>{};

    // Essaye d'extraire la date du nom de fichier (format courant: IMG_20231225_123456.jpg)
    final datePattern = RegExp(r'(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})');
    final match = datePattern.firstMatch(nomFichier);

    if (match != null) {
      result['date_extraite'] = '${match.group(1)}-${match.group(2)}-${match.group(3)} '
          '${match.group(4)}:${match.group(5)}:${match.group(6)}';
    }

    // Essaye d'extraire des tags (ex: vacances_ete_2024.jpg)
    final tags = nomFichier
        .split(RegExp(r'[_\-. ]'))
        .where((part) => part.length > 2 && !part.contains(RegExp(r'\d')))
        .toList();

    if (tags.isNotEmpty) {
      result['mots_cles'] = tags.join(', ');
    }

    return result;
  }
}