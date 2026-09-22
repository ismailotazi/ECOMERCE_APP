import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  Future<void> changePassword() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.passwordsDoNotMatch)));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(code: "no-user");
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPasswordController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.passwordChangedSuccessfully)));

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = t.somethingWentWrong;

      switch (e.code) {
        case "wrong-password":
        case "invalid-credential":
          message = t.currentPasswordIncorrect;
          break;

        case "weak-password":
          message = t.passwordTooWeak;
          break;

        case "too-many-requests":
          message = t.tooManyAttempts;
          break;

        case "requires-recent-login":
          message = t.pleaseSignInAgain;
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.changePassword),
        leading: const CustomBackButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
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
                ? 650
                : isTablet
                ? 600
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        t.changePassword,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        t.updateAdministratorPassword,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: hideCurrent,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return t.enterCurrentPassword;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: t.currentPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hideCurrent = !hideCurrent;
                              });
                            },
                            icon: Icon(
                              hideCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: newPasswordController,
                        obscureText: hideNew,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return t.passwordMinLength;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: t.newPassword,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hideNew = !hideNew;
                              });
                            },
                            icon: Icon(
                              hideNew ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: hideConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return t.confirmYourPassword;
                          }

                          if (value != newPasswordController.text) {
                            return t.passwordsDoNotMatch;
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: t.confirmPassword,
                          prefixIcon: const Icon(Icons.verified_user_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hideConfirm = !hideConfirm;
                              });
                            },
                            icon: Icon(
                              hideConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : changePassword,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  t.updatePassword,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});

//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }

// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final _formKey = GlobalKey<FormState>();

//   final currentPasswordController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   bool loading = false;

//   bool hideCurrent = true;
//   bool hideNew = true;
//   bool hideConfirm = true;
//   Future<void> changePassword() async {
//     final t = AppLocalizations.of(context)!;
//     if (!_formKey.currentState!.validate()) return;

//     if (newPasswordController.text != confirmPasswordController.text) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.passwordsDoNotMatch)));
//       return;
//     }

//     setState(() {
//       loading = true;
//     });

//     try {
//       final user = FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         throw FirebaseAuthException(code: "no-user");
//       }

//       final credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: currentPasswordController.text.trim(),
//       );

//       await user.reauthenticateWithCredential(credential);

//       await user.updatePassword(newPasswordController.text.trim());

//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(t.passwordChangedSuccessfully)));

//         Navigator.pop(context);
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = t.somethingWentWrong;

//       switch (e.code) {
//         case "wrong-password":
//         case "invalid-credential":
//           message = t.currentPasswordIncorrect;
//           break;

//         case "weak-password":
//           message = t.passwordTooWeak;
//           break;

//         case "too-many-requests":
//           message = t.tooManyAttempts;
//           break;

//         case "requires-recent-login":
//           message = t.pleaseSignInAgain;
//           break;
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(message)));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           loading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.changePassword),
//         leading: const CustomBackButton(),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               const SizedBox(height: 10),

//               Text(
//                 t.changePassword,
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 8),

//               Text(
//                 t.updateAdministratorPassword,
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),

//               const SizedBox(height: 30),

//               TextFormField(
//                 controller: currentPasswordController,
//                 obscureText: hideCurrent,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return t.enterCurrentPassword;
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   labelText: t.currentPassword,
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         hideCurrent = !hideCurrent;
//                       });
//                     },
//                     icon: Icon(
//                       hideCurrent ? Icons.visibility_off : Icons.visibility,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               TextFormField(
//                 controller: newPasswordController,
//                 obscureText: hideNew,
//                 validator: (value) {
//                   if (value == null || value.length < 6) {
//                     return t.passwordMinLength;
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   labelText: t.newPassword,
//                   prefixIcon: const Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         hideNew = !hideNew;
//                       });
//                     },
//                     icon: Icon(
//                       hideNew ? Icons.visibility_off : Icons.visibility,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               TextFormField(
//                 controller: confirmPasswordController,
//                 obscureText: hideConfirm,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return t.confirmYourPassword;
//                   }

//                   if (value != newPasswordController.text) {
//                     return t.passwordsDoNotMatch;
//                   }

//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   labelText: t.confirmPassword,
//                   prefixIcon: const Icon(Icons.verified_user_outlined),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         hideConfirm = !hideConfirm;
//                       });
//                     },
//                     icon: Icon(
//                       hideConfirm ? Icons.visibility_off : Icons.visibility,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 35),

//               SizedBox(
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: loading ? null : changePassword,
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                   ),
//                   child: loading
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2.5,
//                             color: Colors.white,
//                           ),
//                         )
//                       : Text(
//                           t.updatePassword,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
