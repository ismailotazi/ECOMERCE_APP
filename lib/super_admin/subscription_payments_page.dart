import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionPaymentsPage extends StatefulWidget {
  const SubscriptionPaymentsPage({super.key});

  @override
  State<SubscriptionPaymentsPage> createState() =>
      _SubscriptionPaymentsPageState();
}

class _SubscriptionPaymentsPageState extends State<SubscriptionPaymentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _filter = 'pending_review';
  bool _processing = false;
  AppLocalizations get t => AppLocalizations.of(context)!;

  String _formatDate(dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) return '—';

    final locale = Localizations.localeOf(context).toString();

    return DateFormat('dd MMM yyyy, HH:mm', locale).format(date);
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return scheme.error;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return t.storeSubscriptionPaymentApproved;
      case 'rejected':
        return t.storeSubscriptionPaymentRejected;
      default:
        return t.storeSubscriptionPaymentPendingReview;
    }
  }

  Future<void> _openProof(String storagePath) async {
    if (storagePath.trim().isEmpty) {
      _showMessage(t.subscriptionPaymentNoProof);
      return;
    }

    try {
      final url = await FirebaseStorage.instance
          .ref(storagePath)
          .getDownloadURL();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(t.subscriptionPaymentProof),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Unable to display payment proof.',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      _showMessage(t.subscriptionPaymentCouldNotOpenProof(e.toString()));
    }
  }

  Future<String?> _askReviewNote({required String action}) async {
    String note = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          action == 'approved'
              ? t.subscriptionPaymentApproveTitle
              : t.subscriptionPaymentRejectTitle,
        ),
        content: TextField(
          maxLines: 3,
          onChanged: (value) => note = value,
          decoration: InputDecoration(
            labelText: action == 'rejected'
                ? t.subscriptionPaymentRejectionReason
                : t.subscriptionPaymentReviewNoteOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              final trimmedNote = note.trim();

              if (action == 'rejected' && trimmedNote.isEmpty) {
                return;
              }

              Navigator.pop(dialogContext, trimmedNote);
            },
            child: Text(
              action == 'approved'
                  ? t.subscriptionPaymentApproveTitle
                  : t.subscriptionPaymentRejectTitle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewPayment({
    required String paymentId,
    required Map<String, dynamic> payment,
    required String action,
  }) async {
    if (_processing) return;

    final note = await _askReviewNote(action: action);

    if (note == null || !mounted) return;

    setState(() => _processing = true);

    try {
      final paymentRef = _firestore
          .collection('subscription_payments')
          .doc(paymentId);

      await _firestore.runTransaction((transaction) async {
        final paymentSnapshot = await transaction.get(paymentRef);

        if (!paymentSnapshot.exists) {
          throw StateError(t.subscriptionPaymentRequestMissing);
        }

        final currentPayment = paymentSnapshot.data()!;
        final storeId = (currentPayment['storeId'] ?? '').toString();

        if (storeId.isEmpty) {
          throw StateError(t.subscriptionPaymentMissingStoreId);
        }
        if (currentPayment['status'] != 'pending_review') {
          throw StateError(t.subscriptionPaymentAlreadyReviewed);
        }

        final storeRef = _firestore.collection('stores').doc(storeId);
        final storeSnapshot = await transaction.get(storeRef);

        if (!storeSnapshot.exists) {
          throw StateError(t.subscriptionPaymentStoreMissing);
        }

        transaction.update(paymentRef, {
          'status': action,
          'reviewNote': note,
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': FirebaseAuth.instance.currentUser!.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (action == 'approved') {
          final storeData = storeSnapshot.data()!;
          final subscriptionValue = storeData['subscription'];

          final subscription = subscriptionValue is Map
              ? Map<String, dynamic>.from(subscriptionValue)
              : <String, dynamic>{};

          final currentDateValue = subscription['nextPaymentDate'];
          DateTime? currentDate;

          if (currentDateValue is Timestamp) {
            currentDate = currentDateValue.toDate();
          } else if (currentDateValue is DateTime) {
            currentDate = currentDateValue;
          }

          final now = DateTime.now();
          final baseDate = currentDate != null && currentDate.isAfter(now)
              ? currentDate
              : now;

          final nextMonth = baseDate.month == 12 ? 1 : baseDate.month + 1;
          final nextYear = baseDate.month == 12
              ? baseDate.year + 1
              : baseDate.year;

          final lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

          final nextPaymentDate = DateTime(
            nextYear,
            nextMonth,
            baseDate.day > lastDayOfNextMonth
                ? lastDayOfNextMonth
                : baseDate.day,
            baseDate.hour,
            baseDate.minute,
            baseDate.second,
          );

          transaction.update(storeRef, {
            'subscription.status': 'active',
            'subscription.nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
            'subscription.lastPaymentAt': FieldValue.serverTimestamp(),
            'subscription.lastPaymentId': paymentId,
            'subscription.updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      if (!mounted) return;

      _showMessage(
        action == 'approved'
            ? t.subscriptionPaymentApprovedUpdated
            : t.subscriptionPaymentRejectedMessage,
      );
    } catch (e) {
      if (mounted) {
        _showMessage(t.subscriptionPaymentReviewError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _statusBadge(String status, ColorScheme scheme) {
    final color = _statusColor(status, scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _paymentCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final payment = document.data();

    final status = (payment['status'] ?? 'pending_review').toString();
    final storeName = (payment['storeName'] ?? payment['storeId'] ?? 'Store')
        .toString();
    final storeId = (payment['storeId'] ?? '').toString();
    final amount = payment['amount'] is num
        ? (payment['amount'] as num).toDouble()
        : double.tryParse(payment['amount']?.toString() ?? '') ?? 0;
    final currency = (payment['currency'] ?? 'MAD').toString();
    final bankName = (payment['bankName'] ?? '—').toString();
    final reference = (payment['transactionReference'] ?? '—').toString();
    final proofPath = (payment['proofStoragePath'] ?? '').toString();

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: scheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        storeId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status, scheme),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${amount.toStringAsFixed(2)} $currency',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(t.subscriptionPaymentBank, bankName),
            _infoRow(t.subscriptionPaymentTransferReference, reference),
            _infoRow(
              t.subscriptionPaymentTransferDate,
              _formatDate(payment['transferDate']),
            ),
            _infoRow(
              t.subscriptionPaymentSubmitted,
              _formatDate(payment['createdAt']),
            ),
            if ((payment['reviewNote'] ?? '').toString().trim().isNotEmpty)
              _infoRow(
                t.subscriptionPaymentReviewNoteOptional,
                payment['reviewNote'].toString(),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openProof(proofPath),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(t.subscriptionPaymentViewProof),
            ),
            if (status == 'pending_review') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _processing
                          ? null
                          : () => _reviewPayment(
                              paymentId: document.id,
                              payment: payment,
                              action: 'rejected',
                            ),
                      icon: const Icon(Icons.close),
                      label: Text(t.subscriptionPaymentRejectTitle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _processing
                          ? null
                          : () => _reviewPayment(
                              paymentId: document.id,
                              payment: payment,
                              action: 'approved',
                            ),
                      icon: const Icon(Icons.check),
                      label: Text(t.subscriptionPaymentApproveTitle),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.subscriptionPayments), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _filterChip(
                      'pending_review',
                      t.storeSubscriptionPaymentPendingReview,
                    ),
                    _filterChip('approved', t.storeSubscriptionPaymentApproved),
                    _filterChip('rejected', t.storeSubscriptionPaymentRejected),
                    _filterChip('all', t.subscriptionPaymentAll),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('subscription_payments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          t.subscriptionPaymentLoadError(
                            snapshot.error.toString(),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final documents = snapshot.data?.docs ?? [];

                  final filtered =
                      documents.where((document) {
                        if (_filter == 'all') return true;
                        return document.data()['status'] == _filter;
                      }).toList()..sort((a, b) {
                        final aDate = a.data()['createdAt'];
                        final bDate = b.data()['createdAt'];

                        final aMillis = aDate is Timestamp
                            ? aDate.millisecondsSinceEpoch
                            : 0;
                        final bMillis = bDate is Timestamp
                            ? bDate.millisecondsSinceEpoch
                            : 0;

                        return bMillis.compareTo(aMillis);
                      });

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 52,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.subscriptionPaymentNoRequests,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1100
                          ? 3
                          : constraints.maxWidth >= 700
                          ? 2
                          : 1;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 440,
                        ),
                        itemBuilder: (context, index) =>
                            _paymentCard(filtered[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _filter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: scheme.primary.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? scheme.primary : scheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
