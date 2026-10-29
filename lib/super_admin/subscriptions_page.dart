import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionsPage extends StatefulWidget {
  final bool showArrowBack;
  const SubscriptionsPage({super.key, this.showArrowBack = true});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _filter = 'all';

  AppLocalizations get t => AppLocalizations.of(context)!;

  DateTime? _nextPaymentDate(Map<String, dynamic> subscription) {
    final value = subscription['nextPaymentDate'];

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }

  double _monthlyPrice(Map<String, dynamic> subscription) {
    final value = subscription['monthlyPrice'];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _subscriptionStatus(Map<String, dynamic> subscription) {
    final date = _nextPaymentDate(subscription);

    // no subscrption date
    if (date == null) return 'not_configured';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    final daysLeft = dueDate.difference(today).inDays;

    // date ended
    if (daysLeft < 0) return 'overdue';

    // 5 days or least
    if (daysLeft <= 5) return 'due_soon';

    // more than 5 days
    return 'active';
  }

  String _statusLabel(String status) {
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

  String _formatDate(DateTime? date) {
    if (date == null) return t.subscriptionNotSet;

    final locale = Localizations.localeOf(context).toString();

    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  Future<void> _manageSubscription({
    required String storeId,
    required String storeName,
    required Map<String, dynamic> currentSubscription,
  }) async {
    final priceController = TextEditingController(
      text: _monthlyPrice(currentSubscription) > 0
          ? _monthlyPrice(currentSubscription).toStringAsFixed(2)
          : '',
    );

    DateTime? selectedDate = _nextPaymentDate(currentSubscription);
    bool saving = false;

    final parentContext = context;

    try {
      await showDialog<void>(
        context: parentContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          final scheme = theme.colorScheme;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> pickDate() async {
                final now = DateTime.now();

                final picked = await showDatePicker(
                  context: dialogContext,
                  initialDate: selectedDate ?? now,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(data: theme, child: child!);
                  },
                );

                if (picked != null) {
                  setDialogState(() => selectedDate = picked);
                }
              }

              Future<void> save() async {
                final price = double.tryParse(
                  priceController.text.trim().replaceAll(',', '.'),
                );

                if (price == null || price < 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text(t.subscriptionInvalidPrice)),
                  );
                  return;
                }

                if (selectedDate == null) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text(t.subscriptionSelectPaymentDate)),
                  );
                  return;
                }

                setDialogState(() => saving = true);

                try {
                  await _firestore.collection('stores').doc(storeId).update({
                    'subscription': {
                      'planName': 'Monthly',
                      'monthlyPrice': price,
                      'currency': 'MAD',
                      'status': 'active',
                      'nextPaymentDate': Timestamp.fromDate(selectedDate!),
                      'updatedAt': FieldValue.serverTimestamp(),
                    },
                  });

                  if (!mounted ||
                      !parentContext.mounted ||
                      !dialogContext.mounted) {
                    return;
                  }

                  Navigator.of(dialogContext).pop();

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(t.subscriptionUpdatedFor(storeName)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  setDialogState(() => saving = false);

                  if (!parentContext.mounted) return;

                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(t.subscriptionSaveError(e.toString())),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: Text(t.subscriptionManageTitle),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          storeId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t.subscriptionMonthlyPrice,
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: t.subscriptionPriceHint,
                            prefixIcon: const Icon(Icons.payments_outlined),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t.subscriptionNextPayment,
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: saving ? null : pickDate,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(_formatDate(selectedDate)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(t.subscriptionSaveNote),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(t.cancel),
                  ),
                  FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      saving ? t.subscriptionSaving : t.subscriptionSave,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        priceController.dispose();
      });
    }
  }

  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    final color = _statusColor(status, scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(width: 7),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeCard({
    required BuildContext context,
    required QueryDocumentSnapshot<Map<String, dynamic>> storeDoc,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final data = storeDoc.data();

    final storeId = storeDoc.id;
    final storeName = (data['name'] ?? storeId).toString();

    final subscriptionValue = data['subscription'];
    final subscription = subscriptionValue is Map
        ? Map<String, dynamic>.from(subscriptionValue)
        : <String, dynamic>{};

    final price = _monthlyPrice(subscription);
    final dueDate = _nextPaymentDate(subscription);
    final status = _subscriptionStatus(subscription);
    final isStoreActive = data['isActive'] == true;
    final logoUrl = (data['logoUrl'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: status == 'overdue'
              ? scheme.error.withValues(alpha: 0.45)
              : scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.storefront_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        Icons.storefront_outlined,
                        color: scheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      storeId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: t.subscriptionManageTitle,
                onSelected: (_) => _manageSubscription(
                  storeId: storeId,
                  storeName: storeName,
                  currentSubscription: subscription,
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'manage',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined),
                        const SizedBox(width: 10),
                        Text(t.subscriptionManageTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 19, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.subscriptionMonthlyPrice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${price.toStringAsFixed(2)} ${t.currencySymbol}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.subscriptionNextPayment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                _formatDate(dueDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _statusBadge(context, status),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isStoreActive ? Colors.green : scheme.error)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isStoreActive
                      ? t.subscriptionStoreEnabled
                      : t.subscriptionStoreDisabled,
                  style: TextStyle(
                    color: isStoreActive ? Colors.green : scheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _manageSubscription(
                storeId: storeId,
                storeName: storeName,
                currentSubscription: subscription,
              ),
              icon: const Icon(Icons.settings_outlined),
              label: Text(t.subscriptionManageTitle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, ColorScheme scheme) {
    final selected = _filter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: scheme.primary.withValues(alpha: 0.16),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: widget.showArrowBack ? const CustomBackButton() : null,
        title: Text(t.subscriptionCenterTitle),
        centerTitle: true,
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('stores').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: scheme.error),
                      const SizedBox(height: 12),
                      Text(
                        t.subscriptionLoadError,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final stores = snapshot.data?.docs ?? [];

            final enrichedStores = stores.map((doc) {
              final data = doc.data();
              final value = data['subscription'];

              final subscription = value is Map
                  ? Map<String, dynamic>.from(value)
                  : <String, dynamic>{};

              return {
                'doc': doc,
                'status': _subscriptionStatus(subscription),
                'price': _monthlyPrice(subscription),
              };
            }).toList();

            final totalStores = stores.length;

            final configured = enrichedStores
                .where((item) => item['status'] != 'not_configured')
                .length;

            final dueSoon = enrichedStores
                .where((item) => item['status'] == 'due_soon')
                .length;

            final overdue = enrichedStores
                .where((item) => item['status'] == 'overdue')
                .length;

            final expectedRevenue = enrichedStores.fold<double>(0, (
              total,
              item,
            ) {
              if (item['status'] == 'not_configured') {
                return total;
              }

              return total + (item['price'] as double);
            });

            final filteredStores = enrichedStores.where((item) {
              if (_filter == 'all') return true;
              return item['status'] == _filter;
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width < 600 ? 16.0 : 28.0;

                final crossAxisCount = width >= 1200
                    ? 3
                    : width >= 760
                    ? 2
                    : 1;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [scheme.primary, scheme.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Colors.white,
                                  size: 29,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   t.subscriptionCenterTitle,
                                    //   style: theme.textTheme.headlineSmall
                                    //       ?.copyWith(
                                    //         fontWeight: FontWeight.w800,
                                    //       ),
                                    // ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.subscriptionCenterSubtitle,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: _manageBankAccount,
                              icon: const Icon(Icons.account_balance_outlined),
                              label: const Text('Bank Accounts'),
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.count(
                            crossAxisCount: width < 450
                                ? 1
                                : width >= 1000
                                ? 4
                                : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: width < 450 ? 3.0 : 1.8,
                            children: [
                              _summaryCard(
                                context: context,
                                title: t.subscriptionTotalStores,
                                value: '$totalStores',
                                icon: Icons.storefront_outlined,
                                color: scheme.primary,
                              ),
                              _summaryCard(
                                context: context,
                                title: t.subscriptionConfigured,
                                value: '$configured',
                                icon: Icons.verified_outlined,
                                color: Colors.green,
                              ),
                              _summaryCard(
                                context: context,
                                title: t.subscriptionDueSoon,
                                value: '$dueSoon',
                                icon: Icons.schedule_rounded,
                                color: Colors.orange,
                              ),
                              _summaryCard(
                                context: context,
                                title: t.subscriptionOverdue,
                                value: '$overdue',
                                icon: Icons.warning_amber_rounded,
                                color: scheme.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scheme.primary.withValues(alpha: 0.16),
                                  scheme.secondary.withValues(alpha: 0.07),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: 0.13,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.subscriptionExpectedRevenue,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${expectedRevenue.toStringAsFixed(2)} ${t.currencySymbol}',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 12,
                            spacing: 12,
                            children: [
                              Text(
                                t.subscriptionStoreSubscriptions,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _filterChip(
                                    'all',
                                    t.subscriptionFilterAll,
                                    scheme,
                                  ),
                                  _filterChip(
                                    'active',
                                    t.subscriptionStatusActive,
                                    scheme,
                                  ),
                                  _filterChip(
                                    'due_soon',
                                    t.subscriptionStatusDueSoon,
                                    scheme,
                                  ),
                                  _filterChip(
                                    'overdue',
                                    t.subscriptionStatusOverdue,
                                    scheme,
                                  ),
                                  _filterChip(
                                    'not_configured',
                                    t.subscriptionStatusNotConfigured,
                                    scheme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (filteredStores.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 48,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(t.subscriptionNoStores),
                                ],
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredStores.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: 340,
                                  ),
                              itemBuilder: (context, index) {
                                final item = filteredStores[index];

                                return _storeCard(
                                  context: context,
                                  storeDoc:
                                      item['doc']
                                          as QueryDocumentSnapshot<
                                            Map<String, dynamic>
                                          >,
                                );
                              },
                            ),
                          const SizedBox(height: 18),
                          Text(
                            t.subscriptionOverdueNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _manageBankAccount() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('subscription_payment_settings')
          .doc('main')
          .get();

      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SubscriptionBankAccountDialog(
          initialData: doc.data() ?? <String, dynamic>{},
        ),
      );

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.bankDetailsSavedSuccessfully)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.couldNotLoadBankDetails}: $e')),
      );
    }
  }
}

class _SubscriptionBankAccountDialog extends StatefulWidget {
  const _SubscriptionBankAccountDialog({required this.initialData});

  final Map<String, dynamic> initialData;

  @override
  State<_SubscriptionBankAccountDialog> createState() =>
      _SubscriptionBankAccountDialogState();
}

class _SubscriptionBankAccountDialogState
    extends State<_SubscriptionBankAccountDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController bankNameController;
  late final TextEditingController accountHolderController;
  late final TextEditingController ribController;
  late final TextEditingController ibanController;
  late final TextEditingController swiftController;
  late final TextEditingController instructionsController;

  late bool isActive;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    bankNameController = TextEditingController(
      text: data['bankName']?.toString() ?? '',
    );
    accountHolderController = TextEditingController(
      text: data['accountHolder']?.toString() ?? '',
    );
    ribController = TextEditingController(text: data['rib']?.toString() ?? '');
    ibanController = TextEditingController(
      text: data['iban']?.toString() ?? '',
    );
    swiftController = TextEditingController(
      text: data['swiftCode']?.toString() ?? '',
    );
    instructionsController = TextEditingController(
      text: data['instructions']?.toString() ?? '',
    );

    isActive = data['isActive'] == true;
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountHolderController.dispose();
    ribController.dispose();
    ibanController.dispose();
    swiftController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );
    }

    return AlertDialog(
      title: Text(t.subscriptionBankAccount),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // BANK NAME
                TextFormField(
                  controller: bankNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration(t.bankName),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return t.bankNameRequired;
                    }

                    if (text.length < 2) {
                      return t.enterValidBankName;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ACCOUNT HOLDER
                TextFormField(
                  controller: accountHolderController,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDecoration(t.accountName),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return t.accountNameRequired;
                    }

                    if (text.length < 2) {
                      return t.enterValidAccountName;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // RIB
                TextFormField(
                  controller: ribController,
                  keyboardType: TextInputType.number,
                  maxLength: 24,
                  decoration: inputDecoration(t.rib),
                  validator: (value) {
                    final rib = value?.replaceAll(' ', '').trim() ?? '';

                    if (rib.isEmpty) {
                      return t.ribRequired;
                    }

                    if (!RegExp(r'^\d{24}$').hasMatch(rib)) {
                      return t.ribExactly24Digits;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // IBAN - OPTIONAL
                TextFormField(
                  controller: ibanController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 28,
                  decoration: inputDecoration('${t.iban} (${t.optional})'),
                  validator: (value) {
                    final iban =
                        value?.replaceAll(' ', '').trim().toUpperCase() ?? '';

                    if (iban.isEmpty) {
                      return null;
                    }

                    if (!RegExp(r'^MA[0-9]{26}$').hasMatch(iban)) {
                      return t.enterValidIban;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // SWIFT/BIC - OPTIONAL
                TextFormField(
                  controller: swiftController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: inputDecoration(t.swiftBic),
                  validator: (value) {
                    final swift = value?.trim().toUpperCase() ?? '';

                    if (swift.isEmpty) {
                      return null;
                    }

                    if (!RegExp(
                      r'^[A-Z0-9]{8}([A-Z0-9]{3})?$',
                    ).hasMatch(swift)) {
                      return t.enterValidSwiftBic;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // PAYMENT INSTRUCTIONS
                TextFormField(
                  controller: instructionsController,
                  maxLines: 3,
                  decoration: inputDecoration(t.paymentInstructions),
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.active),
                  subtitle: Text((t.activeBankDetailsVisibleToStoreAdmins)),
                  value: isActive,
                  activeThumbColor: colors.primary,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: isSaving ? null : _save,
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.save),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;

    // VALIDATION
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('subscription_payment_settings')
          .doc('main')
          .set({
            'bankName': bankNameController.text.trim(),
            'accountHolder': accountHolderController.text.trim(),
            'rib': ribController.text.replaceAll(' ', '').trim(),
            'iban': ibanController.text
                .replaceAll(' ', '')
                .trim()
                .toUpperCase(),
            'swiftCode': swiftController.text.trim().toUpperCase(),
            'instructions': instructionsController.text.trim(),
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.failedToUpdateBankAccount}: $e')),
      );
    }
  }
}
