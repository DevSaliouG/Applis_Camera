import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/service_base_donnees.dart';
import '../../services/service_images_web.dart';
import '../../services/service_stockage_unifie.dart';
import '../../modeles/modele_media.dart';
import '../galerie/ecran_galerie.dart';

class EcranAppareilPhoto extends StatefulWidget {
  const EcranAppareilPhoto({super.key});

  @override
  State<EcranAppareilPhoto> createState() => _EcranAppareilPhotoState();
}

class _EcranAppareilPhotoState extends State<EcranAppareilPhoto>
    with SingleTickerProviderStateMixin {
  CameraController? _controleur;
  List<CameraDescription>? _appareils;
  bool _appareilPret = false;
  bool _enregistrementEnCours = false;
  late AnimationController _animationController;
  bool _flashActif = false;
  CameraLensDirection _directionAppareil = CameraLensDirection.back;
  double _zoomLevel = 1.0;
  bool _showSettingsPanel = false;
  int _selectedMode = 0; // 0: Photo, 1: Vidéo, 2: Portrait, 3: Panoramique
  final List<String> _modes = ['PHOTO', 'VIDÉO', 'PORTRAIT', 'PANORAMA'];
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _initialiserAppareil();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 30),
      vsync: this,
    );
  }

  Future<void> _initialiserAppareil() async {
    try {
      _appareils = await availableCameras();
      if (_appareils!.isNotEmpty) {
        _controleur = CameraController(
          _appareils!.firstWhere(
                (camera) => camera.lensDirection == _directionAppareil,
            orElse: () => _appareils!.first,
          ),
          ResolutionPreset.max,
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
      // Animation de flash visuel
     // _animationController.forward(from: 0);

      final XFile photo = await _controleur!.takePicture();
      await _sauvegarderMedia(photo.path, 'image');

      if (!mounted) return;
      _afficherFeedbackCapture('photo');
    } catch (e) {
      print('Erreur prise photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _demarrerEnregistrement() async {
    if (!_appareilPret || _controleur == null) return;

    try {
      await _controleur!.startVideoRecording();
      setState(() {
        _enregistrementEnCours = true;
        _recordingStartTime = DateTime.now();
        _startRecordingTimer();
      });
      _afficherFeedbackCapture('video_start');
    } catch (e) {
      print('Erreur enregistrement: $e');
    }
  }

  Future<void> _arreterEnregistrement() async {
    if (!_enregistrementEnCours || _controleur == null) return;

    try {
      _stopRecordingTimer();
      final XFile video = await _controleur!.stopVideoRecording();
      setState(() {
        _enregistrementEnCours = false;
        _recordingDuration = Duration.zero;
        _recordingStartTime = null;
      });
      await _sauvegarderMedia(video.path, 'video');

      if (!mounted) return;
      _afficherFeedbackCapture('video_end');
    } catch (e) {
      print('Erreur arrêt enregistrement: $e');
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _recordingStartTime != null) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        });
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  int _getRecordingTime() {
    return _recordingDuration.inSeconds;
  }

  void _afficherFeedbackCapture(String type) {
    if (!mounted) return;

    final Color color = Theme.of(context).colorScheme.primary;
    final String message = type == 'photo'
        ? 'Photo capturée'
        : type == 'video_start'
        ? 'Enregistrement démarré'
        : 'Vidéo sauvegardée';

    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type == 'photo'
                        ? Icons.check_circle
                        : type == 'video_start'
                        ? Icons.fiber_manual_record
                        : Icons.videocam,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () => overlay.remove());
  }

  Future<void> _sauvegarderMedia(String chemin, String type) async {
    try {
      String cheminFinal = chemin;

      if (kIsWeb && chemin.startsWith('blob:')) {
        final converted = await ServiceImagesWeb.convertirBlobEnBase64(chemin);
        if (converted != null) {
          cheminFinal = converted;
        }
      }

      final media = ElementMedia(
        id: DateTime.now().millisecondsSinceEpoch,
        type: type,
        cheminLocal: cheminFinal,
        dateCreation: DateTime.now(),
        dossier: type == 'image' ? 'Images' : 'Videos',
        annotations: null,
        etiquettes: [],
        estFavori: false,
      );

      await ServiceStockageUnifie().sauvegarderMedia(media);
    } catch (e) {
      print('Erreur sauvegarde média: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importerDepuisGalerie() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _sauvegarderMedia(image.path, 'image');
        if (mounted) _afficherFeedbackCapture('photo');
      }
    } catch (e) {
      print('Erreur importation galerie: $e');
    }
  }

  Future<void> _basculerAppareil() async {
    // 1. Vérifier qu'il y a au moins deux caméras
    if (_appareils == null || _appareils!.length < 2) return;

    // 2. Ne rien faire si déjà en cours de basculement
    if (!mounted || _controleur == null) return;

    setState(() {
      _appareilPret = false; // Afficher un indicateur de chargement
    });

    try {
      // 3. Calculer la nouvelle direction
      final nouvelleDirection = _directionAppareil == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      // 4. Trouver la nouvelle caméra
      final nouvelAppareil = _appareils!.firstWhere(
            (camera) => camera.lensDirection == nouvelleDirection,
        orElse: () => _appareils!.first,
      );

      // 5. Attendre la fermeture complète de l'ancien contrôleur
      await _controleur!.dispose();

      // 6. Créer le nouveau contrôleur AVANT d'appeler initialize()
      _controleur = CameraController(
        nouvelAppareil,
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // 7. Initialiser le nouveau contrôleur
      await _controleur!.initialize();

      // 8. Mettre à jour l'état UNIQUEMENT si le widget est toujours monté
      if (mounted) {
        setState(() {
          _directionAppareil = nouvelleDirection;
          _appareilPret = true;
        });
      }

    } catch (e) {
      print(' Erreur basculement appareil: $e');

      // 9. En cas d'erreur, revenir à la caméra arrière
      if (mounted) {
        try {
          // Réinitialiser avec la caméra arrière par défaut
          final cameraArriere = _appareils!.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _appareils!.first,
          );

          _controleur = CameraController(
            cameraArriere,
            ResolutionPreset.veryHigh,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

          await _controleur!.initialize();

          setState(() {
            _directionAppareil = CameraLensDirection.back;
            _appareilPret = true;
          });

        } catch (e2) {
          print(' Erreur restauration caméra: $e2');
        }
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _flashActif = !_flashActif;
    });
    // TODO: Implémenter contrôle réel du flash
  }

  void _toggleSettingsPanel() {
    setState(() {
      _showSettingsPanel = !_showSettingsPanel;
    });
  }

  void _selectMode(int index) {
    setState(() {
      _selectedMode = index;
    });
  }

  void _adjustZoom(double delta) {
    setState(() {
      _zoomLevel = (_zoomLevel + delta).clamp(1.0, 5.0);
    });
    // TODO: Implémenter contrôle réel du zoom
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Vue caméra en plein écran
          if (_appareilPret && _controleur != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controleur!.value.previewSize!.width,
                  height: _controleur!.value.previewSize!.height,
                  child: CameraPreview(_controleur!),
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Initialisation de la caméra...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Animation de flash
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Visibility(
                visible: _animationController.value > 0,
                child: Container(
                  color: Colors.white.withOpacity(
                    _animationController.value * 0.7,
                  ),
                ),
              );
            },
          ),

          // Barre supérieure simplifiée
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context, isDark, colorScheme),
          ),

          // Barre inférieure simplifiée
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context, isDark, colorScheme, size),
          ),

          // Panneau de réglages
          if (_showSettingsPanel)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 60,
              child: _buildSettingsPanel(context, isDark, colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton retour
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            // Indicateur d'enregistrement (seulement si en cours)
            if (_enregistrementEnCours)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _recordingDuration.inSeconds % 2 == 0
                            ? Colors.white
                            : Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Bouton flash et paramètres
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Icon(
                      _flashActif
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleSettingsPanel,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(
                        color: _showSettingsPanel
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _showSettingsPanel
                          ? Icons.settings
                          : Icons.settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(
      BuildContext context, bool isDark, ColorScheme colorScheme, Size size) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sélecteur de mode
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_modes.length, (index) {
                  final isSelected = _selectedMode == index;
                  return GestureDetector(
                    onTap: () => _selectMode(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                        isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _modes[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Barre de contrôle principale
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bouton galerie
                _buildGalleryButton(context, colorScheme),

                // Bouton de capture principal
                _buildMainCaptureButton(context, colorScheme),

                // Bouton basculement appareil
                _buildCameraSwitchButton(context, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context, ColorScheme colorScheme) {
    return FutureBuilder<ElementMedia?>(
      future: _getLastMedia(),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EcranGalerie(),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Stack(
              children: [
                if (snapshot.hasData && snapshot.data != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: colorScheme.primary.withOpacity(0.4),
                        child: Icon(
                          snapshot.data!.type == 'image'
                              ? Icons.photo
                              : Icons.videocam,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                Positioned.fill(
                  child: Icon(
                    Icons.photo_library,
                    color:
                    Colors.white.withOpacity(snapshot.hasData ? 0.8 : 1.0),
                    size: 20,
                  ),
                ),

                if (snapshot.hasData && snapshot.data != null)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCaptureButton(
      BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _selectedMode == 1
          ? (_enregistrementEnCours
          ? _arreterEnregistrement
          : _demarrerEnregistrement)
          : _prendrePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _selectedMode == 1 && _enregistrementEnCours ? 68 : 72,
        height: _selectedMode == 1 && _enregistrementEnCours ? 68 : 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
            width: _selectedMode == 1 && _enregistrementEnCours ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _selectedMode == 1 && _enregistrementEnCours ? 24 : 30,
            height: _selectedMode == 1 && _enregistrementEnCours ? 24 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selectedMode == 1 && _enregistrementEnCours
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraSwitchButton(
      BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _basculerAppareil,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.cameraswitch_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flash
              _buildSettingItem(
                context,
                icon: _flashActif ? Icons.flash_on : Icons.flash_off,
                label: _flashActif ? 'Flash activé' : 'Flash désactivé',
                onTap: _toggleFlash,
              ),
              const SizedBox(height: 8),
              // Zoom
              _buildSettingItem(
                context,
                icon: Icons.zoom_in,
                label: 'Zoom ${_zoomLevel.toStringAsFixed(1)}x',
                onTap: () => _adjustZoom(0.5),
              ),
              const SizedBox(height: 8),
              _buildSettingItem(
                context,
                icon: Icons.zoom_out,
                label: 'Réduire',
                onTap: () => _adjustZoom(-0.5),
              ),
              const SizedBox(height: 8),
              // Timer
              _buildSettingItem(
                context,
                icon: Icons.timer,
                label: 'Timer 10s',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes utilitaires
  Future<ElementMedia?> _getLastMedia() async {
    try {
      final service = ServiceStockageUnifie();
      final medias = await service.chargerMedias();
      if (medias.isNotEmpty) {
        return medias.last;
      }
    } catch (e) {
      print('Erreur chargement dernier média: $e');
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _animationController.dispose();
    _controleur?.dispose();
    super.dispose();
  }
}