// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.notifications),
//         leading: const CustomBackButton(),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),

//               CircleAvatar(
//                 radius: 45,
//                 backgroundColor: Colors.orange.withValues(alpha: .12),
//                 child: const Icon(
//                   Icons.notifications_active,
//                   size: 45,
//                   color: Colors.orange,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Text(
//                 t.notifications,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 8),

//               Text(
//                 t.manageNotificationsDescription,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey, fontSize: 15),
//               ),

//               const SizedBox(height: 30),

//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: SwitchListTile(
//                   value: true,
//                   onChanged: (_) {},
//                   secondary: const Icon(Icons.shopping_bag_outlined),
//                   title: Text(t.orderUpdates),
//                   subtitle: Text(t.orderUpdatesDescription),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: SwitchListTile(
//                   value: true,
//                   onChanged: (_) {},
//                   secondary: const Icon(Icons.local_offer_outlined),
//                   title: Text(t.offersDiscounts),
//                   subtitle: Text(t.offersDiscountsDescription),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: SwitchListTile(
//                   value: false,
//                   onChanged: (_) {},
//                   secondary: const Icon(Icons.campaign_outlined),
//                   title: Text(t.promotions),
//                   subtitle: Text(t.promotionsDescription),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: SwitchListTile(
//                   value: true,
//                   onChanged: (_) {},
//                   secondary: const Icon(Icons.email_outlined),
//                   title: Text(t.emailNotifications),
//                   subtitle: Text(t.emailNotificationsDescription),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(18),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.blue),
//                       SizedBox(width: 12),
//                       Expanded(child: Text(t.pushNotificationsFutureUpdate)),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
