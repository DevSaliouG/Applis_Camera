class Etiquette {
  int? id;
  String nom;
  String couleur;

  Etiquette({
    this.id,
    required this.nom,
    this.couleur = '#2196F3',
  });

  Map<String, dynamic> versMap() {
    return {
      'id': id,
      'nom': nom,
      'couleur': couleur,
    };
  }

  factory Etiquette.depuisMap(Map<String, dynamic> map) {
    return Etiquette(
      id: map['id'],
      nom: map['nom'],
      couleur: map['couleur'] ?? '#2196F3',
    );
  }
}