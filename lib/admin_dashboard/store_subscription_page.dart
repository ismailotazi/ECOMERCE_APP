import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoreSubscriptionPage extends StatefulWidget {
  const StoreSubscriptionPage({super.key});

  @override
  State<StoreSubscriptionPage> createState() => _StoreSubscriptionPageState();
}

class _StoreSubscriptionPageState extends State<StoreSubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _storeLoadStarted = false;
  String? _storeId;
  String _storeName = '';
  bool _loadingStore = true;
  String? _loadError;

  PlatformFile? _selectedFile;
  DateTime? _transferDate;
  final TextEditingController _referenceController = TextEditingController();

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_storeLoadStarted) {
      _storeLoadStarted = true;
      _loadStore();
    }
  }

  Future<void> _loadStore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          AppLocalizations.of(context)!.storeSubscriptionSignInAgain,
        );
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final storeId = (userData['storeId'] ?? '').toString().trim();
      if (!mounted) return;
      if (storeId.isEmpty) {
        throw Exception(AppLocalizations.of(context)!.storeSubscriptionNoStore);
      }

      final storeDoc = await _firestore.collection('stores').doc(storeId).get();
      if (!mounted) return;
      if (!storeDoc.exists) {
        throw Exception(
          AppLocalizations.of(context)!.storeSubscriptionStoreNotFound,
        );
      }

      if (!mounted) return;

      setState(() {
        _storeId = storeId;
        _storeName = (storeDoc.data()?['name'] ?? storeId).toString();
        _loadingStore = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingStore = false;
        _loadError = e.toString();
      });
    }
  }

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  double _toPrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(DateTime? date) {
    final t = AppLocalizations.of(context)!;

    if (date == null) return t.subscriptionNotSet;

    final locale = Localizations.localeOf(context).languageCode;

    final month = DateFormat('MMM', locale).format(date);
    final day = DateFormat('dd').format(date);
    final year = DateFormat('yyyy').format(date);

    return '$day $month $year';
  }

  String _subscriptionStatus(Map<String, dynamic> subscription) {
    final date = _toDate(subscription['nextPaymentDate']);

    if (date == null) return 'not_configured';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final daysLeft = due.difference(today).inDays;

    if (daysLeft < 0) return 'overdue';
    if (daysLeft <= 5) return 'due_soon';

    return 'active';
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'due_soon':
        return Colors.orange;
      case 'overdue':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _statusText(String status) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case 'active':
        return t.subscriptionStatusActive;
      case 'due_soon':
        return t.subscriptionStatusDueSoon;
      case 'overdue':
        return t.subscriptionStatusOverdue;
      default:
        return t.subscriptionStatusNotConfigured;
    }
  }

  Future<void> _pickFile() async {
    final t = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final extension = (file.extension ?? '').toLowerCase();

      if (!['jpg', 'jpeg', 'png', 'webp', 'pdf'].contains(extension)) {
        _showMessage(t.storeSubscriptionChooseFileType);
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        _showMessage(t.storeSubscriptionFileTooLarge);
        return;
      }

      if (file.bytes == null && file.path == null) {
        _showMessage(t.storeSubscriptionFileReadError);
        return;
      }

      setState(() => _selectedFile = file);
    } catch (e) {
      _showMessage(t.storeSubscriptionFileSelectError(e.toString()));
    }
  }

  Future<void> _pickTransferDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _transferDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
    );

    if (picked != null && mounted) {
      setState(() => _transferDate = picked);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _submitPayment() async {
    final storeId = _storeId;
    final file = _selectedFile;
    final transferDate = _transferDate;
    final t = AppLocalizations.of(context)!;
    if (storeId == null || file == null || transferDate == null) {
      _showMessage(t.storeSubscriptionSelectDateAndProof);
      return;
    }

    if (file.bytes == null && file.path == null) {
      _showMessage(t.storeSubscriptionFileUnavailable);
      return;
    }

    setState(() => _uploading = true);

    String? uploadedPath;

    try {
      final storeRef = _firestore.collection('stores').doc(storeId);
      final storeSnapshot = await storeRef.get();

      final storeData = storeSnapshot.data() ?? {};
      final subscriptionValue = storeData['subscription'];

      final subscription = subscriptionValue is Map
          ? Map<String, dynamic>.from(subscriptionValue)
          : <String, dynamic>{};

      final price = _toPrice(subscription['monthlyPrice']);

      const currency = 'MAD';

      final planName =
          (subscription['planName'] ?? t.storeSubscriptionMonthlyPlan)
              .toString();

      if (price <= 0) {
        throw Exception(t.storeSubscriptionPriceNotConfigured);
      }

      final bankDoc = await _firestore
          .collection('subscription_payment_settings')
          .doc('main')
          .get();

      final bankData = bankDoc.data() ?? {};

      if (!bankDoc.exists || bankData['isActive'] != true) {
        throw Exception(t.storeSubscriptionBankUnavailable);
      }

      final extension = (file.extension ?? 'bin').toLowerCase();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${storeId}_proof.$extension';

      final storageRef = _storage.ref().child(
        'subscription_payment_proofs/$storeId/$fileName',
      );

      final contentType = extension == 'pdf'
          ? 'application/pdf'
          : extension == 'png'
          ? 'image/png'
          : extension == 'webp'
          ? 'image/webp'
          : extension == 'jpg' || extension == 'jpeg'
          ? 'image/jpeg'
          : 'application/octet-stream';

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'storeId': storeId,
          'purpose': 'subscription_payment_proof',
        },
      );

      final bytes = file.bytes;

      if (bytes != null) {
        await storageRef.putData(bytes, metadata);
      } else {
        await storageRef.putFile(File(file.path!), metadata);
      }

      uploadedPath = storageRef.fullPath;

      final paymentRef = _firestore.collection('subscription_payments').doc();

      await paymentRef.set({
        'storeId': storeId,
        'storeName': _storeName,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'planName': planName,
        'amount': price,
        'currency': currency,
        'transferDate': Timestamp.fromDate(transferDate),
        'transactionReference': _referenceController.text.trim(),
        'proofStoragePath': uploadedPath,
        'bankName': (bankData['bankName'] ?? '').toString(),
        'status': 'pending_review',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _selectedFile = null;
        _transferDate = null;
        _referenceController.clear();
      });

      _showMessage(t.storeSubscriptionPaymentSubmitted);
    } catch (e) {
      // Do not leave an orphaned uploaded proof when saving the record fails.
      if (uploadedPath != null) {
        try {
          await _storage.ref().child(uploadedPath).delete();
        } catch (_) {
          // Keep the original error if cleanup is not permitted.
        }
      }

      _showMessage(t.storeSubscriptionSubmitPaymentError(e.toString()));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _sectionCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: scheme.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscription(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    final subscriptionValue = data['subscription'];
    final subscription = subscriptionValue is Map
        ? Map<String, dynamic>.from(subscriptionValue)
        : <String, dynamic>{};

    final price = _toPrice(subscription['monthlyPrice']);

    const currency = 'MAD';

    final plan = (subscription['planName'] ?? t.storeSubscriptionMonthlyPlan)
        .toString();

    final dueDate = _toDate(subscription['nextPaymentDate']);

    final status = _subscriptionStatus(subscription);

    final statusColor = _statusColor(status, scheme);

    return _sectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.workspace_premium_outlined,
            title: t.storeSubscriptionYourSubscription,
            subtitle: _storeName,
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusBadge(context, _statusText(status), statusColor),
              if (data['isActive'] == false)
                _statusBadge(
                  context,
                  t.subscriptionStoreDisabled,
                  scheme.error,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.15),
                  scheme.secondary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${price.toStringAsFixed(2)} $currency',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  t.storeSubscriptionPriceLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            context,
            label: t.storeSubscriptionNextPaymentDate,
            value: _formatDate(dueDate),
            icon: Icons.calendar_month_outlined,
          ),
          _infoRow(
            context,
            label: t.storeSubscriptionStatusLabel,
            value: _statusText(status),
            icon: Icons.verified_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetails(Map<String, dynamic>? bank) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    if (bank == null || bank['isActive'] != true) {
      return _sectionCard(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              context,
              icon: Icons.account_balance_outlined,
              title: t.storeSubscriptionBankTransfer,
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.info_outline_rounded,
              color: scheme.onSurfaceVariant,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(t.storeSubscriptionBankUnavailableContact),
          ],
        ),
      );
    }

    final bankName = (bank['bankName'] ?? '').toString();
    final accountHolder = (bank['accountHolder'] ?? '').toString();
    final rib = (bank['rib'] ?? '').toString();
    final iban = (bank['iban'] ?? '').toString();
    final swift = (bank['swiftCode'] ?? '').toString();
    final instructions = (bank['instructions'] ?? '').toString();

    return _sectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.account_balance_outlined,
            title: t.storeSubscriptionBankTransferDetails,
            subtitle: t.storeSubscriptionTransferInstructions,
          ),
          const SizedBox(height: 18),
          _infoRow(
            context,
            label: t.storeSubscriptionBankName,
            value: bankName,
            icon: Icons.account_balance,
          ),
          _infoRow(
            context,
            label: t.storeSubscriptionAccountHolder,
            value: accountHolder,
            icon: Icons.person_outline,
          ),
          _infoRow(
            context,
            label: t.storeSubscriptionRib,
            value: rib,
            icon: Icons.numbers_outlined,
          ),
          if (iban.isNotEmpty)
            _infoRow(
              context,
              label: t.storeSubscriptionIban,
              value: iban,
              icon: Icons.account_box_outlined,
            ),
          if (swift.isNotEmpty)
            _infoRow(
              context,
              label: t.storeSubscriptionSwiftBic,
              value: swift,
              icon: Icons.language_outlined,
            ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(instructions),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadForm() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    final file = _selectedFile;

    return _sectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.receipt_long_outlined,
            title: t.storeSubscriptionSubmitProofTitle,
            subtitle: t.storeSubscriptionUploadReceiptSubtitle,
          ),
          const SizedBox(height: 22),
          Text(
            t.storeSubscriptionTransferDate,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _uploading ? null : _pickTransferDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(_formatDate(_transferDate)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            t.storeSubscriptionTransactionReferenceOptional,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _referenceController,
            enabled: !_uploading,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: t.storeSubscriptionTransactionReferenceHint,
              prefixIcon: const Icon(Icons.tag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            t.storeSubscriptionTransferReceiptRequired,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _uploading ? null : _pickFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: file == null ? scheme.outlineVariant : scheme.primary,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    file == null
                        ? Icons.cloud_upload_outlined
                        : (file.extension?.toLowerCase() == 'pdf'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined),
                    size: 38,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    file?.name ?? t.storeSubscriptionChooseImageOrPdf,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    file == null
                        ? t.storeSubscriptionAllowedFileTypes
                        : '${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    file == null
                        ? t.storeSubscriptionBrowseFiles
                        : t.storeSubscriptionChangeFile,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _uploading ? null : _submitPayment,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                _uploading
                    ? t.storeSubscriptionSubmitting
                    : t.storeSubscriptionSubmitForVerification,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.storeSubscriptionManualVerificationNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final storeId = _storeId!;
    final t = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('subscription_payments')
          .where('storeId', isEqualTo: storeId)
          .snapshots(),
      builder: (context, snapshot) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        if (snapshot.hasError) {
          return _sectionCard(
            context: context,
            child: Text(
              t.storeSubscriptionLoadHistoryError(snapshot.error.toString()),
              style: TextStyle(color: scheme.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _sectionCard(
            context: context,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        docs.sort((a, b) {
          final aDate =
              _toDate(a.data()['createdAt']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              _toDate(b.data()['createdAt']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        return _sectionCard(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                context,
                icon: Icons.history_rounded,
                title: t.storeSubscriptionPaymentHistory,
                subtitle: t.storeSubscriptionPaymentHistorySubtitle,
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 38,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(t.storeSubscriptionNoPayments),
                      ],
                    ),
                  ),
                )
              else
                ...docs.map((doc) {
                  final payment = doc.data();
                  final status = (payment['status'] ?? 'pending_review')
                      .toString();

                  final color = switch (status) {
                    'approved' => Colors.green,
                    'rejected' => scheme.error,
                    _ => Colors.orange,
                  };

                  final statusLabel = switch (status) {
                    'approved' => t.storeSubscriptionPaymentApproved,
                    'rejected' => t.storeSubscriptionPaymentRejected,
                    _ => t.storeSubscriptionPaymentPendingReview,
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_toPrice(payment['amount']).toStringAsFixed(2)} '
                                  '${payment['currency'] ?? 'MAD'}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _statusBadge(context, statusLabel, color),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            context,
                            label: t.storeSubscriptionTransferDate,
                            value: _formatDate(
                              _toDate(payment['transferDate']),
                            ),
                          ),
                          if ((payment['transactionReference'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                            _infoRow(
                              context,
                              label: t.storeSubscriptionReference,
                              value: payment['transactionReference'].toString(),
                            ),
                          if ((payment['reviewNote'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                            _infoRow(
                              context,
                              label: t.storeSubscriptionAdminNote,
                              value: payment['reviewNote'].toString(),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    if (_loadingStore) {
      return Scaffold(
        appBar: AppBar(title: Text(t.storeSubscriptionTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.storeSubscriptionTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: scheme.error),
                const SizedBox(height: 12),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _loadingStore = true;
                      _loadError = null;
                    });
                    _loadStore();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(t.tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.storeSubscriptionTitle)),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('stores').doc(_storeId).snapshots(),
          builder: (context, storeSnapshot) {
            if (storeSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t.storeSubscriptionLoadDetailsError(
                      storeSnapshot.error.toString(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!storeSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final storeData = storeSnapshot.data!.data() ?? {};

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('subscription_payment_settings')
                  .doc('main')
                  .snapshots(),
              builder: (context, bankSnapshot) {
                Map<String, dynamic>? bankData;

                if (bankSnapshot.hasData && bankSnapshot.data!.exists) {
                  bankData = bankSnapshot.data!.data();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final horizontalPadding = maxWidth < 600 ? 16.0 : 28.0;

                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(maxWidth < 600 ? 20 : 28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [scheme.primary, scheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t.storeSubscriptionManageTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.storeSubscriptionManageSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSubscription(storeData),
                        const SizedBox(height: 18),
                        if (bankSnapshot.hasError)
                          _sectionCard(
                            context: context,
                            child: Text(
                              t.storeSubscriptionLoadBankError,
                              style: TextStyle(color: scheme.error),
                            ),
                          )
                        else if (bankSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !bankSnapshot.hasData)
                          _sectionCard(
                            context: context,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          _buildBankDetails(bankData),
                        const SizedBox(height: 18),
                        _buildUploadForm(),
                        const SizedBox(height: 18),
                        _buildPaymentHistory(),
                      ],
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: content,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
