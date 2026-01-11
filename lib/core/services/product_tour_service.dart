import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing product tour state and preferences
/// 
/// Handles persistence of tour completion status and user preferences
/// for showing/hiding the onboarding product tour.
class ProductTourService {
  static const String _keyTourCompleted = 'product_tour_completed';
  static const String _keyTourEnabled = 'product_tour_enabled';
  
  /// Check if the product tour should be shown
  /// 
  /// Returns true if:
  /// - Tour hasn't been completed/skipped yet
  /// - User hasn't disabled it in settings
  static Future<bool> shouldShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_keyTourCompleted) ?? false;
    final enabled = prefs.getBool(_keyTourEnabled) ?? true;
    return !completed && enabled;
  }
  
  /// Check if user has completed or skipped the tour
  static Future<bool> hasCompletedTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTourCompleted) ?? false;
  }
  
  /// Mark the tour as completed (or skipped)
  static Future<void> setTourCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourCompleted, completed);
  }
  
  /// Check if tour is enabled in settings
  static Future<bool> isTourEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTourEnabled) ?? true;
  }
  
  /// Enable or disable the tour from settings
  static Future<void> setTourEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourEnabled, enabled);
  }
  
  /// Reset the tour to show again (for "Restart Tour" button)
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTourCompleted, false);
    await prefs.setBool(_keyTourEnabled, true);
  }
}
