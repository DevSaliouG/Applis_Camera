import 'package:flutter/material.dart';

class PuceEtiquette extends StatelessWidget {
  final String texte;
  final Color couleur;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PuceEtiquette({
    super.key,
    required this.texte,
    required this.couleur,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(texte),
        backgroundColor: couleur.withOpacity(0.2),
        labelStyle: TextStyle(color: couleur),
        deleteIcon: onDelete != null
            ? Icon(Icons.close, size: 16, color: couleur)
            : null,
        onDeleted: onDelete,
      ),
    );
  }
}