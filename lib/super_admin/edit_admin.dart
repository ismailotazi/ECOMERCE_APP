import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class EditAdminPage extends StatefulWidget {
  final String adminId;
  final Map<String, dynamic> initialData;

  const EditAdminPage({
    super.key,
    required this.adminId,
    required this.initialData,
  });

  @override
  State<EditAdminPage> createState() => _EditAdminPageState();
}

class _EditAdminPageState extends State<EditAdminPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  String? _selectedStoreId;

  bool _isLoading = false;
  bool _isLoadingStores = true;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _stores = [];

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.initialData['firstName']?.toString() ?? '',
    );

    _lastNameController = TextEditingController(
      text: widget.initialData['lastName']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.initialData['email']?.toString() ?? '',
    );

    final existingStoreId = widget.initialData['storeId']?.toString().trim();

    _selectedStoreId = existingStoreId?.isNotEmpty == true
        ? existingStoreId
        : null;

    _loadStores();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('isActive', isEqualTo: true)
          .get();

      if (!mounted) return;

      setState(() {
        _stores = snapshot.docs;
        _isLoadingStores = false;
      });

      // If the existing admin store is not active anymore,
      // don't silently select another store.
      if (_selectedStoreId != null &&
          !_stores.any((doc) => doc.id == _selectedStoreId)) {
        setState(() {
          _selectedStoreId = null;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingStores = false;
      });
    }
  }

  String _storeName(QueryDocumentSnapshot<Map<String, dynamic>> store) {
    final data = store.data();

    final name = data['name']?.toString().trim() ?? '';

    if (name.isNotEmpty) {
      return name;
    }

    return store.id;
  }

  Future<void> _updateAdmin() async {
    final t = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    if (firstName.isEmpty) {
      _showError(t.pleaseEnterFirstName);
      return;
    }

    if (lastName.isEmpty) {
      _showError(t.pleaseEnterLastName);
      return;
    }

    if (email.isEmpty) {
      _showError(t.pleaseEnterEmail);
      return;
    }

    if (!_isValidEmail(email)) {
      _showError(t.invalidEmail);
      return;
    }

    if (_selectedStoreId == null || _selectedStoreId!.isEmpty) {
      _showError(t.pleaseSelectStore);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adminRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminId);

      final adminDoc = await adminRef.get();

      if (!adminDoc.exists) {
        _showError(t.adminOrStoreNotFound);
        return;
      }

      final adminData = adminDoc.data();

      if (adminData == null || adminData['role'] != 'admin') {
        _showError(t.adminOrStoreNotFound);
        return;
      }

      await adminRef.update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'storeId': _selectedStoreId,
      });

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.adminUpdatedSuccessfully),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = t.somethingWentWrong;

      switch (e.code) {
        case 'permission-denied':
          message = t.permissionDenied;
          break;

        case 'not-found':
          message = t.adminOrStoreNotFound;
          break;

        case 'already-exists':
          message = t.emailAlreadyExists;
          break;

        case 'failed-precondition':
          message = t.storeInactive;
          break;

        case 'invalid-argument':
          message = t.invalidAdminInformation;
          break;

        case 'unauthenticated':
          message = t.pleaseSignInAgain;
          break;
      }

      _showError(message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(t.somethingWentWrong);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final photoUrl = widget.initialData['photoUrl']?.toString().trim() ?? '';

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 44,
                  color: colorScheme.onPrimaryContainer,
                );
              },
            )
          : Icon(
              Icons.admin_panel_settings_outlined,
              size: 44,
              color: colorScheme.onPrimaryContainer,
            ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  Widget _buildForm(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.adminInformation,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 6),

        Text(
          t.updateAdminInformation,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: _firstNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !_isLoading,
          decoration: _inputDecoration(
            context,
            label: t.firstName,
            icon: Icons.person_outline_rounded,
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _lastNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !_isLoading,
          decoration: _inputDecoration(
            context,
            label: t.lastName,
            icon: Icons.person_outline_rounded,
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          decoration: _inputDecoration(
            context,
            label: t.email,
            icon: Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedStoreId,
          isExpanded: true,
          decoration: _inputDecoration(
            context,
            label: t.store,
            icon: Icons.storefront_outlined,
          ),
          items: _stores.map((store) {
            return DropdownMenuItem<String>(
              value: store.id,
              child: Text(
                _storeName(store),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _isLoading || _isLoadingStores
              ? null
              : (value) {
                  setState(() {
                    _selectedStoreId = value;
                  });
                },
        ),

        if (_isLoadingStores) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(
            minHeight: 3,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ],

        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security_rounded, color: colorScheme.primary),
              Expanded(
                child: Text(
                  t.adminUpdateSecurityInfo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _updateAdmin,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              _isLoading ? t.saving : t.saveChanges,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.editAdmin,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1100;
            final isTablet = width >= 700 && width < 1100;

            final horizontalPadding = isDesktop
                ? 40.0
                : isTablet
                ? 28.0
                : 20.0;

            final contentWidth = isDesktop ? 760.0 : 700.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 36 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    children: [
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32 : 24),
                          child: Column(
                            children: [
                              _buildAvatar(context),

                              const SizedBox(height: 16),

                              Text(
                                '${_firstNameController.text.trim()} '
                                            '${_lastNameController.text.trim()}'
                                        .trim()
                                        .isEmpty
                                    ? t.admin
                                    : '${_firstNameController.text.trim()} '
                                              '${_lastNameController.text.trim()}'
                                          .trim(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                t.administrator,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32 : 24),
                          child: _buildForm(context),
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
