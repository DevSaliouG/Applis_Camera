import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import '../../core/utils/utils_media.dart';
import '../../modeles/modele_media.dart';
import '../../services/service_images_web.dart';


class EcranDetailMedia extends StatefulWidget {
  final ElementMedia media;

  const EcranDetailMedia({super.key, required this.media});

  @override
  State<EcranDetailMedia> createState() => _EcranDetailMediaState();
}

class _EcranDetailMediaState extends State<EcranDetailMedia> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _isPlaying = false;

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
        // Pour le web
        if (widget.media.cheminLocal.startsWith('data:video')) {
          // C'est une data URL
          _videoController = VideoPlayerController.network(widget.media.cheminLocal);
        } else if (widget.media.cheminLocal.startsWith('blob:')) {
          // C'est une URL blob
          _videoController = VideoPlayerController.network(widget.media.cheminLocal);
        } else {
          // Autres cas
          _videoController = VideoPlayerController.network(widget.media.cheminLocal);
        }
      } else {
        // Pour mobile
        _videoController = VideoPlayerController.file(File(widget.media.cheminLocal));
      }

      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {
        _videoInitialized = true;
      });
    } catch (e) {
      print(' Erreur initialisation vidéo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement vidéo: $e')),
        );
      }
    }
  }

  void _jouerPauseVideo() {
    if (_videoController != null && _videoInitialized) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        _videoController!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UtilsMedia.obtenirNomFichier(widget.media.cheminLocal)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Naviguer vers éditeur
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _partagerMedia,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildInfoBar(),
    );
  }

  Widget _buildBody() {
    if (widget.media.type == 'image') {
      return _buildImageDetail();
    } else if (widget.media.type == 'video') {
      return _buildVideoDetail();
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text('Document'),
          ],
        ),
      );
    }
  }

  Widget _buildImageDetail() {
    return Center(
      child: kIsWeb
          ? InteractiveViewer(
        maxScale: 5.0,
        minScale: 0.5,
        child: ServiceImagesWeb.creerImageWidget(
          widget.media.cheminLocal,
          fit: BoxFit.contain,
        ),
      )
          : PhotoView(
        imageProvider: FileImage(File(widget.media.cheminLocal)),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 3.0,
        heroAttributes: PhotoViewHeroAttributes(
          tag: widget.media.id ?? UniqueKey(),
        ),
      ),
    );
  }

  Widget _buildVideoDetail() {
    if (!_videoInitialized || _videoController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de la vidéo...'),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),

        // Contrôles de lecture
        Positioned.fill(
          child: GestureDetector(
            onTap: _jouerPauseVideo,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Barre de progression
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _videoController!.value.position.inSeconds.toDouble(),
                        min: 0,
                        max: _videoController!.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _videoController!.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(
                      '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type: ${widget.media.type.toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${UtilsMedia.formaterDate(widget.media.dateCreation)}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (widget.media.annotations != null && widget.media.annotations!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Notes: ${widget.media.annotations}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (widget.media.etiquettes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                children: widget.media.etiquettes.map((etiquette) {
                  return Chip(
                    label: Text(etiquette),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          if (widget.media.estFavori)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Favori',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _partagerMedia() async {
    // TODO: Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
    );
  }
}