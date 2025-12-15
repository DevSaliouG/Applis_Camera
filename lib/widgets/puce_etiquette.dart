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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: couleur.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: couleur.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texte,
              style: TextStyle(
                color: couleur,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: couleur.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: couleur,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}