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
  Color _couleurSelectionnee = const Color(0xFFA8C3A1);
  double _epaisseurPinceau = 3.0;
  final List<DessinPoint> _points = [];
  final TextEditingController _controleurAnnotations = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éditeur'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFA8C3A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.save_outlined, color: const Color(0xFFA8C3A1), size: 22),
              onPressed: _sauvegarder,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de dessin
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
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(widget.cheminImage)),
                            fit: BoxFit.contain,
                          ),
                          color: const Color(0xFFF7F3EF),
                        ),
                      ),
                      CustomPaint(
                        painter: PeintreDessin(points: _points),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Outils
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
              children: [
                // Outils dessin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.undo_outlined, color: const Color(0xFF6F7D8C)),
                        onPressed: () {
                          if (_points.isNotEmpty) {
                            setState(() {
                              _points.removeLast();
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, color: const Color(0xFFC57B57)),
                        onPressed: () {
                          setState(() {
                            _points.clear();
                          });
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _afficherSelecteurCouleur,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _couleurSelectionnee.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _couleurSelectionnee,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _couleurSelectionnee,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _epaisseurPinceau,
                        min: 1,
                        max: 20,
                        onChanged: (value) {
                          setState(() {
                            _epaisseurPinceau = value;
                          });
                        },
                        activeColor: const Color(0xFFA8C3A1),
                        inactiveColor: const Color(0xFFF7F3EF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Zone annotations texte
                TextField(
                  controller: _controleurAnnotations,
                  decoration: InputDecoration(
                    hintText: 'Ajouter des annotations...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF6F7D8C).withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: const Color(0xFF6F7D8C).withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFFA8C3A1),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F3EF),
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
      barrierColor: Colors.transparent,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir une couleur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6F7D8C),
                ),
              ),
              const SizedBox(height: 24),
              ColorPicker(
                pickerColor: _couleurSelectionnee,
                onColorChanged: (color) {
                  setState(() {
                    _couleurSelectionnee = color;
                  });
                },
                showLabel: false,
                pickerAreaHeightPercent: 0.5,
                pickerAreaBorderRadius: BorderRadius.circular(20),
                enableAlpha: false,
                displayThumbColor: true,
                portraitOnly: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: const Color(0xFF6F7D8C).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: const Color(0xFF6F7D8C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: const Color(0xFFA8C3A1),
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sauvegarder() {
    // TODO: Sauvegarder les annotations et dessins
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Modifications sauvegardées'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFFA8C3A1),
      ),
    );
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
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

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