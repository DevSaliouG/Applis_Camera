class ParametresUtilisateur {
  bool themeSombre;
  int qualiteImage;
  bool sauvegardeAuto;
  bool notifications;
  String langue;

  ParametresUtilisateur({
    this.themeSombre = false,
    this.qualiteImage = 1,
    this.sauvegardeAuto = true,
    this.notifications = true,
    this.langue = 'fr',
  });

  Map<String, dynamic> versMap() {
    return {
      'themeSombre': themeSombre ? 1 : 0,
      'qualiteImage': qualiteImage,
      'sauvegardeAuto': sauvegardeAuto ? 1 : 0,
      'notifications': notifications ? 1 : 0,
      'langue': langue,
    };
  }

  factory ParametresUtilisateur.depuisMap(Map<String, dynamic> map) {
    return ParametresUtilisateur(
      themeSombre: map['themeSombre'] == 1,
      qualiteImage: map['qualiteImage'] ?? 1,
      sauvegardeAuto: map['sauvegardeAuto'] == 1,
      notifications: map['notifications'] == 1,
      langue: map['langue'] ?? 'fr',
    );
  }
}