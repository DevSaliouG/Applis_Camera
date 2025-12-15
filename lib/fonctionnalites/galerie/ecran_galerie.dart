import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:si_capture_2/fonctionnalites/appareil_photo/ecran_appareil_photo.dart';
import 'package:si_capture_2/fonctionnalites/parametres/ecran_parametres.dart';
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
  final ScrollController _scrollController = ScrollController();

  // Données
  List<ElementMedia> _medias = [];
  List<ElementMedia> _tousMedias = [];
  final List<ElementMedia> _mediasSelectionnes = [];

  // Filtres
  String _dossierActuel = 'Tous';
  final List<String> _dossiers = ['Tous', 'Images', 'Videos', 'Favoris'];

  // États
  bool _chargementEnCours = true;
  bool _modeSelection = false;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showAppBar = _scrollController.offset <= 100;
    });
  }

  Future<void> _initialiserDonnees() async {
    final bibliotheques = await _serviceStockage.obtenirBibliotheques();
    if (mounted) {
      setState(() {
        for (var biblio in bibliotheques) {
          if (!_dossiers.contains(biblio)) _dossiers.add(biblio);
        }
      });
    }
    await _chargerMedias();
  }

  Future<void> _chargerMedias() async {
    setState(() => _chargementEnCours = true);

    try {
      final medias = await _serviceStockage.chargerMedias();

      if (mounted) {
        setState(() {
          _tousMedias = medias;
          _filtrerMedias();
          _chargementEnCours = false;
        });
      }
    } catch (e) {
      print('Erreur chargement: $e');
      if (mounted) setState(() => _chargementEnCours = false);
    }
  }

  void _filtrerMedias() {
    setState(() {
      if (_dossierActuel == 'Tous') {
        _medias = List.from(_tousMedias);
      } else if (_dossierActuel == 'Favoris') {
        _medias = _tousMedias.where((m) => m.estFavori).toList();
      } else if (_dossierActuel == 'Images') {
        _medias = _tousMedias.where((m) => m.type == 'image').toList();
      } else if (_dossierActuel == 'Videos') {
        _medias = _tousMedias.where((m) => m.type == 'video').toList();
      } else {
        _medias =
            _tousMedias.where((m) => m.dossier == _dossierActuel).toList();
      }

      _medias.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    });
  }

  void _basculerSelection(ElementMedia media) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_mediasSelectionnes.contains(media)) {
        _mediasSelectionnes.remove(media);
        if (_mediasSelectionnes.isEmpty) _modeSelection = false;
      } else {
        _mediasSelectionnes.add(media);
      }
    });
  }

  void _activerModeSelection(ElementMedia media) {
    HapticFeedback.mediumImpact();
    setState(() {
      _modeSelection = true;
      _mediasSelectionnes.add(media);
    });
  }

  void _quitterModeSelection() {
    setState(() {
      _modeSelection = false;
      _mediasSelectionnes.clear();
    });
  }

  Future<void> _supprimerSelection() async {
    final count = _mediasSelectionnes.length;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDeleteConfirmation(context, count),
    );

    if (result == true) {
      for (var media in _mediasSelectionnes) {
        if (media.id != null) {
          await _serviceStockage.supprimerMedia(media.id!);
        }
      }
      _quitterModeSelection();
      _chargerMedias();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$count élément${count > 1 ? 's' : ''} supprimé${count > 1 ? 's' : ''}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildDeleteConfirmation(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.delete_outline_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Supprimer $count élément${count > 1 ? 's' : ''} ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Cette action est irréversible. Les éléments seront définitivement supprimés.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'ANNULER',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 56,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    'SUPPRIMER',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _ouvrirMedia(ElementMedia media) {
    if (_modeSelection) {
      _basculerSelection(media);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EcranDetailMedia(media: media),
        ),
      ).then((_) => _chargerMedias());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // L'AppBar est maintenant dans le Scaffold, pas dans un Stack
      appBar: _modeSelection || _showAppBar
          ? _buildAppBar(context, colorScheme)
          : null,
      body: _buildBody(context, colorScheme),
      // La barre d'actions de sélection est maintenant un bottomSheet
      bottomSheet:
          _modeSelection ? _buildSelectionActions(context, colorScheme) : null,
    );
  }

  PreferredSizeWidget? _buildAppBar(
      BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        _modeSelection
            ? '${_mediasSelectionnes.length} sélectionné${_mediasSelectionnes.length > 1 ? 's' : ''}'
            : 'Galerie',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          _modeSelection ? Icons.close_rounded : Icons.arrow_back_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: _modeSelection
            ? _quitterModeSelection
            : () => Navigator.pop(context),
      ),
      actions: _buildAppBarActions(context, colorScheme),
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context, ColorScheme colorScheme) {
    if (_modeSelection) {
      return [
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: colorScheme.error,
          ),
          onPressed:
              _mediasSelectionnes.isNotEmpty ? _supprimerSelection : null,
        ),
        IconButton(
          icon: Icon(
            Icons.favorite_border_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: _mediasSelectionnes.isNotEmpty
              ? () {
                  // TODO: Marquer comme favori
                  _quitterModeSelection();
                }
              : null,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            showSearch(
              context: context,
              delegate: RechercheMediaDelegate(_tousMedias),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => _showGalleryOptionsMenu(context),
        ),
      ];
    }
  }

  void _showGalleryOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Titre du menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Option Paramètres
              _buildMenuOption(
                context,
                icon: Icons.settings_rounded,
                title: 'Paramètres',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EcranParametres(),
                    ),
                  );
                },
              ),

              // Option Appareil photo
              _buildMenuOption(
                context,
                icon: Icons.camera_alt_rounded,
                title: 'Appareil photo',
                onTap: () {
                  Navigator.pop(context);
                  // Naviguer vers l'appareil photo (index 0 dans main.dart)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EcranAppareilPhoto(),
                    ),
                  );
                },
              ),

              // Option Tri
              _buildMenuOption(
                context,
                icon: Icons.sort_rounded,
                title: 'Trier par date',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implémenter le tri
                  _trierParDate();
                },
              ),

              // Option Statistiques
              _buildMenuOption(
                context,
                icon: Icons.analytics_rounded,
                title: 'Statistiques',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Écran statistiques
                  _afficherStatistiques();
                },
              ),

              const SizedBox(height: 16),

              // Bouton Fermer
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('FERMER'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

// 4. Méthodes à implémenter (placeholders)
  void _trierParDate() {
    // TODO: Implémenter le tri par date
    setState(() {
      _medias.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    });
  }

  void _afficherStatistiques() {
    // TODO: Implémenter l'affichage des statistiques
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: Text(
          '${_medias.length} médias\n'
              '${_medias.where((m) => m.type == 'image').length} photos\n'
              '${_medias.where((m) => m.type == 'video').length} vidéos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colorScheme) {
    if (_chargementEnCours) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des médias...',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_medias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun média',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par capturer quelques photos',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barre de filtres fixe (pas dans un Sliver)
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _dossiers.map((dossier) {
                final isSelected = _dossierActuel == dossier;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      dossier,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _dossierActuel = dossier;
                        _filtrerMedias();
                      });
                    },
                    backgroundColor: colorScheme.surfaceVariant,
                    selectedColor: colorScheme.primary,
                    checkmarkColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Grille des médias avec ListView normale
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: _medias.length,
            itemBuilder: (context, index) {
              final media = _medias[index];
              final isSelected = _mediasSelectionnes.contains(media);

              return GestureDetector(
                onTap: () => _ouvrirMedia(media),
                onLongPress: () => _activerModeSelection(media),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primary,
                            width: 3,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Carte média
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(isSelected ? 9 : 12),
                        child: CarteMedia(media: media),
                      ),

                      // Overlay de sélection
                      if (_modeSelection)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.circular(isSelected ? 9 : 12),
                            ),
                          ),
                        ),

                      // Checkbox de sélection
                      if (_modeSelection)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),

                      // Indicateur vidéo
                      if (media.type == 'video')
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),

                      // Indicateur favori
                      if (media.estFavori)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildSelectionActions(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Icons.share_rounded,
              label: 'Partager',
              onPressed: _mediasSelectionnes.isNotEmpty
                  ? () {
                      // TODO: Partage
                      _quitterModeSelection();
                    }
                  : null,
            ),
            _buildActionButton(
              context,
              icon: Icons.folder_rounded,
              label: 'Déplacer',
              onPressed: _mediasSelectionnes.isNotEmpty
                  ? () {
                      // TODO: Déplacer vers dossier
                      _quitterModeSelection();
                    }
                  : null,
            ),
            _buildActionButton(
              context,
              icon: Icons.edit_rounded,
              label: 'Modifier',
              onPressed: _mediasSelectionnes.length == 1
                  ? () {
                      // TODO: Éditer
                      _quitterModeSelection();
                    }
                  : null,
            ),
            _buildActionButton(
              context,
              icon: Icons.download_rounded,
              label: 'Télécharger',
              onPressed: _mediasSelectionnes.isNotEmpty
                  ? () {
                      // TODO: Télécharger
                      _quitterModeSelection();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: onPressed != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: onPressed != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

class RechercheMediaDelegate extends SearchDelegate<ElementMedia?> {
  final List<ElementMedia> medias;

  RechercheMediaDelegate(this.medias);

  @override
  String get searchFieldLabel => 'Rechercher photos et vidéos...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_rounded,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildResults(context);
  }

  Widget _buildRecentSearches(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recherches récentes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildRecentSearchItem(context, 'Photos de vacances'),
              _buildRecentSearchItem(context, 'Vidéos 2024'),
              _buildRecentSearchItem(context, 'Favoris'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String term) {
    return ListTile(
      leading: Icon(
        Icons.history_rounded,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(term),
      onTap: () {
        query = term;
        showResults(context);
      },
    );
  }

  Widget _buildResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (query.isEmpty) {
      return Center(
        child: Text(
          'Commencez à taper pour rechercher',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    final suggestions = medias.where((media) {
      final nomFichier = media.cheminLocal.split('/').last.toLowerCase();
      final annotations = (media.annotations ?? '').toLowerCase();
      final etiquettes = media.etiquettes.map((e) => e.toLowerCase()).toList();

      return nomFichier.contains(query.toLowerCase()) ||
          annotations.contains(query.toLowerCase()) ||
          etiquettes
              .any((etiquette) => etiquette.contains(query.toLowerCase()));
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec d\'autres mots-clés',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final media = suggestions[index];
        return GestureDetector(
          onTap: () {
            close(context, media);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EcranDetailMedia(media: media),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CarteMedia(media: media),
                if (media.type == 'video')
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
