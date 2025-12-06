import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceSecurite {
  static final FlutterSecureStorage _stockage = const FlutterSecureStorage();

  static Future<void> sauvegarderDonneeSecurisee(String cle, String valeur) async {
    await _stockage.write(key: cle, value: valeur);
  }

  static Future<String?> obtenirDonneeSecurisee(String cle) async {
    return await _stockage.read(key: cle);
  }

  static Future<void> supprimerDonneeSecurisee(String cle) async {
    await _stockage.delete(key: cle);
  }

  static Future<void> supprimerToutesDonnees() async {
    await _stockage.deleteAll();
  }

  static Future<bool> verifierPremiereOuverture() async {
    String? premiereOuverture = await obtenirDonneeSecurisee('premiere_ouverture');
    return premiereOuverture == null;
  }
}