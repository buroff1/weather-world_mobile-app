import 'package:flutter/material.dart'; // Import Flutter material package for UI components

// Define UnitProvider class which extends ChangeNotifier
class UnitProvider with ChangeNotifier {
  String _units =
      'metric'; // Private variable to store current unit ('metric' or 'imperial')

  // Getter to access the current unit
  String get units => _units;

  // Method to toggle the unit between 'metric' and 'imperial'
  void toggleUnits() {
    _units = _units == 'metric' ? 'imperial' : 'metric'; // Toggle the unit
    notifyListeners(); // Notify listeners about the change
  }
}
