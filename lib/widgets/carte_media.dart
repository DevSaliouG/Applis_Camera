import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:si_capture_2/services/service_images_web.dart';
import '../modeles/modele_media.dart';
import '../core/utils/utils_media.dart';

class CarteMedia extends StatefulWidget {
  final ElementMedia media;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showSelection;

  const CarteMedia({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showSelection = false,
  });

  @override
  State<CarteMedia> createState() => _CarteMediaState();
}

class _CarteMediaState extends State<CarteMedia> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // --- PALETTE DE COULEURS (Design System) ---
  final Color _primaryColor = const Color(0xFFA8C3A1); // Vert Sauge
  final Color _secondaryColor = const Color(0xFFC57B57); // Terre Cuite
  final Color _accentColor = const Color(0xFFE53935); // Rouge pour favoris
  final Color _bgPlaceholder = const Color(0xFFF0F0F0);
  final Color _textColor = const Color(0xFF4A4A4A);
  final Color _glassBg = const Color(0xFFF7F3EF).withOpacity(0.95);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.media.type == 'video') {
      _initialiserVideo();
    }
  }

  Future<void> _initialiserVideo() async {
    try {
      if (kIsWeb) {
        _videoController = VideoPlayerController.network(widget.media.cheminLocal);
      } else {
        _videoController = VideoPlayerController.file(File(widget.media.cheminLocal));
      }

      await _videoController!.initialize();
      await _videoController!.setVolume(0);

      // Générer une miniature pour la première frame
      if (_videoController!.value.isInitialized) {
        setState(() {
          _videoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Erreur initialisation vidéo: $e');
    }
  }

  void _handleHover(bool hovering) {
    setState(() => _isHovering = hovering);
    if (hovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovering ? 0.15 : 0.08),
                      blurRadius: _isHovering ? 20 : 12,
                      offset: Offset(0, _isHovering ? 8 : 4),
                      spreadRadius: _isHovering ? -2 : 0,
                    ),
                    if (widget.isSelected)
                      BoxShadow(
                        color: _secondaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Carte de base avec effet de profondeur
                      _buildCardBase(),

                      // 2. Contenu média
                      _buildMediaContent(),

                      // 3. Overlay d'interaction
                      _buildInteractionOverlay(),

                      // 4. Indicateurs d'état
                      _buildStateIndicators(),

                      // 5. Info-bulle au survol
                      if (_isHovering) _buildHoverInfo(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBase() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _bgPlaceholder.withOpacity(0.8),
            _bgPlaceholder.withOpacity(0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    return widget.media.type == 'image'
        ? _buildImageWidget()
        : widget.media.type == 'video'
        ? _buildVideoWidget()
        : _buildPlaceholder();
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      return ServiceImagesWeb.creerImageWidget(
        widget.media.cheminLocal,
        fit: BoxFit.cover,
      );
    }

    try {
      File fichierImage = File(widget.media.cheminLocal);
      if (fichierImage.existsSync()) {
        return Image.file(
          fichierImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    } catch (e) {
      debugPrint('Erreur chargement image: $e');
    }

    return _buildPlaceholder();
  }

  Widget _buildVideoWidget() {
    if (_videoInitialized && _videoController != null) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),

          // Overlay de lecture vidéo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _bgPlaceholder,
            _bgPlaceholder.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.media.type == 'video'
                  ? Icons.play_circle_outline
                  : Icons.photo_outlined,
              size: 40,
              color: _textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              widget.media.type == 'video' ? 'Vidéo' : 'Image',
              style: TextStyle(
                color: _textColor.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionOverlay() {
    return AnimatedOpacity(
      opacity: _isHovering ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicators() {
    return Stack(
      children: [
        // Cercle de sélection avec animation
        if (widget.isSelected || widget.showSelection)
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              width: widget.isSelected ? 26 : 20,
              height: widget.isSelected ? 26 : 20,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? _secondaryColor
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white
                      : _secondaryColor.withOpacity(0.6),
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isSelected
                      ? Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                    key: const ValueKey('check'),
                  )
                      : Icon(
                    Icons.circle_outlined,
                    size: 10,
                    color: _secondaryColor.withOpacity(0.8),
                    key: const ValueKey('circle'),
                  ),
                ),
              ),
            ),
          ),

        // Indicateur favori avec effet brillant
        if (widget.media.estFavori)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _glassBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 16,
                color: Color(0xFFE53935),
              ),
            ),
          ),

        // Badge vidéo
        if (widget.media.type == 'video')
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _videoController?.value.duration != null
                        ? UtilsMedia.formaterDuree(
                        _videoController!.value.duration)
                        : 'Vidéo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Date discrète
        Positioned(
          bottom: 8,
          right: 8,
          child: Opacity(
            opacity: 0.7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                UtilsMedia.formaterDateCourt(widget.media.dateCreation),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoverInfo() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _opacityAnimation.value,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.media.nomFichier ?? 'Sans titre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    if (widget.media.annotations?.isNotEmpty == true)
                      Text(
                        widget.media.annotations!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ajouter cette fonction dans utils_media.dart
extension UtilsMediaExtensions on UtilsMedia {
  static String formaterDateCourt(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Aujourd\'hui';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}an';
    }
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}