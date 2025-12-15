import 'dart:async';
import 'dart:io';
import 'dart:ui'; // Pour l'effet de flou
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import '../../core/utils/utils_media.dart';
import '../../modeles/modele_media.dart';
import '../../services/service_stockage_unifie.dart';

class EcranDetailMedia extends StatefulWidget {
  final ElementMedia media;

  const EcranDetailMedia({super.key, required this.media});

  @override
  State<EcranDetailMedia> createState() => _EcranDetailMediaState();
}

class _EcranDetailMediaState extends State<EcranDetailMedia>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _isPlaying = false;
  bool _interfaceVisible = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.value = 1.0;

    if (widget.media.type == 'video') {
      _initialiserVideo();
    }
  }

  Future<void> _initialiserVideo() async {
    try {
      if (kIsWeb) {
        // Sur le Web, on traite le chemin (Blob ou URL) comme une URL réseau
        _videoController = VideoPlayerController.networkUrl(
            Uri.parse(widget.media.cheminLocal));
      } else {
        // Sur Mobile, on utilise le fichier local
        _videoController = VideoPlayerController.file(
            File(widget.media.cheminLocal));
      }

      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);

      if (mounted) {
        setState(() => _videoInitialized = true);
      }
    } catch (e) {
      print('Erreur vidéo: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;
    // Met à jour l'UI pour la barre de progression
    setState(() {});

    // Détection fin de vidéo
    if (_videoController!.value.isInitialized &&
        _videoController!.value.position >= _videoController!.value.duration &&
        _isPlaying) { // Ajout check _isPlaying pour éviter boucle
      setState(() => _isPlaying = false);
      _videoController!.pause();
      _videoController!.seekTo(Duration.zero); // Rembobiner à la fin
      if (!_interfaceVisible) _basculerInterface(); // Réafficher contrôles
    }
  }

  void _basculerInterface() {
    setState(() {
      _interfaceVisible = !_interfaceVisible;
      if (_interfaceVisible) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _basculerLecture() {
    if (!_videoInitialized || _videoController == null) return;
    HapticFeedback.selectionClick();

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController!.play();
        if (_interfaceVisible) _basculerInterface();
      } else {
        _videoController!.pause();
        if (!_interfaceVisible) _basculerInterface();
      }
    });
  }

  Future<void> _toggleFavori() async {
    HapticFeedback.mediumImpact();
    // Mise à jour visuelle immédiate (optimiste)
    setState(() {
      widget.media.estFavori = !widget.media.estFavori;
    });

    try {
      final service = ServiceStockageUnifie();
      await service.mettreAJourFavori(
          widget.media.id!, widget.media.estFavori);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.media.estFavori ? 'Ajouté aux favoris' : 'Retiré des favoris',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFA8C3A1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        widget.media.estFavori = !widget.media.estFavori;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: _basculerInterface,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Contenu média (Image ou Vidéo)
            Positioned.fill(child: _buildMediaContent()),

            // 2. Overlay gradient pour lisibilité texte bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: FadeTransition(
                opacity: _animController,
                child: IgnorePointer( // Permet de cliquer à travers sur l'image
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Barre supérieure (Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animController,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            _buildGlassButton(
                              icon: widget.media.estFavori
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.media.estFavori
                                  ? Colors.red
                                  : Colors.white,
                              onTap: _toggleFavori,
                            ),
                            const SizedBox(width: 12),
                            _buildGlassButton(
                              icon: Icons.info_outline_rounded,
                              onTap: _afficherDetails,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Bouton play central (si vidéo)
            if (widget.media.type == 'video')
              if (!_isPlaying || _interfaceVisible)
                Center(
                  child: FadeTransition(
                    opacity: _animController,
                    child: GestureDetector(
                      onTap: _basculerLecture,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

            // 5. Contrôles vidéo (Slider)
            if (widget.media.type == 'video' && _videoInitialized)
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _animController,
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFA8C3A1),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_videoController!.value.position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(_videoController!.value.duration),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 6. Informations en bas (Nom, Date)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animController,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          UtilsMedia.obtenirNomFichier(widget.media.cheminLocal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          UtilsMedia.formaterDate(widget.media.dateCreation),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        if (widget.media.etiquettes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: widget.media.etiquettes.map((tag) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CORRECTION MAJEURE ICI ---
  Widget _buildMediaContent() {
    if (widget.media.type == 'image') {
      // Déterminer le fournisseur d'image selon la plateforme
      ImageProvider imageProvider;
      if (kIsWeb) {
        // Sur le Web, on utilise NetworkImage (les blobs sont des URLs)
        imageProvider = NetworkImage(widget.media.cheminLocal);
      } else {
        // Sur Mobile, on utilise FileImage
        imageProvider = FileImage(File(widget.media.cheminLocal));
      }

      return PhotoView(
        imageProvider: imageProvider, // Utilisation de la variable conditionnelle
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.5,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        heroAttributes: PhotoViewHeroAttributes(tag: widget.media.id.toString()),
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text("Erreur chargement image", style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      );
    } else {
      // Vidéo
      if (!_videoInitialized || _videoController == null) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFFA8C3A1)));
      }
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect( // Ajout ClipRRect pour le flou
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
    }
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _afficherDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6F7D8C),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Nom',
                UtilsMedia.obtenirNomFichier(widget.media.cheminLocal)),
            _buildDetailRow('Date',
                UtilsMedia.formaterDate(widget.media.dateCreation)),
            _buildDetailRow('Type', widget.media.type.toUpperCase()),
            _buildDetailRow('Dossier', widget.media.dossier ?? 'Général'),
            if (widget.media.annotations != null &&
                widget.media.annotations!.isNotEmpty)
              _buildDetailRow('Notes', widget.media.annotations!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6F7D8C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF4A4A4A)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _animController.dispose();
    super.dispose();
  }
}