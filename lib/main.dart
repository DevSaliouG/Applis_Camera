// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si_capture_2/core/themes/theme_app.dart';
import 'package:si_capture_2/core/themes/theme_manager.dart';
import 'fonctionnalites/appareil_photo/ecran_appareil_photo.dart';
import 'fonctionnalites/galerie/ecran_galerie.dart';
import 'fonctionnalites/parametres/ecran_parametres.dart';

void main() => runApp(const ApplicationSilicCapture());

class ApplicationSilicCapture extends StatelessWidget {
  const ApplicationSilicCapture({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'SilicCapture',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            home: const EcranPrincipal(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _indexCourant = 0;

  final List<Widget> _ecrans = [
    const EcranAppareilPhoto(),
    const EcranGalerie(),
    const EcranParametres(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _ecrans[_indexCourant],
      ),
      // Cacher la BottomNavigationBar uniquement sur l'écran appareil photo (index 0)
      bottomNavigationBar: _indexCourant == 0
          ? null // Pas de BottomNavigationBar sur l'écran appareil photo
          : ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _indexCourant,
              onTap: (index) {
                setState(() {
                  _indexCourant = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _indexCourant == 0 ? 28 : 24,
                          height: _indexCourant == 0 ? 28 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _indexCourant == 0
                                ? colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            _indexCourant == 0
                                ? Icons.camera_alt_rounded
                                : Icons.camera_alt_outlined,
                            size: _indexCourant == 0 ? 20 : 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  label: 'CAPTURE',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _indexCourant == 1 ? 28 : 24,
                          height: _indexCourant == 1 ? 28 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _indexCourant == 1
                                ? colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            _indexCourant == 1
                                ? Icons.photo_library_rounded
                                : Icons.photo_library_outlined,
                            size: _indexCourant == 1 ? 20 : 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  label: 'GALERIE',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _indexCourant == 2 ? 28 : 24,
                          height: _indexCourant == 2 ? 28 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _indexCourant == 2
                                ? colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            _indexCourant == 2
                                ? Icons.settings_rounded
                                : Icons.settings_outlined,
                            size: _indexCourant == 2 ? 20 : 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  label: 'PARAMÈTRES',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}