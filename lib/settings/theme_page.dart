import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  bool isSaving = false;

  String getSelectedTheme(ThemeProvider provider) {
    if (provider.isLight) {
      return "light";
    }

    if (provider.isDark) {
      return "dark";
    }

    return "system";
  }

  Future<void> saveTheme(String theme) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await context.read<ThemeProvider>().setThemeMode(
        theme == 'light'
            ? ThemeMode.light
            : theme == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Theme saved successfully")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save theme")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget buildTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeProvider themeProvider,
  }) {
    final selectedTheme = getSelectedTheme(themeProvider);
    final selected = selectedTheme == value;

    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isSaving ? null : () => saveTheme(value),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            if (isSaving && selected)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colorScheme.primary : colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(title: Text(t.theme), centerTitle: true),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isDesktop = width >= 1100;
          final bool isTablet = width >= 700 && width < 1100;

          final double horizontalPadding = isDesktop
              ? 32
              : isTablet
              ? 24
              : 20;

          final double maxContentWidth = isDesktop
              ? 700
              : isTablet
              ? 650
              : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                children: [
                  Text(
                    t.chooseYourPreferredTheme,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    t.selectHowAppAppear,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 30),

                  buildTile(
                    value: "light",
                    title: t.light,
                    subtitle: t.alwaysUseLightMode,
                    icon: Icons.light_mode_rounded,
                    themeProvider: themeProvider,
                  ),

                  buildTile(
                    value: "dark",
                    title: t.dark,
                    subtitle: t.alwaysUseDarkMode,
                    icon: Icons.dark_mode_rounded,
                    themeProvider: themeProvider,
                  ),

                  buildTile(
                    value: "system",
                    title: t.system,
                    subtitle: t.systemDefault,
                    icon: Icons.phone_android_rounded,
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/theme_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ThemePage extends StatefulWidget {
//   const ThemePage({super.key});

//   @override
//   State<ThemePage> createState() => _ThemePageState();
// }

// class _ThemePageState extends State<ThemePage> {
//   bool isSaving = false;

//   String getSelectedTheme(ThemeProvider provider) {
//     if (provider.isLight) {
//       return "light";
//     }

//     if (provider.isDark) {
//       return "dark";
//     }

//     return "system";
//   }

//   Future<void> saveTheme(String theme) async {
//     if (isSaving) return;

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       await context.read<ThemeProvider>().setThemeMode(
//         theme == 'light'
//             ? ThemeMode.light
//             : theme == 'dark'
//             ? ThemeMode.dark
//             : ThemeMode.system,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Theme saved successfully")));
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Failed to save theme")));
//     } finally {
//       if (mounted) {
//         setState(() {
//           isSaving = false;
//         });
//       }
//     }
//   }

//   Widget buildTile({
//     required String value,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required ThemeProvider themeProvider,
//   }) {
//     final selectedTheme = getSelectedTheme(themeProvider);
//     final selected = selectedTheme == value;

//     final colorScheme = Theme.of(context).colorScheme;

//     return InkWell(
//       onTap: isSaving ? null : () => saveTheme(value),
//       borderRadius: BorderRadius.circular(18),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         margin: const EdgeInsets.only(bottom: 15),
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: selected
//               ? colorScheme.primary.withValues(alpha: 0.12)
//               : Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: selected ? colorScheme.primary : colorScheme.outlineVariant,
//             width: selected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 30,
//               color: selected
//                   ? colorScheme.primary
//                   : colorScheme.onSurfaceVariant,
//             ),

//             const SizedBox(width: 16),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.onSurface,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     subtitle,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             if (isSaving && selected)
//               SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color: colorScheme.primary,
//                 ),
//               )
//             else
//               Icon(
//                 selected ? Icons.check_circle : Icons.radio_button_unchecked,
//                 color: selected ? colorScheme.primary : colorScheme.outline,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final themeProvider = context.watch<ThemeProvider>();

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,

//       appBar: AppBar(title: Text(t.theme), centerTitle: true),

//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           Text(
//             t.chooseYourPreferredTheme,
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             t.selectHowAppAppear,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ),

//           const SizedBox(height: 30),

//           buildTile(
//             value: "light",
//             title: t.light,
//             subtitle: t.alwaysUseLightMode,
//             icon: Icons.light_mode_rounded,
//             themeProvider: themeProvider,
//           ),

//           buildTile(
//             value: "dark",
//             title: t.dark,
//             subtitle: t.alwaysUseDarkMode,
//             icon: Icons.dark_mode_rounded,
//             themeProvider: themeProvider,
//           ),

//           buildTile(
//             value: "system",
//             title: t.system,
//             subtitle: t.systemDefault,
//             icon: Icons.phone_android_rounded,
//             themeProvider: themeProvider,
//           ),
//         ],
//       ),
//     );
//   }
// }
