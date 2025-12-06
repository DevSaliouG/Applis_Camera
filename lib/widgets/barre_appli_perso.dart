import 'package:flutter/material.dart';

class BarreAppliPerso extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final List<Widget>? actions;
  final bool centreTitre;
  final double elevation;

  const BarreAppliPerso({
    super.key,
    required this.titre,
    this.actions,
    this.centreTitre = true,
    this.elevation = 2,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titre),
      centerTitle: centreTitre,
      elevation: elevation,
      actions: actions,
    );
  }
}