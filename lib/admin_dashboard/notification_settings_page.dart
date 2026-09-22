// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationSettingsPage extends StatefulWidget {
//   const NotificationSettingsPage({super.key});

//   @override
//   State<NotificationSettingsPage> createState() =>
//       _NotificationSettingsPageState();
// }

// class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
//   bool enableNotifications = true;
//   bool orderNotifications = true;
//   bool userNotifications = true;
//   bool lowStockNotifications = true;
//   bool promotionNotifications = false;
//   bool sound = true;
//   bool vibration = true;

//   @override
//   void initState() {
//     super.initState();
//     loadSettings();
//   }

//   Future<void> loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();

//     setState(() {
//       enableNotifications = prefs.getBool("enableNotifications") ?? true;

//       orderNotifications = prefs.getBool("orderNotifications") ?? true;

//       userNotifications = prefs.getBool("userNotifications") ?? true;

//       lowStockNotifications = prefs.getBool("lowStockNotifications") ?? true;

//       promotionNotifications = prefs.getBool("promotionNotifications") ?? false;

//       sound = prefs.getBool("notificationSound") ?? true;

//       vibration = prefs.getBool("notificationVibration") ?? true;
//     });
//   }

//   Future<void> saveBool(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(t.notificationSettings),
//         leading: const CustomBackButton(),
//       ),

//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             Text(
//               t.notifications,
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               t.chooseNotifications,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),

//             const SizedBox(height: 28),

//             buildSwitchTile(
//               title: t.enableNotifications,
//               subtitle: t.turnAllNotificationsOnOrOff,
//               icon: Icons.notifications_active_rounded,
//               color: Theme.of(context).colorScheme.primary,
//               value: enableNotifications,
//               onChanged: (value) async {
//                 setState(() {
//                   enableNotifications = value;

//                   if (!value) {
//                     orderNotifications = false;
//                     userNotifications = false;
//                     lowStockNotifications = false;
//                     promotionNotifications = false;
//                     sound = false;
//                     vibration = false;
//                   }
//                 });
//                 await saveBool("enableNotifications", value);
//               },
//             ),

//             buildSwitchTile(
//               title: t.newOrders,
//               subtitle: t.receiveNotificationsForNewOrders,
//               icon: Icons.shopping_bag_rounded,
//               color: Theme.of(context).colorScheme.primary,
//               value: orderNotifications,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         orderNotifications = value;
//                       });

//                       await saveBool("orderNotifications", value);
//                     }
//                   : null,
//             ),

//             buildSwitchTile(
//               title: t.newUsers,
//               subtitle: t.notifyWhenCustomerRegisters,
//               icon: Icons.person_add_alt_1_rounded,
//               color: Theme.of(context).colorScheme.primary,
//               value: userNotifications,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         userNotifications = value;
//                       });

//                       await saveBool("userNotifications", value);
//                     }
//                   : null,
//             ),

//             buildSwitchTile(
//               title: t.lowStock,
//               subtitle: t.alertWhenProductsRunningOut,
//               icon: Icons.inventory_2_rounded,
//               color: Theme.of(context).colorScheme.error,
//               value: lowStockNotifications,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         lowStockNotifications = value;
//                       });

//                       await saveBool("lowStockNotifications", value);
//                     }
//                   : null,
//             ),

//             buildSwitchTile(
//               title: t.promotions,
//               subtitle: t.marketingPromotionalNotifications,
//               icon: Icons.local_offer_rounded,
//               color: AppColors.success,
//               value: promotionNotifications,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         promotionNotifications = value;
//                       });

//                       await saveBool("promotionNotifications", value);
//                     }
//                   : null,
//             ),
//             buildSwitchTile(
//               title: t.sound,
//               subtitle: t.playSoundWhenReceivingNotifications,
//               icon: Icons.volume_up_rounded,
//               color: Theme.of(context).colorScheme.secondary,
//               value: sound,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         sound = value;
//                       });

//                       await saveBool("notificationSound", value);
//                     }
//                   : null,
//             ),

//             buildSwitchTile(
//               title: t.vibration,
//               subtitle: t.vibrateWhenReceivingNotifications,
//               icon: Icons.vibration_rounded,
//               color: Theme.of(context).colorScheme.secondary,
//               value: vibration,
//               onChanged: enableNotifications
//                   ? (value) async {
//                       setState(() {
//                         vibration = value;
//                       });

//                       await saveBool("notificationVibration", value);
//                     }
//                   : null,
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildSwitchTile({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required bool value,
//     ValueChanged<bool>? onChanged,
//   }) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: .05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SwitchListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

//         secondary: CircleAvatar(
//           radius: 22,
//           backgroundColor: color.withValues(alpha: .12),
//           child: Icon(icon, color: color),
//         ),

//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),

//         subtitle: Text(
//           subtitle,
//           style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
//         ),

//         value: value,

//         activeThumbColor: theme.colorScheme.primary,

//         onChanged: onChanged,
//       ),
//     );
//   }
// }
