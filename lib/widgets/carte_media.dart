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

  const CarteMedia({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<CarteMedia> createState() => _CarteMediaState();
}

class _CarteMediaState extends State<CarteMedia> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _videoInitialized = true;
      });
    } catch (e) {
      print('Erreur initialisation vidéo: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        elevation: 2,
        child: Stack(
          children: [
            // Contenu média
            _buildMediaContent(),

            // Indicateur vidéo
            if (widget.media.type == 'video')
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Indicateur favori
            if (widget.media.estFavori)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 16,
                  ),
                ),
              ),

            // Date en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                ),
                child: Text(
                  UtilsMedia.formaterDate(widget.media.dateCreation),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.media.type == 'image') {
      return _buildImageWidget();
    } else if (widget.media.type == 'video') {
      return _buildVideoWidget();
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildImageWidget() {
    // Pour le web
    if (kIsWeb) {
      return ServiceImagesWeb.creerImageWidget(
        widget.media.cheminLocal,
        fit: BoxFit.cover,
      );
    }

    // Pour mobile
    try {
      File fichierImage = File(widget.media.cheminLocal);
      if (fichierImage.existsSync()) {
        return Image.file(
          fichierImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      }
    } catch (e) {
      print('Erreur chargement image: $e');
    }

    return _buildPlaceholder();
  }

  Widget _buildVideoWidget() {
    if (_videoInitialized && _videoController != null) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              widget.media.type == 'video' ? 'Vidéo' : 'Document',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          widget.media.type == 'image'
              ? Icons.photo
              : widget.media.type == 'video'
              ? Icons.videocam
              : Icons.insert_drive_file,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}