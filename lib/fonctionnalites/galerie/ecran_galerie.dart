import 'package:flutter/material.dart';
import '../../modeles/modele_media.dart';
import '../../services/service_stockage_unifie.dart';
import '../../widgets/carte_media.dart';
import 'ecran_detail_media.dart';

class EcranGalerie extends StatefulWidget {
  const EcranGalerie({super.key});

  @override
  State<EcranGalerie> createState() => _EcranGalerieState();
}

class _EcranGalerieState extends State<EcranGalerie> {
  final ServiceStockageUnifie _serviceStockage = ServiceStockageUnifie();
  List<ElementMedia> _medias = [];
  List<ElementMedia> _tousMedias = []; // Stocker tous les médias pour la recherche
  String _dossierActuel = 'Tous';
  final List<String> _dossiers = ['Tous', 'Images', 'Videos', 'Documents', 'Favoris'];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
  }

  Future<void> _initialiserDonnees() async {
    // Charger d'abord les bibliothèques
    final bibliotheques = await _serviceStockage.obtenirBibliotheques();
    setState(() {
      _dossiers.addAll(bibliotheques.where((biblio) => !_dossiers.contains(biblio)));
    });

    // Puis charger les médias
    await _chargerMedias();
  }

  Future<void> _chargerMedias() async {
    setState(() {
      _chargementEnCours = true;
    });

    try {
      print(' Chargement des médias...');

      _tousMedias = await _serviceStockage.chargerMedias();

      print(' ${_tousMedias.length} médias chargés');

      setState(() {
        if (_dossierActuel == 'Tous') {
          _medias = _tousMedias;
        } else if (_dossierActuel == 'Favoris') {
          _medias = _tousMedias.where((m) => m.estFavori).toList();
        } else if (_dossierActuel == 'Images') {
          _medias = _tousMedias.where((m) => m.type == 'image').toList();
        } else if (_dossierActuel == 'Videos') {
          _medias = _tousMedias.where((m) => m.type == 'video').toList();
        } else if (_dossierActuel == 'Documents') {
          _medias = _tousMedias.where((m) => m.type == 'document').toList();
        } else {
          // C'est une bibliothèque personnalisée
          _medias = _tousMedias.where((m) => m.dossier == _dossierActuel).toList();
        }
        _chargementEnCours = false;
      });
    } catch (e) {
      print(' Erreur chargement médias: $e');
      setState(() {
        _medias = [];
        _tousMedias = [];
        _chargementEnCours = false;
      });
    }
  }

  void _changerDossier(String dossier) {
    setState(() {
      _dossierActuel = dossier;
    });
    _chargerMedias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _rechercherMedias();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _filtrerMedias();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de dossiers
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dossiers.length,
              itemBuilder: (context, index) {
                String dossier = _dossiers[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(dossier),
                    selected: _dossierActuel == dossier,
                    onSelected: (selected) => _changerDossier(dossier),
                  ),
                );
              },
            ),
          ),

          // Grille de médias
          Expanded(
            child: _chargementEnCours
                ? const Center(child: CircularProgressIndicator())
                : _medias.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun média'),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _medias.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _afficherDetailMedia(_medias[index]);
                  },
                  onLongPress: () {
                    _afficherOptionsMedia(_medias[index]);
                  },
                  child: CarteMedia(
                    media: _medias[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _afficherDialogNouveauDossier();
        },
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }

  void _afficherOptionsMedia(ElementMedia media) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _naviguerVersEditeur(media);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Ajouter à une bibliothèque'),
              onTap: () {
                Navigator.pop(context);
                _afficherDialogAjouterBibliotheque(media);
              },
            ),
            ListTile(
              leading: Icon(media.estFavori ? Icons.star : Icons.star_border),
              title: Text(media.estFavori ? 'Retirer des favoris' : 'Ajouter aux favoris'),
              onTap: () async {
                Navigator.pop(context);
                await _serviceStockage.mettreAJourFavori(media.id!, !media.estFavori);
                _chargerMedias();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(media.estFavori
                        ? ' Retiré des favoris'
                        : ' Ajouté aux favoris'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmerSuppression(media);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(ElementMedia media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce média ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (media.id != null) {
                try {
                  await _serviceStockage.supprimerMedia(media.id!);
                  _chargerMedias();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(' Média supprimé')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(' Erreur: $e')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _afficherDialogAjouterBibliotheque(ElementMedia media) async {
    final bibliotheques = await _serviceStockage.obtenirBibliotheques();
    final TextEditingController controleur = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter à une bibliothèque'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bibliotheques.isNotEmpty)
                    ...bibliotheques.map((biblio) => ListTile(
                      title: Text(biblio),
                      onTap: () async {
                        if (media.id != null) {
                          await _serviceStockage.ajouterMediaABibliotheque(media.id!, biblio);
                          _chargerMedias();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(' Média ajouté à $biblio')),
                          );
                          Navigator.pop(context);
                        }
                      },
                    )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controleur,
                    decoration: const InputDecoration(
                      hintText: 'Nouvelle bibliothèque',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (controleur.text.isNotEmpty) {
                if (media.id != null) {
                  await _serviceStockage.ajouterMediaABibliotheque(media.id!, controleur.text);
                  setState(() {
                    if (!_dossiers.contains(controleur.text)) {
                      _dossiers.add(controleur.text);
                    }
                  });
                  _chargerMedias();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(' Bibliothèque créée et média ajouté')),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Créer et ajouter'),
          ),
        ],
      ),
    );
  }

  void _afficherDialogNouveauDossier() {
    final TextEditingController controleur = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau dossier'),
        content: TextField(
          controller: controleur,
          decoration: const InputDecoration(
            hintText: 'Nom du dossier',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controleur.text.isNotEmpty && !_dossiers.contains(controleur.text)) {
                setState(() {
                  _dossiers.add(controleur.text);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(' Dossier "${controleur.text}" créé')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _rechercherMedias() {
    showSearch(
      context: context,
      delegate: _RechercheMediaDelegate(_tousMedias, (media) => _afficherDetailMedia(media), (media) => _afficherOptionsMedia(media)),
    );
  }

  void _filtrerMedias() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filtrer par', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Aujourd\'hui'),
                    selected: false,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      // TODO: Implémenter le filtrage par date
                    },
                  ),
                  FilterChip(
                    label: const Text('Cette semaine'),
                    selected: false,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      // TODO: Implémenter le filtrage par date
                    },
                  ),
                  FilterChip(
                    label: const Text('Favoris uniquement'),
                    selected: false,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      setState(() {
                        _dossierActuel = 'Favoris';
                      });
                      _chargerMedias();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _afficherDetailMedia(ElementMedia media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EcranDetailMedia(media: media),
      ),
    );
  }

  void _naviguerVersEditeur(ElementMedia media) {
    // TODO: Naviguer vers l'éditeur
    print('Naviguer vers éditeur: ${media.id}');
  }
}

class _RechercheMediaDelegate extends SearchDelegate {
  final List<ElementMedia> medias;
  final Function(ElementMedia) onTapMedia;
  final Function(ElementMedia) onLongPressMedia;

  _RechercheMediaDelegate(this.medias, this.onTapMedia, this.onLongPressMedia);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<ElementMedia> resultats = medias.where((media) {
      final nomFichier = media.cheminLocal.split('/').last.toLowerCase();
      final annotations = media.annotations?.toLowerCase() ?? '';
      final etiquettes = media.etiquettes.map((e) => e.toLowerCase()).toList();

      return nomFichier.contains(query.toLowerCase()) ||
          annotations.contains(query.toLowerCase()) ||
          etiquettes.any((etiquette) => etiquette.contains(query.toLowerCase()));
    }).toList();

    return _buildResultatsListe(resultats);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ElementMedia> suggestions = query.isEmpty
        ? []
        : medias.where((media) {
      final nomFichier = media.cheminLocal.split('/').last.toLowerCase();
      final annotations = media.annotations?.toLowerCase() ?? '';
      final etiquettes = media.etiquettes.map((e) => e.toLowerCase()).toList();

      return nomFichier.contains(query.toLowerCase()) ||
          annotations.contains(query.toLowerCase()) ||
          etiquettes.any((etiquette) => etiquette.contains(query.toLowerCase()));
    }).toList();

    return _buildResultatsListe(suggestions);
  }

  Widget _buildResultatsListe(List<ElementMedia> resultats) {
    if (resultats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucun résultat trouvé'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: resultats.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onTapMedia(resultats[index]);
            close(context, resultats[index]);
          },
          onLongPress: () {
            onLongPressMedia(resultats[index]);
          },
          child: CarteMedia(
            media: resultats[index],
          ),
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Rechercher des médias...';
}