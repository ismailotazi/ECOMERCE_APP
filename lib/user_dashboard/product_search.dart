import 'package:ecomerce_app/l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class ProductSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> products;

  ProductSearchDelegate({required this.products});

  @override
  List<Widget>? buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: t.clear,
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: theme.colorScheme.onSurface,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products.where((item) {
      final name = (item["name"] ?? "").toString().toLowerCase();
      return name.contains(query.toLowerCase().trim());
    }).toList();

    return _buildList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products.where((item) {
      final name = (item["name"] ?? "").toString().toLowerCase();
      return name.contains(query.toLowerCase().trim());
    }).toList();

    return _buildList(context, suggestions);
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> list) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 70,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                t.noProductFound,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.tryAnotherKeyword,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isDesktop = width >= 1100;
        final bool isTablet = width >= 700 && width < 1100;

        final double horizontalPadding = isDesktop
            ? 32
            : isTablet
            ? 24
            : 16;

        final double maxContentWidth = isDesktop
            ? 850
            : isTablet
            ? 700
            : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                final image = item["image"] ?? "";

                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(
                      isDesktop
                          ? 14
                          : isTablet
                          ? 13
                          : 12,
                    ),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              width: isDesktop
                                  ? 68
                                  : isTablet
                                  ? 64
                                  : 60,
                              height: isDesktop
                                  ? 68
                                  : isTablet
                                  ? 64
                                  : 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  width: isDesktop
                                      ? 68
                                      : isTablet
                                      ? 64
                                      : 60,
                                  height: isDesktop
                                      ? 68
                                      : isTablet
                                      ? 64
                                      : 60,
                                  color: theme.colorScheme.surface,
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: theme.colorScheme.outline,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: isDesktop
                                  ? 68
                                  : isTablet
                                  ? 64
                                  : 60,
                              height: isDesktop
                                  ? 68
                                  : isTablet
                                  ? 64
                                  : 60,
                              color: theme.colorScheme.surface,
                              child: Icon(
                                Icons.image_outlined,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                    ),

                    title: Text(
                      item["name"] ?? t.noName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "\$${item["price"]}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),

                    onTap: () {
                      close(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// import 'package:ecomerce_app/l10n/app_localizations.dart';

// import 'package:flutter/material.dart';

// class ProductSearchDelegate extends SearchDelegate {
//   final List<Map<String, dynamic>> products;

//   ProductSearchDelegate({required this.products});
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     final theme = Theme.of(context);
//     final t = AppLocalizations.of(context)!;
//     return [
//       if (query.isNotEmpty)
//         IconButton(
//           icon: Icon(
//             Icons.close_rounded,
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//           tooltip: t.clear,
//           onPressed: () => query = "",
//         ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     final theme = Theme.of(context);

//     return IconButton(
//       icon: Icon(
//         Icons.arrow_back_ios_new_rounded,
//         color: theme.colorScheme.onSurface,
//       ),
//       onPressed: () => close(context, null),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final results = products.where((item) {
//       final name = (item["name"] ?? "").toString().toLowerCase();
//       return name.contains(query.toLowerCase().trim());
//     }).toList();

//     return _buildList(context, results);
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = products.where((item) {
//       final name = (item["name"] ?? "").toString().toLowerCase();
//       return name.contains(query.toLowerCase().trim());
//     }).toList();

//     return _buildList(context, suggestions);
//   }

//   Widget _buildList(BuildContext context, List<Map<String, dynamic>> list) {
//     final theme = Theme.of(context);
//     final t = AppLocalizations.of(context)!;
//     if (list.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off_rounded,
//               size: 70,
//               color: theme.colorScheme.outline,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               t.noProductFound,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               t.tryAnotherKeyword,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.outline,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: list.length,
//       separatorBuilder: (_, _) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final item = list[index];
//         final image = item["image"] ?? "";

//         return Card(
//           elevation: 0,
//           color: theme.colorScheme.surfaceContainerHighest,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//             side: BorderSide(color: theme.colorScheme.outlineVariant),
//           ),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(12),

//             leading: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: image.isNotEmpty
//                   ? Image.network(
//                       image,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, _, _) {
//                         return Container(
//                           width: 60,
//                           height: 60,
//                           color: theme.colorScheme.surface,
//                           child: Icon(
//                             Icons.image_outlined,
//                             color: theme.colorScheme.outline,
//                           ),
//                         );
//                       },
//                     )
//                   : Container(
//                       width: 60,
//                       height: 60,
//                       color: theme.colorScheme.surface,
//                       child: Icon(
//                         Icons.image_outlined,
//                         color: theme.colorScheme.outline,
//                       ),
//                     ),
//             ),

//             title: Text(
//               item["name"] ?? t.noName,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             subtitle: Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 "\$${item["price"]}",
//                 style: theme.textTheme.titleSmall?.copyWith(
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             trailing: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: theme.colorScheme.outline,
//             ),

//             onTap: () {
//               close(context, item);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
