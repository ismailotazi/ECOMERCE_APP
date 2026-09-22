import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static late SharedPreferences _prefs;

  static const _keyOrderNotifications = 'orderNotifications';
  static const _keyUserNotifications = 'userNotifications';
  static const _keyLowStockNotifications = 'lowStockNotifications';
  static const _keyPromotionNotifications = 'promotionNotifications';

  static const _keyNotificationSound = 'notificationSound';
  static const _keyNotificationVibration = 'notificationVibration';

  //==========================
  // INITIALIZE
  //==========================

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //==========================
  // ORDER NOTIFICATIONS
  //==========================

  static Future<void> setOrderNotifications(bool value) async {
    await _prefs.setBool(_keyOrderNotifications, value);
  }

  static bool getOrderNotifications() {
    return _prefs.getBool(_keyOrderNotifications) ?? true;
  }

  //==========================
  // USER NOTIFICATIONS
  //==========================

  static Future<void> setUserNotifications(bool value) async {
    await _prefs.setBool(_keyUserNotifications, value);
  }

  static bool getUserNotifications() {
    return _prefs.getBool(_keyUserNotifications) ?? true;
  }

  //==========================
  // LOW STOCK
  //==========================

  static Future<void> setLowStockNotifications(bool value) async {
    await _prefs.setBool(_keyLowStockNotifications, value);
  }

  static bool getLowStockNotifications() {
    return _prefs.getBool(_keyLowStockNotifications) ?? true;
  }

  //==========================
  // PROMOTIONS
  //==========================

  static Future<void> setPromotionNotifications(bool value) async {
    await _prefs.setBool(_keyPromotionNotifications, value);
  }

  static bool getPromotionNotifications() {
    return _prefs.getBool(_keyPromotionNotifications) ?? false;
  }

  //==========================
  // SOUND
  //==========================

  static Future<void> setNotificationSound(bool value) async {
    await _prefs.setBool(_keyNotificationSound, value);
  }

  static bool getNotificationSound() {
    return _prefs.getBool(_keyNotificationSound) ?? true;
  }

  //==========================
  // VIBRATION
  //==========================

  static Future<void> setNotificationVibration(bool value) async {
    await _prefs.setBool(_keyNotificationVibration, value);
  }

  static bool getNotificationVibration() {
    return _prefs.getBool(_keyNotificationVibration) ?? true;
  }

  //==========================
  // CLEAR
  //==========================

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
