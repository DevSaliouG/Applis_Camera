
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/service_base_donnees.dart';
import '../../services/service_images_web.dart';
import '../../services/service_stockage_unifie.dart';
import '../../modeles/modele_media.dart';

class EcranAppareilPhoto extends StatefulWidget {
  const EcranAppareilPhoto({super.key});

  @override
  State<EcranAppareilPhoto> createState() => _EcranAppareilPhotoState();
}

class _EcranAppareilPhotoState extends State<EcranAppareilPhoto> {
  CameraController? _controleur;
  List<CameraDescription>? _appareils;
  bool _appareilPret = false;
  bool _enregistrementEnCours = false;
  final ServiceBaseDeDonnees _serviceBD = ServiceBaseDeDonnees();

  @override
  void initState() {
    super.initState();
    _initialiserAppareil();
  }

  Future<void> _initialiserAppareil() async {
    try {
      _appareils = await availableCameras();
      if (_appareils!.isNotEmpty) {
        _controleur = CameraController(
          _appareils![0],
          ResolutionPreset.high,
        );

        await _controleur!.initialize();
        setState(() {
          _appareilPret = true;
        });
      }
    } catch (e) {
      print('Erreur initialisation appareil: $e');
    }
  }

  Future<void> _prendrePhoto() async {
    if (!_appareilPret || _controleur == null) return;

    try {
      final XFile photo = await _controleur!.takePicture();
      await _sauvegarderMedia(photo.path, 'image');

      // Message de confirmation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo sauvegardée')),
      );
    } catch (e) {
      print('Erreur prise photo: $e');
    }
  }

  Future<void> _demarrerEnregistrement() async {
    if (!_appareilPret || _controleur == null) return;

    try {
      await _controleur!.startVideoRecording();
      setState(() {
        _enregistrementEnCours = true;
      });
    } catch (e) {
      print('Erreur enregistrement: $e');
    }
  }

  Future<void> _arreterEnregistrement() async {
    if (!_enregistrementEnCours || _controleur == null) return;

    try {
      final XFile video = await _controleur!.stopVideoRecording();
      setState(() {
        _enregistrementEnCours = false;
      });
      await _sauvegarderMedia(video.path, 'video');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vidéo sauvegardée')),
      );
    } catch (e) {
      print('Erreur arrêt enregistrement: $e');
    }
  }

  // Dans la fonction _sauvegarderMedia, utilisez ServiceStockageUnifie
  Future<void> _sauvegarderMedia(String chemin, String type) async {
    try {
      print(' Sauvegarde média: $chemin');

      // Pour le web, convertir blob en base64 si nécessaire
      String cheminFinal = chemin;

      if (kIsWeb && chemin.startsWith('blob:')) {
        final converted = await ServiceImagesWeb.convertirBlobEnBase64(chemin);
        if (converted != null) {
          cheminFinal = converted;
        }
      }

      // Créer l'objet média
      // Dans _sauvegarderMedia de ecran_appareil_photo.dart
      ElementMedia media = ElementMedia(
        id: DateTime.now().millisecondsSinceEpoch,
        type: type,
        cheminLocal: cheminFinal,
        dateCreation: DateTime.now(),
        dossier: type == 'image' ? 'Images' : 'Videos', // ← ICI: changer de 'General' à 'Images'/'Videos'
        annotations: null,
        etiquettes: [],
        estFavori: false,
      );

      // Sauvegarder avec le service unifié
      await ServiceStockageUnifie().sauvegarderMedia(media);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' ${type == 'image' ? 'Photo' : 'Vidéo'} sauvegardée'),
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      print(' Erreur sauvegarde média: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _importerDepuisGalerie() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _sauvegarderMedia(image.path, 'image');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image importée')),
        );
      }
    } catch (e) {
      print('Erreur importation galerie: $e');
    }
  }

  void _basculerAppareil() {
    if (_appareils == null || _appareils!.length < 2) return;

    CameraDescription nouvelAppareil = _controleur!.description == _appareils![0]
        ? _appareils![1]
        : _appareils![0];

    _controleur?.dispose();
    _controleur = CameraController(nouvelAppareil, ResolutionPreset.high);
    _controleur!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _basculerAppareil,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Naviguer vers scanner QR
            },
          ),
        ],
      ),
      body: _appareilPret && _controleur != null
          ? Stack(
        children: [
          CameraPreview(_controleur!),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _importerDepuisGalerie,
                  mini: true,
                  child: const Icon(Icons.photo_library),
                ),
              ],
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _prendrePhoto,
            child: const Icon(Icons.camera),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _enregistrementEnCours ? _arreterEnregistrement : _demarrerEnregistrement,
            backgroundColor: _enregistrementEnCours ? Colors.red : Colors.blue,
            child: Icon(_enregistrementEnCours ? Icons.stop : Icons.videocam),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _controleur?.dispose();
    super.dispose();
  }
}