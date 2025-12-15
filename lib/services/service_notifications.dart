import 'package:flutter/material.dart';

class ServiceNotifications extends ChangeNotifier {
  static final ServiceNotifications _instance = ServiceNotifications._internal();
  factory ServiceNotifications() => _instance;
  ServiceNotifications._internal();

  bool _refreshGallery = false;
  bool _newCaptureAvailable = false;
  int _newCaptureCount = 0;

  bool get shouldRefreshGallery => _refreshGallery;
  bool get newCaptureAvailable => _newCaptureAvailable;
  int get newCaptureCount => _newCaptureCount;

  // Notifier qu'une capture a été faite
  void notifyCaptureMade() {
    _refreshGallery = true;
    _newCaptureAvailable = true;
    _newCaptureCount++;
    notifyListeners();

    print(' Capture notifiée - Rafraîchissement galerie demandé');
  }

  // Notifier que la galerie a été rafraîchie
  void galleryRefreshed() {
    _refreshGallery = false;
    _newCaptureAvailable = false;
    notifyListeners();
  }

  // Notifier qu'un média a été supprimé
  void notifyMediaDeleted() {
    _refreshGallery = true;
    notifyListeners();
  }

  // Réinitialiser le compteur
  void resetCounter() {
    _newCaptureCount = 0;
    notifyListeners();
  }
}