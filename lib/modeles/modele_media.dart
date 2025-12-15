import 'dart:io';

import 'package:flutter/foundation.dart';

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
  String? nomFichier;

  ElementMedia({
    this.id,
    required this.type,
    required this.cheminLocal,
    List<String>? etiquettes,
    required this.dateCreation,
    this.annotations,
    this.dossier = 'General',
    this.estFavori = false,
    this.miniature,
    this.nomFichier,
  }) : etiquettes = etiquettes ?? [];

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
      'nomFichier': nomFichier ?? _extraireNomFichier(),
    };
  }

  factory ElementMedia.depuisMap(Map<String, dynamic> map) {
    return ElementMedia(
      id: map['id'],
      type: map['type'],
      cheminLocal: map['cheminLocal'],
      etiquettes: (map['etiquettes'] as String? ?? '')
          .split(',')
          .where((t) => t.isNotEmpty)
          .toList(),
      dateCreation: DateTime.parse(map['dateCreation']),
      annotations: map['annotations'],
      dossier: map['dossier'] ?? 'General',
      estFavori: map['estFavori'] == 1,
      miniature: map['miniature'],
      nomFichier: map['nomFichier'] ?? '',
    );
  }

  // Getter nomFichier qui extrait le nom du fichier depuis le chemin
  String get nomFichierOuExtrait {
    if (nomFichier != null && nomFichier!.isNotEmpty) {
      return nomFichier!;
    }
    return _extraireNomFichier();
  }

  // Méthode privée pour extraire le nom du fichier du chemin
  String _extraireNomFichier() {
    try {
      final pathSegments = cheminLocal.split(Platform.pathSeparator);
      return pathSegments.last;
    } catch (e) {
      // Si c'est une URL web, essayer de l'extraire différemment
      if (cheminLocal.contains('/')) {
        final segments = cheminLocal.split('/');
        return segments.last;
      }
      return 'Fichier sans nom';
    }
  }

  // Méthode pour mettre à jour le nom de fichier
  void mettreAJourNomFichier(String nouveauNom) {
    nomFichier = nouveauNom;
  }

  // Méthode pour ajouter une étiquette
  void ajouterEtiquette(String etiquette) {
    if (!etiquettes.contains(etiquette)) {
      etiquettes.add(etiquette);
    }
  }

  // Méthode pour retirer une étiquette
  void retirerEtiquette(String etiquette) {
    etiquettes.remove(etiquette);
  }

  // Méthode pour basculer l'état favori
  void basculerFavori() {
    estFavori = !estFavori;
  }

  // Méthode pour mettre à jour les annotations
  void mettreAJourAnnotations(String nouvellesAnnotations) {
    annotations = nouvellesAnnotations;
  }

  // Méthode pour copier l'objet avec des modifications optionnelles
  ElementMedia copyWith({
    int? id,
    String? type,
    String? cheminLocal,
    List<String>? etiquettes,
    DateTime? dateCreation,
    String? annotations,
    String? dossier,
    bool? estFavori,
    String? miniature,
    String? nomFichier,
  }) {
    return ElementMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      cheminLocal: cheminLocal ?? this.cheminLocal,
      etiquettes: etiquettes ?? List.from(this.etiquettes),
      dateCreation: dateCreation ?? this.dateCreation,
      annotations: annotations ?? this.annotations,
      dossier: dossier ?? this.dossier,
      estFavori: estFavori ?? this.estFavori,
      miniature: miniature ?? this.miniature,
      nomFichier: nomFichier ?? this.nomFichier,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ElementMedia &&
        other.id == id &&
        other.type == type &&
        other.cheminLocal == cheminLocal &&
        listEquals(other.etiquettes, etiquettes) &&
        other.dateCreation == dateCreation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    type.hashCode ^
    cheminLocal.hashCode ^
    etiquettes.hashCode ^
    dateCreation.hashCode;
  }

  @override
  String toString() {
    return 'ElementMedia{id: $id, type: $type, nom: $nomFichierOuExtrait, dossier: $dossier, favori: $estFavori}';
  }
}