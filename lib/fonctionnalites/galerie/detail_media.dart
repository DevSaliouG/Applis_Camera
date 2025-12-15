import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import '../../modeles/modele_media.dart';
import '../../core/utils/utils_media.dart';

class DetailMedia extends StatefulWidget {
  final ElementMedia media;
  final VoidCallback? onClose;

  const DetailMedia({super.key, required this.media, this.onClose});

  @override
  State<DetailMedia> createState() => _DetailMediaState();
}

class _DetailMediaState extends State<DetailMedia> {
  bool _isPlaying = false;
  bool _isMuted = false;
  int _currentTime = 23;
  final int _duration = 83;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.media.type == 'video') {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_currentTime >= _duration) {
          setState(() {
            _isPlaying = false;
            _currentTime = _duration;
          });
          _timer?.cancel();
        } else {
          setState(() {
            _currentTime++;
          });
        }
      });
    }
  }

  void _togglePlay() {
    HapticFeedback.selectionClick();
    setState(() {
      _isPlaying = !_isPlaying;
      _startTimer();
    });
  }

  void _toggleMute() {
    HapticFeedback.lightImpact();
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _skipBackward() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTime = (_currentTime - 10).clamp(0, _duration);
    });
  }

  void _skipForward() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTime = (_currentTime + 10).clamp(0, _duration);
    });
  }

  void _handleSeek(double value) {
    setState(() {
      _currentTime = value.toInt();
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildVideoPlayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF92400E),
            Color(0xFFB45309),
            Color(0xFFD97706),
          ],
        ),
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.amber[900]!.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Stack(
          children: [
            // Video Preview Background
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1765224747170-be7b97010052?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc2lsaG91ZXR0ZSUyMGF1ZGllbmNlfGVufDF8fHx8MTc2NTM5MDgzNXww&ixlib=rb-4.1.0&q=80&w=1080',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),

            // Top Bar avec effet glassmorphism
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 40,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildGlassButton(
                          icon: Icons.arrow_back,
                          onTap: widget.onClose ?? () => Navigator.pop(context),
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            UtilsMedia.obtenirNomFichier(widget.media.cheminLocal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            _buildGlassButton(
                              icon: Icons.share_outlined,
                              onTap: () {
                                // TODO: Partager la vidéo
                              },
                              size: 40,
                            ),
                            const SizedBox(width: 8),
                            _buildGlassButton(
                              icon: Icons.more_vert,
                              onTap: () {
                                // TODO: Menu options
                              },
                              size: 40,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center Play Controls
            Positioned.fill(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSkipButton(
                      icon: Icons.replay_10,
                      label: '10',
                      onTap: _skipBackward,
                    ),
                    const SizedBox(width: 48),
                    _buildPlayButton(),
                    const SizedBox(width: 48),
                    _buildSkipButton(
                      icon: Icons.forward_10,
                      label: '10',
                      onTap: _skipForward,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Additional Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGlassSmallButton(
                              icon: Icons.fullscreen,
                              onTap: () {},
                            ),
                            const SizedBox(width: 24),
                            _buildGlassSmallButton(
                              icon: Icons.share,
                              onTap: () {},
                            ),
                            const SizedBox(width: 24),
                            _buildGlassSmallButton(
                              icon: Icons.volume_off,
                              onTap: () {},
                            ),
                            const SizedBox(width: 24),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEC4899).withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 24),
                            _buildGlassSmallButton(
                              icon: Icons.headphones,
                              onTap: () {},
                            ),
                            const SizedBox(width: 24),
                            _buildGlassSmallButton(
                              icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                              onTap: _toggleMute,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Time and Seek Bar
                        Row(
                          children: [
                            Text(
                              _formatTime(_currentTime),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _currentTime.toDouble(),
                                  min: 0,
                                  max: _duration.toDouble(),
                                  onChanged: _handleSeek,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatTime(_duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSmallButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.grey[900],
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          UtilsMedia.obtenirNomFichier(widget.media.cheminLocal),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6F7D8C),
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3EF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFF6F7D8C), size: 22),
              onPressed: () {
                // TODO: Naviguer vers éditeur
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFA8C3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: Color(0xFFA8C3A1), size: 22),
              onPressed: () {
                // TODO: Partager
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: PhotoView(
                  imageProvider: FileImage(File(widget.media.cheminLocal)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.media.id ?? UniqueKey(),
                  ),
                  backgroundDecoration: const BoxDecoration(
                    color: Color(0xFFF7F3EF),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UtilsMedia.obtenirNomFichier(widget.media.cheminLocal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6F7D8C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          UtilsMedia.formaterDate(widget.media.dateCreation),
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF6F7D8C).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    if (widget.media.estFavori)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC57B57).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFC57B57).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: const Color(0xFFC57B57),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Favori',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFC57B57),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.media.annotations != null &&
                    widget.media.annotations!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annotations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6F7D8C).withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.media.annotations!,
                          style: const TextStyle(
                            color: Color(0xFF6F7D8C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                if (widget.media.etiquettes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Étiquettes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6F7D8C).withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.media.etiquettes.map((etiquette) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8C3A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFA8C3A1).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              etiquette,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA8C3A1),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.type == 'video') {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildVideoPlayer(),
        ),
      );
    } else {
      return _buildImageView();
    }
  }
}