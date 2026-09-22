import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:ecomerce_app/theme/custom_back_button.dart';

class BackupDatabasePage extends StatefulWidget {
  const BackupDatabasePage({super.key});

  @override
  State<BackupDatabasePage> createState() => _BackupDatabasePageState();
}

class _BackupDatabasePageState extends State<BackupDatabasePage> {
  bool isBackingUp = false;
  double progress = 0;

  final List<String> collections = [
    "users",
    "products",
    "orders",
    "banks",
    "favorites",
  ];

  final Set<String> selectedCollections = {
    "users",
    "products",
    "orders",
    "banks",
    "favorites",
  };

  Future<void> createBackup() async {
    final t = AppLocalizations.of(context)!;
    if (selectedCollections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.pleaseSelectAtLeastOneCollection)),
      );
      return;
    }

    setState(() {
      isBackingUp = true;
      progress = 0;
    });

    try {
      final Map<String, dynamic> backup = {
        "backupVersion": "1.0",
        "createdAt": DateTime.now().toIso8601String(),
        "collections": <String, dynamic>{},
      };

      int completed = 0;

      for (final collectionName in selectedCollections) {
        final snapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .get();

        final List<Map<String, dynamic>> documents = [];

        for (final doc in snapshot.docs) {
          documents.add({
            "id": doc.id,
            "data": _convertFirestoreData(doc.data()),
          });
        }

        backup["collections"][collectionName] = documents;

        completed++;

        if (mounted) {
          setState(() {
            progress = completed / selectedCollections.length;
          });
        }
      }

      final jsonString = const JsonEncoder.withIndent("  ").convert(backup);

      if (!mounted) return;

      final path = await FilePicker.platform.saveFile(
        dialogTitle: t.saveDatabaseBackup,
        fileName:
            "database_backup_${DateTime.now().millisecondsSinceEpoch}.json",
        type: FileType.custom,
        allowedExtensions: ["json"],
        bytes: utf8.encode(jsonString),
      );

      if (!mounted) return;

      if (path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.backupCancelled)));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.databaseBackupSavedSuccessfully),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.backupFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBackingUp = false;
        });
      }
    }
  }

  Future<void> restoreBackup() async {
    final t = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: t.selectDatabaseBackup,
        type: FileType.custom,
        allowedExtensions: ["json"],
        withData: true,
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.bytes == null) {
        throw Exception(t.unableToReadSelectedFile);
      }

      final jsonString = utf8.decode(file.bytes!);

      final Map<String, dynamic> backup = jsonDecode(jsonString);

      if (backup["backupVersion"] == null ||
          backup["collections"] == null ||
          backup["collections"] is! Map) {
        throw Exception(t.invalidBackupFile);
      }

      final collections = Map<String, dynamic>.from(backup["collections"]);

      int totalDocuments = 0;

      for (final collectionData in collections.values) {
        if (collectionData is List) {
          totalDocuments += collectionData.length;
        }
      }

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return AlertDialog(
            title: Text(t.restoreDatabase),
            content: Text(
              "${t.backupContains}\n\n"
              "${t.collectionsCount(collections.length)}\n"
              "${t.documentsCount(totalDocuments)}\n\n"
              "${t.existingDocumentsWillBeOverwritten}\n\n"
              "${t.doYouWantToContinue}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(t.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(t.restore),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      setState(() {
        isBackingUp = true;
        progress = 0;
      });

      int completed = 0;

      for (final entry in collections.entries) {
        final collectionName = entry.key;
        final documents = entry.value;

        if (documents is! List) continue;

        for (final document in documents) {
          if (document is! Map) continue;

          final documentId = document["id"]?.toString();

          if (documentId == null || documentId.isEmpty) {
            continue;
          }

          final rawData = document["data"];

          if (rawData is! Map) continue;

          final data = _restoreFirestoreData(
            Map<String, dynamic>.from(rawData),
          );

          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(documentId)
              .set(data, SetOptions(merge: false));

          completed++;

          if (mounted && totalDocuments > 0) {
            setState(() {
              progress = completed / totalDocuments;
            });
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.databaseRestoredSuccessfully(completed)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.restoreFailed(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBackingUp = false;
          progress = 0;
        });
      }
    }
  }

  dynamic _restoreFirestoreData(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      if (map["_type"] == "timestamp") {
        return Timestamp.fromDate(DateTime.parse(map["value"].toString()));
      }

      if (map["_type"] == "geopoint") {
        return GeoPoint(
          (map["latitude"] as num).toDouble(),
          (map["longitude"] as num).toDouble(),
        );
      }

      if (map["_type"] == "reference") {
        return FirebaseFirestore.instance.doc(map["path"].toString());
      }

      return map.map(
        (key, value) => MapEntry(key, _restoreFirestoreData(value)),
      );
    }

    if (value is List) {
      return value.map(_restoreFirestoreData).toList();
    }

    return value;
  }

  dynamic _convertFirestoreData(dynamic value) {
    if (value is Timestamp) {
      return {"_type": "timestamp", "value": value.toDate().toIso8601String()};
    }

    if (value is GeoPoint) {
      return {
        "_type": "geopoint",
        "latitude": value.latitude,
        "longitude": value.longitude,
      };
    }

    if (value is DocumentReference) {
      return {"_type": "reference", "path": value.path};
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), _convertFirestoreData(value)),
      );
    }

    if (value is List) {
      return value.map(_convertFirestoreData).toList();
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 28.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.backupDatabase),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              children: [
                SizedBox(height: isDesktop ? 8 : 4),

                Center(
                  child: Container(
                    width: isDesktop ? 88 : 76,
                    height: isDesktop ? 88 : 76,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.backup_rounded,
                      size: isDesktop ? 48 : 42,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 20 : 16),

                Center(
                  child: Text(
                    t.databaseBackup,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 28 : null,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      t.createBackupDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 32 : 30),

                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 26 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.selectData,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          t.chooseCollectionsToInclude,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...collections.map((collection) {
                          final selected = selectedCollections.contains(
                            collection,
                          );

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selected,
                            title: Text(switch (collection) {
                              "users" => t.users,
                              "products" => t.products,
                              "orders" => t.orders,
                              "banks" => t.paymentBanks,
                              "favorites" => t.favorites,
                              _ => collection,
                            }),
                            secondary: Icon(_collectionIcon(collection)),
                            onChanged: isBackingUp
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedCollections.add(collection);
                                      } else {
                                        selectedCollections.remove(collection);
                                      }
                                    });
                                  },
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 24 : 20),

                if (isBackingUp) ...[
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    t.completedPercentage((progress * 100).toInt()),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 58 : 55,
                  child: ElevatedButton.icon(
                    onPressed: isBackingUp ? null : createBackup,
                    icon: isBackingUp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_rounded),
                    label: Text(
                      isBackingUp ? t.creatingBackup : t.createBackup,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: isDesktop ? 58 : 55,
                  child: OutlinedButton.icon(
                    onPressed: isBackingUp ? null : restoreBackup,
                    icon: const Icon(Icons.restore_rounded),
                    label: Text(
                      t.restoreBackup,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 24 : 20),

                Container(
                  padding: EdgeInsets.all(isDesktop ? 18 : 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.backupFirestoreOnly,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isDesktop ? 12 : 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _collectionIcon(String collection) {
    switch (collection) {
      case "users":
        return Icons.people_outline_rounded;
      case "products":
        return Icons.inventory_2_outlined;
      case "orders":
        return Icons.shopping_bag_outlined;
      case "banks":
        return Icons.account_balance_outlined;
      case "favorites":
        return Icons.favorite_border_rounded;
      default:
        return Icons.storage_rounded;
    }
  }
}
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// import 'package:ecomerce_app/theme/custom_back_button.dart';

// class BackupDatabasePage extends StatefulWidget {
//   const BackupDatabasePage({super.key});

//   @override
//   State<BackupDatabasePage> createState() => _BackupDatabasePageState();
// }

// class _BackupDatabasePageState extends State<BackupDatabasePage> {
//   bool isBackingUp = false;
//   double progress = 0;

//   final List<String> collections = [
//     "users",
//     "products",
//     "orders",
//     "banks",
//     "favorites",
//   ];

//   final Set<String> selectedCollections = {
//     "users",
//     "products",
//     "orders",
//     "banks",
//     "favorites",
//   };

//   Future<void> createBackup() async {
//     final t = AppLocalizations.of(context)!;
//     if (selectedCollections.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(t.pleaseSelectAtLeastOneCollection)),
//       );
//       return;
//     }

//     setState(() {
//       isBackingUp = true;
//       progress = 0;
//     });

//     try {
//       final Map<String, dynamic> backup = {
//         "backupVersion": "1.0",
//         "createdAt": DateTime.now().toIso8601String(),
//         "collections": <String, dynamic>{},
//       };

//       int completed = 0;

//       for (final collectionName in selectedCollections) {
//         final snapshot = await FirebaseFirestore.instance
//             .collection(collectionName)
//             .get();

//         final List<Map<String, dynamic>> documents = [];

//         for (final doc in snapshot.docs) {
//           documents.add({
//             "id": doc.id,
//             "data": _convertFirestoreData(doc.data()),
//           });
//         }

//         backup["collections"][collectionName] = documents;

//         completed++;

//         if (mounted) {
//           setState(() {
//             progress = completed / selectedCollections.length;
//           });
//         }
//       }

//       final jsonString = const JsonEncoder.withIndent("  ").convert(backup);

//       if (!mounted) return;

//       final path = await FilePicker.platform.saveFile(
//         dialogTitle: t.saveDatabaseBackup,
//         fileName:
//             "database_backup_${DateTime.now().millisecondsSinceEpoch}.json",
//         type: FileType.custom,
//         allowedExtensions: ["json"],
//         bytes: utf8.encode(jsonString),
//       );

//       if (!mounted) return;

//       if (path == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(t.backupCancelled)));
//         return;
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.databaseBackupSavedSuccessfully),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.backupFailed(e.toString())),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isBackingUp = false;
//         });
//       }
//     }
//   }

//   Future<void> restoreBackup() async {
//     final t = AppLocalizations.of(context)!;
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         dialogTitle: t.selectDatabaseBackup,
//         type: FileType.custom,
//         allowedExtensions: ["json"],
//         withData: true,
//       );

//       if (result == null) return;

//       final file = result.files.single;

//       if (file.bytes == null) {
//         throw Exception(t.unableToReadSelectedFile);
//       }

//       final jsonString = utf8.decode(file.bytes!);

//       final Map<String, dynamic> backup = jsonDecode(jsonString);

//       if (backup["backupVersion"] == null ||
//           backup["collections"] == null ||
//           backup["collections"] is! Map) {
//         throw Exception(t.invalidBackupFile);
//       }

//       final collections = Map<String, dynamic>.from(backup["collections"]);

//       int totalDocuments = 0;

//       for (final collectionData in collections.values) {
//         if (collectionData is List) {
//           totalDocuments += collectionData.length;
//         }
//       }

//       if (!mounted) return;

//       final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (context) {
//           final theme = Theme.of(context);
//           final colorScheme = theme.colorScheme;

//           return AlertDialog(
//             title: Text(t.restoreDatabase),
//             content: Text(
//               "${t.backupContains}\n\n"
//               "${t.collectionsCount(collections.length)}\n"
//               "${t.documentsCount(totalDocuments)}\n\n"
//               "${t.existingDocumentsWillBeOverwritten}\n\n"
//               "${t.doYouWantToContinue}",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context, false);
//                 },
//                 child: Text(t.cancel),
//               ),
//               FilledButton(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: colorScheme.error,
//                   foregroundColor: colorScheme.onError,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context, true);
//                 },
//                 child: Text(t.restore),
//               ),
//             ],
//           );
//         },
//       );

//       if (confirmed != true) return;

//       setState(() {
//         isBackingUp = true;
//         progress = 0;
//       });

//       int completed = 0;

//       for (final entry in collections.entries) {
//         final collectionName = entry.key;
//         final documents = entry.value;

//         if (documents is! List) continue;

//         for (final document in documents) {
//           if (document is! Map) continue;

//           final documentId = document["id"]?.toString();

//           if (documentId == null || documentId.isEmpty) {
//             continue;
//           }

//           final rawData = document["data"];

//           if (rawData is! Map) continue;

//           final data = _restoreFirestoreData(
//             Map<String, dynamic>.from(rawData),
//           );

//           await FirebaseFirestore.instance
//               .collection(collectionName)
//               .doc(documentId)
//               .set(data, SetOptions(merge: false));

//           completed++;

//           if (mounted && totalDocuments > 0) {
//             setState(() {
//               progress = completed / totalDocuments;
//             });
//           }
//         }
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.databaseRestoredSuccessfully(completed)),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.restoreFailed(e.toString())),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isBackingUp = false;
//           progress = 0;
//         });
//       }
//     }
//   }

//   dynamic _restoreFirestoreData(dynamic value) {
//     if (value is Map) {
//       final map = Map<String, dynamic>.from(value);

//       if (map["_type"] == "timestamp") {
//         return Timestamp.fromDate(DateTime.parse(map["value"].toString()));
//       }

//       if (map["_type"] == "geopoint") {
//         return GeoPoint(
//           (map["latitude"] as num).toDouble(),
//           (map["longitude"] as num).toDouble(),
//         );
//       }

//       if (map["_type"] == "reference") {
//         return FirebaseFirestore.instance.doc(map["path"].toString());
//       }

//       return map.map(
//         (key, value) => MapEntry(key, _restoreFirestoreData(value)),
//       );
//     }

//     if (value is List) {
//       return value.map(_restoreFirestoreData).toList();
//     }

//     return value;
//   }

//   dynamic _convertFirestoreData(dynamic value) {
//     if (value is Timestamp) {
//       return {"_type": "timestamp", "value": value.toDate().toIso8601String()};
//     }

//     if (value is GeoPoint) {
//       return {
//         "_type": "geopoint",
//         "latitude": value.latitude,
//         "longitude": value.longitude,
//       };
//     }

//     if (value is DocumentReference) {
//       return {"_type": "reference", "path": value.path};
//     }

//     if (value is Map) {
//       return value.map(
//         (key, value) => MapEntry(key.toString(), _convertFirestoreData(value)),
//       );
//     }

//     if (value is List) {
//       return value.map(_convertFirestoreData).toList();
//     }

//     return value;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.backupDatabase),
//         centerTitle: true,
//         leading: const CustomBackButton(),
//       ),

//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             Icon(Icons.backup_rounded, size: 60, color: colorScheme.primary),

//             const SizedBox(height: 16),

//             Center(
//               child: Text(
//                 t.databaseBackup,
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               t.createBackupDescription,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),

//             const SizedBox(height: 30),

//             Card(
//               elevation: 0,
//               color: colorScheme.surfaceContainerHighest,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 side: BorderSide(color: colorScheme.outlineVariant),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       t.selectData,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       t.chooseCollectionsToInclude,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     ...collections.map((collection) {
//                       final selected = selectedCollections.contains(collection);

//                       return CheckboxListTile(
//                         contentPadding: EdgeInsets.zero,
//                         value: selected,
//                         title: Text(switch (collection) {
//                           "users" => t.users,
//                           "products" => t.products,
//                           "orders" => t.orders,
//                           "banks" => t.paymentBanks,
//                           "favorites" => t.favorites,
//                           _ => collection,
//                         }),
//                         secondary: Icon(_collectionIcon(collection)),
//                         onChanged: isBackingUp
//                             ? null
//                             : (value) {
//                                 setState(() {
//                                   if (value == true) {
//                                     selectedCollections.add(collection);
//                                   } else {
//                                     selectedCollections.remove(collection);
//                                   }
//                                 });
//                               },
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             if (isBackingUp) ...[
//               LinearProgressIndicator(
//                 value: progress,
//                 minHeight: 7,
//                 borderRadius: BorderRadius.circular(10),
//               ),

//               const SizedBox(height: 10),

//               Text(
//                 t.completedPercentage((progress * 100).toInt()),
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodyMedium,
//               ),

//               const SizedBox(height: 20),
//             ],

//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton.icon(
//                 onPressed: isBackingUp ? null : createBackup,
//                 icon: isBackingUp
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.cloud_download_rounded),
//                 label: Text(
//                   isBackingUp ? t.creatingBackup : t.createBackup,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: OutlinedButton.icon(
//                 onPressed: isBackingUp ? null : restoreBackup,
//                 icon: const Icon(Icons.restore_rounded),
//                 label: Text(
//                   t.restoreBackup,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: colorScheme.primaryContainer.withValues(alpha: 0.35),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.info_outline_rounded, color: colorScheme.primary),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       t.backupFirestoreOnly,
//                       style: theme.textTheme.bodySmall,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _collectionIcon(String collection) {
//     switch (collection) {
//       case "users":
//         return Icons.people_outline_rounded;
//       case "products":
//         return Icons.inventory_2_outlined;
//       case "orders":
//         return Icons.shopping_bag_outlined;
//       case "banks":
//         return Icons.account_balance_outlined;
//       case "favorites":
//         return Icons.favorite_border_rounded;
//       default:
//         return Icons.storage_rounded;
//     }
//   }
// }
