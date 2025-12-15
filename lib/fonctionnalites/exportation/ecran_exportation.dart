import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../modeles/modele_media.dart';
import '../../services/service_base_donnees.dart';
import 'generateur_pdf.dart';

class EcranExportation extends StatefulWidget {
  final ElementMedia? media;

  const EcranExportation({super.key, this.media});

  @override
  State<EcranExportation> createState() => _EcranExportationState();
}

class _EcranExportationState extends State<EcranExportation> {
  final ServiceBaseDeDonnees _serviceBD = ServiceBaseDeDonnees();
  List<ElementMedia> _mediasSelectionnes = [];
  List<ElementMedia> _tousMedias = [];
  String _formatExport = 'PDF';
  final List<String> _formats = ['PDF', 'JPG', 'ZIP'];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
  }

  Future<void> _initialiserDonnees() async {
    _tousMedias = await _serviceBD.obtenirTousMedias();
    if (widget.media != null) {
      _mediasSelectionnes.add(widget.media!);
    }
    setState(() {
      _chargementEnCours = false;
    });
  }

  Future<void> _exporter() async {
    if (_mediasSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sélectionnez au moins un média'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
      return;
    }

    try {
      if (_formatExport == 'PDF') {
        final String cheminPDF = await GenerateurPDF.genererPDF(_mediasSelectionnes);
        await Share.shareFiles([cheminPDF], text: 'Export depuis SilicCapture');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF généré avec succès'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFA8C3A1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFC57B57),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportation'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: const Color(0xFFA8C3A1)),
            onPressed: _exporter,
          ),
        ],
      ),
      body: _chargementEnCours
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFA8C3A1),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Format d\'export',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6F7D8C),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 12,
                    children: _formats.map((format) {
                      bool isSelected = _formatExport == format;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _formatExport = format;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFA8C3A1).withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFA8C3A1)
                                  : const Color(0xFF6F7D8C).withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: const Color(0xFFA8C3A1).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              )
                            ]
                                : [],
                          ),
                          child: Text(
                            format,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFFA8C3A1)
                                  : const Color(0xFF6F7D8C),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_mediasSelectionnes.length} sélectionné(s)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6F7D8C),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _mediasSelectionnes = List.from(_tousMedias);
                            });
                          },
                          child: Text(
                            'Tout',
                            style: TextStyle(
                              color: const Color(0xFFA8C3A1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _mediasSelectionnes.clear();
                            });
                          },
                          child: Text(
                            'Aucun',
                            style: TextStyle(
                              color: const Color(0xFFC57B57),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tousMedias.length,
              itemBuilder: (context, index) {
                ElementMedia media = _tousMedias[index];
                bool estSelectionne = _mediasSelectionnes.contains(media);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: estSelectionne
                        ? [
                      BoxShadow(
                        color: const Color(0xFFA8C3A1).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ]
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(
                      color: estSelectionne
                          ? const Color(0xFFA8C3A1)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        if (estSelectionne) {
                          _mediasSelectionnes.remove(media);
                        } else {
                          _mediasSelectionnes.add(media);
                        }
                      });
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFFF7F3EF),
                        image: media.type == 'image'
                            ? DecorationImage(
                          image: AssetImage(media.cheminLocal),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: media.type != 'image'
                          ? Icon(
                        Icons.insert_drive_file,
                        color: const Color(0xFF6F7D8C),
                      )
                          : null,
                    ),
                    title: Text(
                      'Image ${media.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6F7D8C),
                      ),
                    ),
                    subtitle: Text(
                      media.dateCreation.toString().substring(0, 10),
                      style: TextStyle(
                        color: const Color(0xFF6F7D8C).withOpacity(0.6),
                      ),
                    ),
                    trailing: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: estSelectionne
                            ? const Color(0xFFA8C3A1)
                            : Colors.transparent,
                        border: Border.all(
                          color: estSelectionne
                              ? const Color(0xFFA8C3A1)
                              : const Color(0xFF6F7D8C).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: estSelectionne
                          ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}