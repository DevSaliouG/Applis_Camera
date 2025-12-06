import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../modeles/modele_media.dart';
import '../../core/utils/utils_media.dart';

class DetailMedia extends StatelessWidget {
  final ElementMedia media;

  const DetailMedia({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UtilsMedia.obtenirNomFichier(media.cheminLocal)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Naviguer vers éditeur
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Partager
            },
          ),
        ],
      ),
      body: Center(
        child: media.type == 'image'
            ? PhotoView(
          imageProvider: FileImage(File(media.cheminLocal)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        )
            : const Icon(Icons.videocam, size: 100),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${UtilsMedia.formaterDate(media.dateCreation)}',
              style: const TextStyle(color: Colors.white),
            ),
            if (media.annotations != null && media.annotations!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notes: ${media.annotations}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            if (media.etiquettes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  children: media.etiquettes.map((etiquette) {
                    return Chip(
                      label: Text(etiquette),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}