import 'package:flutter/material.dart';

class NavigationManager extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void navigateTo(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void navigateToCamera() {
    _currentIndex = 0;
    notifyListeners();
  }

  void navigateToGallery() {
    _currentIndex = 1;
    notifyListeners();
  }

  void navigateToSettings() {
    _currentIndex = 2;
    notifyListeners();
  }
}