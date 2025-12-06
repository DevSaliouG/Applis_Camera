import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EcranEditeur extends StatefulWidget {
  final String cheminImage;

  const EcranEditeur({super.key, required this.cheminImage});

  @override
  State<EcranEditeur> createState() => _EcranEditeurState();
}

class _EcranEditeurState extends State<EcranEditeur> {
  Color _couleurSelectionnee = Colors.red;
  double _epaisseurPinceau = 2.0;
  final List<DessinPoint> _points = [];
  final TextEditingController _controleurAnnotations = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éditeur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _sauvegarder,
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de dessin
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _points.add(DessinPoint(
                    point: details.localPosition,
                    couleur: _couleurSelectionnee,
                    epaisseur: _epaisseurPinceau,
                  ));
                });
              },
              onPanStart: (details) {
                setState(() {
                  _points.add(DessinPoint(
                    point: details.localPosition,
                    couleur: _couleurSelectionnee,
                    epaisseur: _epaisseurPinceau,
                  ));
                });
              },
              child: CustomPaint(
                painter: PeintreDessin(points: _points),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(widget.cheminImage)),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Outils
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              children: [
                // Outils dessin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: () {
                        if (_points.isNotEmpty) {
                          setState(() {
                            _points.removeLast();
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _points.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: () {
                        _afficherSelecteurCouleur();
                      },
                    ),
                    Slider(
                      value: _epaisseurPinceau,
                      min: 1,
                      max: 20,
                      onChanged: (value) {
                        setState(() {
                          _epaisseurPinceau = value;
                        });
                      },
                    ),
                  ],
                ),

                // Zone annotations texte
                TextField(
                  controller: _controleurAnnotations,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter des annotations...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _afficherSelecteurCouleur() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _couleurSelectionnee,
            onColorChanged: (color) {
              setState(() {
                _couleurSelectionnee = color;
              });
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _sauvegarder() {
    // TODO: Sauvegarder les annotations et dessins
    Navigator.pop(context);
  }
}

class DessinPoint {
  final Offset point;
  final Color couleur;
  final double epaisseur;

  DessinPoint({
    required this.point,
    required this.couleur,
    required this.epaisseur,
  });
}

class PeintreDessin extends CustomPainter {
  final List<DessinPoint> points;

  PeintreDessin({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      paint.color = points[i].couleur;
      paint.strokeWidth = points[i].epaisseur;

      canvas.drawLine(points[i].point, points[i + 1].point, paint);
        }

    // Dessiner les points individuels
    for (var point in points) {
      paint.color = point.couleur;
      paint.strokeWidth = point.epaisseur;
      canvas.drawCircle(point.point, point.epaisseur / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}