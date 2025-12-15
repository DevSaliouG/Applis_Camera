import 'package:flutter/material.dart';

class BarreAppliPerso extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final List<Widget>? actions;
  final bool centreTitre;
  final Color? backgroundColor;
  final Color? titleColor;

  const BarreAppliPerso({
    super.key,
    required this.titre,
    this.actions,
    this.centreTitre = true,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titre,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: titleColor ?? const Color(0xFF6F7D8C),
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: centreTitre,
      elevation: 0,
      backgroundColor: backgroundColor ?? const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      actions: actions,
    );
  }
}