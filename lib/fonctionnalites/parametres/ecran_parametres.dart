// lib/fonctionnalites/parametres/ecran_parametres.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si_capture_2/core/themes/theme_manager.dart';
import '../../services/service_base_donnees.dart';
import '../../services/service_securite.dart';
import '../../modeles/modele_parametres.dart';

class EcranParametres extends StatefulWidget {
  const EcranParametres({super.key});

  @override
  State<EcranParametres> createState() => _EcranParametresState();
}

class _EcranParametresState extends State<EcranParametres> {
  final ServiceBaseDeDonnees _serviceBD = ServiceBaseDeDonnees();
  ParametresUtilisateur _parametres = ParametresUtilisateur();
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _chargerParametres();
    _themeManager = Provider.of<ThemeManager>(context, listen: false);
  }

  Future<void> _chargerParametres() async {
    _parametres = await _serviceBD.obtenirParametres();
    setState(() {});
  }

  Future<void> _mettreAJourParametres() async {
    await _serviceBD.mettreAJourParametres(_parametres);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres sauvegardés')),
    );
  }

  Future<void> _changerTheme(bool isDark) async {
    setState(() {
      _parametres.themeSombre = isDark;
    });
    await _mettreAJourParametres();
    _themeManager.toggleTheme(isDark);
  }

  Future<void> _mettreThemeSysteme() async {
    setState(() {
      _parametres.themeSombre = false;
    });
    await _mettreAJourParametres();
    _themeManager.setSystemTheme();
  }

  Future<void> _effacerToutesDonnees() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        title: Text('Effacer toutes les données',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87)),
        content: Text('Cette action est irréversible. Voulez-vous continuer ?',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700])),
          ),
          TextButton(
            onPressed: () async {
              await ServiceSecurite.supprimerToutesDonnees();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Toutes les données ont été effacées')),
              );
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: Icon(
              themeManager.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              _changerTheme(!themeManager.isDarkMode);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Section Apparence
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Apparence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(Icons.brightness_auto,
                          size: 20,
                          color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text('Thème système',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                  subtitle: Text('Suivre les paramètres du système',
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  value: ThemeMode.system,
                  groupValue: themeManager.themeMode,
                  onChanged: (value) {
                    _mettreThemeSysteme();
                  },
                  activeColor: isDark ? Colors.blue[300] : Colors.blue,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(Icons.light_mode,
                          size: 20,
                          color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text('Thème clair',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                  value: ThemeMode.light,
                  groupValue: themeManager.themeMode,
                  onChanged: (value) {
                    _changerTheme(false);
                  },
                  activeColor: isDark ? Colors.blue[300] : Colors.blue,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                RadioListTile<ThemeMode>(
                  title: Row(
                    children: [
                      Icon(Icons.dark_mode,
                          size: 20,
                          color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text('Thème sombre',
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                  value: ThemeMode.dark,
                  groupValue: themeManager.themeMode,
                  onChanged: (value) {
                    _changerTheme(true);
                  },
                  activeColor: isDark ? Colors.blue[300] : Colors.blue,
                ),
              ],
            ),
          ),

          // Section Général
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Général',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: Text('Qualité des images',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(_obtenirTexteQualite(_parametres.qualiteImage),
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  onTap: () {
                    _afficherSelecteurQualite();
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                SwitchListTile(
                  title: Text('Sauvegarde automatique',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  value: _parametres.sauvegardeAuto,
                  onChanged: (value) {
                    setState(() {
                      _parametres.sauvegardeAuto = value;
                    });
                    _mettreAJourParametres();
                  },
                  activeColor: isDark ? Colors.blue[300] : Colors.blue,
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                SwitchListTile(
                  title: Text('Notifications',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  value: _parametres.notifications,
                  onChanged: (value) {
                    setState(() {
                      _parametres.notifications = value;
                    });
                    _mettreAJourParametres();
                  },
                  activeColor: isDark ? Colors.blue[300] : Colors.blue,
                ),
              ],
            ),
          ),

          // Section Gestion
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Gestion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.security,
                      color: isDark ? Colors.white : Colors.black87),
                  title: Text('Confidentialité',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  onTap: () {
                    // TODO: Écran confidentialité
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                ListTile(
                  leading: Icon(Icons.storage,
                      color: isDark ? Colors.white : Colors.black87),
                  title: Text('Stockage',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text('Voir l\'utilisation',
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  onTap: () {
                    // TODO: Écran stockage
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                ListTile(
                  leading: Icon(Icons.info,
                      color: isDark ? Colors.white : Colors.black87),
                  title: Text('À propos',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  onTap: _afficherAPropos,
                ),
              ],
            ),
          ),

          // Section Zone de danger
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Zone de danger',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red.withOpacity(isDark ? 0.1 : 0.05),
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Effacer toutes les données',
                  style: TextStyle(color: Colors.red)),
              onTap: _effacerToutesDonnees,
            ),
          ),
        ],
      ),
    );
  }

  String _obtenirTexteQualite(int qualite) {
    switch (qualite) {
      case 0: return 'Basse';
      case 1: return 'Moyenne';
      case 2: return 'Haute';
      default: return 'Moyenne';
    }
  }

  void _afficherSelecteurQualite() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text('Qualité des images',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: Text('Basse',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87)),
              value: 0,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
              activeColor: isDark ? Colors.blue[300] : Colors.blue,
            ),
            RadioListTile(
              title: Text('Moyenne',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87)),
              value: 1,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
              activeColor: isDark ? Colors.blue[300] : Colors.blue,
            ),
            RadioListTile(
              title: Text('Haute',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87)),
              value: 2,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
              activeColor: isDark ? Colors.blue[300] : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  void _afficherAPropos() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showAboutDialog(
      context: context,
      applicationName: 'SilicCapture',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 - Application pour étudiants en Master SI',
      applicationIcon: const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
      children: [
        const SizedBox(height: 10),
        Text(
          'Smart Information Capture',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Capturez, organisez et partagez vos informations visuelles',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}