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

  @override
  void initState() {
    super.initState();
    _chargerMedias();

    if (widget.media != null) {
      _mediasSelectionnes.add(widget.media!);
    }
  }

  Future<void> _chargerMedias() async {
    _tousMedias = await _serviceBD.obtenirTousMedias();
    setState(() {});
  }

  Future<void> _exporter() async {
    if (_mediasSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un média')),
      );
      return;
    }

    try {
      if (_formatExport == 'PDF') {
        final String cheminPDF = await GenerateurPDF.genererPDF(_mediasSelectionnes);

        // Partager le PDF
        await Share.shareFiles([cheminPDF], text: 'Export PDF depuis SilicCapture');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF généré avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur exportation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exporter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de format
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Format:'),
                const SizedBox(width: 16),
                ..._formats.map((format) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(format),
                      selected: _formatExport == format,
                      onSelected: (selected) {
                        setState(() {
                          _formatExport = format;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Liste des médias
          Expanded(
            child: ListView.builder(
              itemCount: _tousMedias.length,
              itemBuilder: (context, index) {
                ElementMedia media = _tousMedias[index];
                bool estSelectionne = _mediasSelectionnes.contains(media);

                return ListTile(
                  leading: Checkbox(
                    value: estSelectionne,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _mediasSelectionnes.add(media);
                        } else {
                          _mediasSelectionnes.remove(media);
                        }
                      });
                    },
                  ),
                  title: Text('Image ${media.id}'),
                  subtitle: Text(media.dateCreation.toString()),
                  trailing: const Icon(Icons.photo),
                );
              },
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mediasSelectionnes = List.from(_tousMedias);
                    });
                  },
                  icon: const Icon(Icons.select_all),
                  label: const Text('Tout sélectionner'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mediasSelectionnes.clear();
                    });
                  },
                  icon: const Icon(Icons.deselect),
                  label: const Text('Tout désélectionner'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}