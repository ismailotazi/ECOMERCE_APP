import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = "system";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LanguageProvider>();

      setState(() {
        if (provider.isEnglish) {
          selectedLanguage = "en";
        } else if (provider.isFrench) {
          selectedLanguage = "fr";
        } else if (provider.isArabic) {
          selectedLanguage = "ar";
        } else {
          selectedLanguage = "system";
        }
      });
    });
  }

  Future<void> saveLanguage(String language) async {
    final t = AppLocalizations.of(context)!;
    final provider = context.read<LanguageProvider>();

    await provider.setLanguage(language);

    if (!mounted) return;

    setState(() {
      selectedLanguage = language;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.languageSavedSuccessfully)));
  }

  Widget languageTile({
    required String code,
    required String title,
    required String subtitle,
    required String flag,
  }) {
    final selected = selectedLanguage == code;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => saveLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      key: const ValueKey(true),
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.outline,
                      key: const ValueKey(false),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(centerTitle: true, title: Text(t.language)),

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
                    t.chooseYourPreferredLanguage,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    t.chooseLanguageDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 30),

                  languageTile(
                    code: "en",
                    title: "English",
                    subtitle: t.unitedStates,
                    flag: "🇺🇸",
                  ),

                  languageTile(
                    code: "fr",
                    title: "Français",
                    subtitle: t.france,
                    flag: "🇫🇷",
                  ),

                  languageTile(
                    code: "ar",
                    title: "العربية",
                    subtitle: "المغرب",
                    flag: "🇲🇦",
                  ),

                  languageTile(
                    code: "system",
                    title: t.systemDefault,
                    subtitle: t.followDeviceLanguage,
                    flag: "📱",
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
// import 'package:ecomerce_app/localization/language_provider.dart';
// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';

// class LanguagePage extends StatefulWidget {
//   const LanguagePage({super.key});

//   @override
//   State<LanguagePage> createState() => _LanguagePageState();
// }

// class _LanguagePageState extends State<LanguagePage> {
//   String selectedLanguage = "system";

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<LanguageProvider>();

//       setState(() {
//         if (provider.isEnglish) {
//           selectedLanguage = "en";
//         } else if (provider.isFrench) {
//           selectedLanguage = "fr";
//         } else if (provider.isArabic) {
//           selectedLanguage = "ar";
//         } else {
//           selectedLanguage = "system";
//         }
//       });
//     });
//   }

//   Future<void> saveLanguage(String language) async {
//     final t = AppLocalizations.of(context)!;
//     final provider = context.read<LanguageProvider>();

//     await provider.setLanguage(language);

//     if (!mounted) return;

//     setState(() {
//       selectedLanguage = language;
//     });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(t.languageSavedSuccessfully)));
//   }

//   Widget languageTile({
//     required String code,
//     required String title,
//     required String subtitle,
//     required String flag,
//   }) {
//     final selected = selectedLanguage == code;

//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: () => saveLanguage(code),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         margin: const EdgeInsets.only(bottom: 15),
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: selected
//               ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
//               : Theme.of(context).colorScheme.surfaceContainer,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: selected
//                 ? Theme.of(context).colorScheme.primary
//                 : Theme.of(context).colorScheme.outlineVariant,
//             width: selected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Text(flag, style: const TextStyle(fontSize: 28)),
//             const SizedBox(width: 16),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 250),
//               child: selected
//                   ? Icon(
//                       Icons.check_circle,
//                       color: Theme.of(context).colorScheme.primary,
//                       key: const ValueKey(true),
//                     )
//                   : Icon(
//                       Icons.radio_button_unchecked,
//                       color: Theme.of(context).colorScheme.outline,
//                       key: const ValueKey(false),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,

//       appBar: AppBar(centerTitle: true, title: Text(t.language)),

//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           Text(
//             t.chooseYourPreferredLanguage,
//             style: Theme.of(
//               context,
//             ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             t.chooseLanguageDescription,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ),

//           const SizedBox(height: 30),

//           languageTile(
//             code: "en",
//             title: "English",
//             subtitle: t.unitedStates,
//             flag: "🇺🇸",
//           ),

//           languageTile(
//             code: "fr",
//             title: "Français",
//             subtitle: t.france,
//             flag: "🇫🇷",
//           ),

//           languageTile(
//             code: "ar",
//             title: "العربية",
//             subtitle: "المغرب",
//             flag: "🇲🇦",
//           ),

//           languageTile(
//             code: "system",
//             title: t.systemDefault,
//             subtitle: t.followDeviceLanguage,
//             flag: "📱",
//           ),
//         ],
//       ),
//     );
//   }
// }
