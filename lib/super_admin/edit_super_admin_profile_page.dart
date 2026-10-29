import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';

class EditSuperAdminProfilePage extends StatefulWidget {
  const EditSuperAdminProfilePage({super.key});

  @override
  State<EditSuperAdminProfilePage> createState() =>
      _EditSuperAdminProfilePageState();
}

class _EditSuperAdminProfilePageState extends State<EditSuperAdminProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      final data = doc.data();

      if (!mounted) return;

      _firstNameController.text = data?['firstName']?.toString().trim() ?? '';

      _lastNameController.text = data?['lastName']?.toString().trim() ?? '';

      setState(() {
        _email = user.email ?? data?['email']?.toString() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('EDIT SUPER ADMIN PROFILE LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError();
    }
  }

  Future<void> _saveProfile() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'lastName': lastName,
      });

      await user.updateDisplayName('$firstName $lastName'.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(t.profileUpdatedSuccessfully),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('EDIT SUPER ADMIN PROFILE SAVE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError() {
    final t = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(t.somethingWentWrong),
      ),
    );
  }

  String get _displayName {
    final t = AppLocalizations.of(context)!;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    final name = '$firstName $lastName'.trim();

    return name.isNotEmpty ? name : t.superAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.editProfile,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1000;
                  final horizontalPadding = isDesktop
                      ? 40.0
                      : width >= 700
                      ? 28.0
                      : 20.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 40 : 24,
                      horizontalPadding,
                      40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileHeader(context, colorScheme),

                              const SizedBox(height: 28),

                              _buildSectionCard(
                                context,
                                title: t.personalInformation,
                                icon: Icons.person_outline_rounded,
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _firstNameController,
                                      label: t.firstName,
                                      icon: Icons.person_outline_rounded,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return t.firstNameIsRequired;
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _lastNameController,
                                      label: t.lastName,
                                      icon: Icons.person_outline_rounded,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return t.lastNameIsRequired;
                                        }

                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              _buildSectionCard(
                                context,
                                title: t.account,
                                icon: Icons.account_circle_outlined,
                                child: _buildEmailField(context, colorScheme),
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: _isSaving
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: Text(
                                    _isSaving ? t.saving : t.saveChanges,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme) {
    final t = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 500;

            final information = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  _email,
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.superAdmin,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final adminIcon = ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'images/official.jpg',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 42,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            );

            if (compact) {
              return Column(
                children: [adminIcon, const SizedBox(height: 16), information],
              );
            }

            return Row(
              children: [
                adminIcon,
                const SizedBox(width: 20),
                Expanded(child: information),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, ColorScheme colorScheme) {
    return TextFormField(
      initialValue: _email,
      readOnly: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: Icon(
          Icons.lock_outline_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
