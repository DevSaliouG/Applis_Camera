import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'fonctionnalites/appareil_photo/ecran_appareil_photo.dart';
import 'fonctionnalites/galerie/ecran_galerie.dart';
import 'fonctionnalites/parametres/ecran_parametres.dart';

void main() {
  // Initialisation spécifique à la plateforme
  if (kIsWeb) {
    print('Application exécutée sur le web');
    // Pour le web, certaines fonctionnalités seront limitées
    _configurerPourWeb();
  } else {
    print('Application exécutée sur mobile');
  }

  runApp(const ApplicationSilicCapture());
}

/*void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const ApplicationSilicCapture(), // Wrap your app
  ),
);*/


/// Configuration spécifique pour le web
void _configurerPourWeb() {
  // Désactiver certaines fonctionnalités non supportées sur le web
  // ou configurer des alternatives
}

class ApplicationSilicCapture extends StatelessWidget {
  const ApplicationSilicCapture({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilicCapture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EcranPrincipal(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Éviter le zoom automatique du texte
          ),
          child: child!,
        );
      },
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
  bool _afficherAvertissementWeb = kIsWeb;

  final List<Widget> _ecrans = [
    const EcranAppareilPhoto(),
    const EcranGalerie(),
    const EcranParametres(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bandeau d'avertissement pour le web
          if (_afficherAvertissementWeb)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Version web - certaines fonctionnalités sont limitées. Pour une expérience complète, utilisez l\'application mobile.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () {
                      setState(() {
                        _afficherAvertissementWeb = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Contenu principal
          Expanded(
            child: _ecrans[_indexCourant],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexCourant,
        onTap: (index) {
          setState(() {
            _indexCourant = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galerie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}