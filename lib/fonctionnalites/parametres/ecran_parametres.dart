import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _chargerParametres();
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

  Future<void> _effacerToutesDonnees() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer toutes les données'),
        content: const Text('Cette action est irréversible. Voulez-vous continuer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Effacer tous les fichiers et la base de données
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
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          // Thème
          SwitchListTile(
            title: const Text('Thème sombre'),
            value: _parametres.themeSombre,
            onChanged: (value) {
              setState(() {
                _parametres.themeSombre = value;
              });
              _mettreAJourParametres();
            },
          ),

          // Qualité image
          ListTile(
            title: const Text('Qualité des images'),
            subtitle: Text(_obtenirTexteQualite(_parametres.qualiteImage)),
            onTap: () {
              _afficherSelecteurQualite();
            },
          ),

          // Sauvegarde automatique
          SwitchListTile(
            title: const Text('Sauvegarde automatique'),
            value: _parametres.sauvegardeAuto,
            onChanged: (value) {
              setState(() {
                _parametres.sauvegardeAuto = value;
              });
              _mettreAJourParametres();
            },
          ),

          // Notifications
          SwitchListTile(
            title: const Text('Notifications'),
            value: _parametres.notifications,
            onChanged: (value) {
              setState(() {
                _parametres.notifications = value;
              });
              _mettreAJourParametres();
            },
          ),

          // Langue
          ListTile(
            title: const Text('Langue'),
            subtitle: const Text('Français'),
            onTap: () {
              // TODO: Changer langue
            },
          ),

          // Confidentialité
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Confidentialité'),
            onTap: () {
              // TODO: Écran confidentialité
            },
          ),

          // Stockage
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Stockage'),
            subtitle: const Text('Voir l\'utilisation'),
            onTap: () {
              // TODO: Écran stockage
            },
          ),

          // À propos
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              _afficherAPropos();
            },
          ),

          // Effacer données
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Effacer toutes les données', style: TextStyle(color: Colors.red)),
            onTap: _effacerToutesDonnees,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qualité des images'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Basse'),
              value: 0,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Moyenne'),
              value: 1,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Haute'),
              value: 2,
              groupValue: _parametres.qualiteImage,
              onChanged: (value) {
                setState(() {
                  _parametres.qualiteImage = value!;
                });
                _mettreAJourParametres();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _afficherAPropos() {
    showAboutDialog(
      context: context,
      applicationName: 'SilicCapture',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 - Application pour étudiants en Master SI',
      children: [
        const Text('Smart Information Capture'),
        const SizedBox(height: 10),
        const Text('Capturez, organisez et partagez vos informations visuelles'),
      ],
    );
  }
}