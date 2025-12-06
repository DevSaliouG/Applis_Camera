import 'package:intl/intl.dart';

class UtilsMedia {
  static String formaterDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String obtenirNomFichier(String chemin) {
    return chemin.split('/').last;
  }

  static String obtenirExtension(String chemin) {
    return chemin.split('.').last.toLowerCase();
  }

  static bool estImage(String chemin) {
    final extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    return extensions.contains(obtenirExtension(chemin));
  }

  static bool estVideo(String chemin) {
    final extensions = ['mp4', 'avi', 'mov', 'mkv'];
    return extensions.contains(obtenirExtension(chemin));
  }
}