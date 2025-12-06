class ElementMedia {
  int? id;
  String type;
  String cheminLocal;
  List<String> etiquettes;
  DateTime dateCreation;
  String? annotations;
  String? dossier;
  bool estFavori;
  String? miniature;

  ElementMedia({
    this.id,
    required this.type,
    required this.cheminLocal,
    this.etiquettes = const [],
    required this.dateCreation,
    this.annotations,
    this.dossier = 'General',
    this.estFavori = false,
    this.miniature,
  });

  Map<String, dynamic> versMap() {
    return {
      'id': id,
      'type': type,
      'cheminLocal': cheminLocal,
      'etiquettes': etiquettes.join(','),
      'dateCreation': dateCreation.toIso8601String(),
      'annotations': annotations ?? '',
      'dossier': dossier ?? 'General',
      'estFavori': estFavori ? 1 : 0,
      'miniature': miniature ?? '',
    };
  }

  factory ElementMedia.depuisMap(Map<String, dynamic> map) {
    return ElementMedia(
      id: map['id'],
      type: map['type'],
      cheminLocal: map['cheminLocal'],
      etiquettes: (map['etiquettes'] as String).split(',').where((t) => t.isNotEmpty).toList(),
      dateCreation: DateTime.parse(map['dateCreation']),
      annotations: map['annotations'],
      dossier: map['dossier'] ?? 'General',
      estFavori: map['estFavori'] == 1,
      miniature: map['miniature'],
    );
  }
}