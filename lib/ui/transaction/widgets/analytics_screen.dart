import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/transaction/widgets/Owe-toggle.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

enum _Period { daily, weekly, monthly, yearly }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showOwedToMe = true;
  _Period _period = _Period.weekly;

  String? _myAddress;

  String? _filterFriendPublicKey;
  String? _filterTag;
  DateTimeRange? _filterDateRange;

  static const _categoryColors = [
    Color(0xFF16A34A),
    Color(0xFF22C55E),
    Color(0xFF4ADE80),
    Color(0xFF86EFAC),
    Color(0xFFBBF7D0),
    Color(0xFF065F46),
    Color(0xFF0D9488),
  ];

  @override
  void initState() {
    super.initState();
    const FlutterSecureStorage().read(key: 'evm_address').then((addr) {
      if (mounted) setState(() => _myAddress = addr);
    });
  }

  bool _isAccepted(TransactionModel t) =>
      t.status.name.toLowerCase().contains('accept');

  List<TransactionModel> _filteredTransactions(List<TransactionModel> all) {
    final me = _myAddress;
    if (me == null) return const [];

    return all.where((t) {
      if (!_isAccepted(t)) return false;
      final involvesMe = t.fromUserPublicKey == me || t.toUserPublicKey == me;
      if (!involvesMe) return false;

      if (_filterFriendPublicKey != null) {
        final friendInvolved =
            t.fromUserPublicKey == _filterFriendPublicKey ||
            t.toUserPublicKey == _filterFriendPublicKey;
        if (!friendInvolved) return false;
      }

      if (_filterTag != null && t.tag != _filterTag) return false;

      if (_filterDateRange != null) {
        final d = DateTime(
          t.createdAt.year,
          t.createdAt.month,
          t.createdAt.day,
        );
        final start = _filterDateRange!.start;
        final end = _filterDateRange!.end;
        if (d.isBefore(start) || d.isAfter(end)) return false;
      }

      return true;
    }).toList();
  }

  double _absRupees(TransactionModel t) => t.amount.abs().toDouble() / 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, txState) {
                  return BlocBuilder<BalanceBloc, BalanceState>(
                    builder: (context, balState) {
                      final transactions = txState is TransactionLoaded
                          ? _filteredTransactions(txState.transactions)
                          : <TransactionModel>[];

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          _buildFilters(theme),
                          const SizedBox(height: 16),
                          Center(
                            child: OweToggle(
                              showOwedToMe: _showOwedToMe,
                              onChanged: (val) =>
                                  setState(() => _showOwedToMe = val),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildAmountDisplay(theme, balState),
                          const SizedBox(height: 24),
                          _buildTrendCard(theme, transactions),
                          const SizedBox(height: 20),
                          _buildBreakdownCard(theme, transactions),
                        ],
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

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Expanded(
            child: Text(
              'Analytics',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final colors = theme.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            theme,
            label: _filterFriendLabel(),
            icon: Icons.person_outline,
            active: _filterFriendPublicKey != null,
            onTap: _showFriendFilterSheet,
          ),
          const SizedBox(width: 8),
          _filterChip(
            theme,
            label: _filterTag ?? 'All categories',
            icon: Icons.sell_outlined,
            active: _filterTag != null,
            onTap: _showTagFilterSheet,
          ),
          const SizedBox(width: 8),
          _filterChip(
            theme,
            label: _filterDateRangeLabel(),
            icon: Icons.calendar_today_outlined,
            active: _filterDateRange != null,
            onTap: _pickDateRange,
          ),
          if (_filterFriendPublicKey != null ||
              _filterTag != null ||
              _filterDateRange != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _filterFriendPublicKey = null;
                _filterTag = null;
                _filterDateRange = null;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Clear',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _filterFriendLabel() {
    if (_filterFriendPublicKey == null) return 'All friends';
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final match = userState.users
          .where((u) => u.publicKey == _filterFriendPublicKey)
          .toList();
      if (match.isNotEmpty) return match.first.displayName;
    }
    return 'Friend';
  }

  String _filterDateRangeLabel() {
    if (_filterDateRange == null) return 'All time';
    final s = _filterDateRange!.start;
    final e = _filterDateRange!.end;
    return '${s.day}/${s.month} - ${e.day}/${e.month}';
  }

  Widget _filterChip(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    final colors = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.primary.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? colors.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active
                  ? colors.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: active
                    ? colors.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendFilterSheet() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoaded || _myAddress == null) return;
    final friends = userState.users
        .where((u) => u.publicKey != _myAddress)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by friend',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('All friends'),
                trailing: _filterFriendPublicKey == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() => _filterFriendPublicKey = null);
                  Navigator.pop(context);
                },
              ),
              ...friends.map(
                (f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(f.displayName),
                  trailing: _filterFriendPublicKey == f.publicKey
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    setState(() => _filterFriendPublicKey = f.publicKey);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagFilterSheet() {
    final txState = context.read<TransactionBloc>().state;
    if (txState is! TransactionLoaded) return;
    final tags =
        txState.transactions
            .map((t) => t.tag)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('All categories'),
                trailing: _filterTag == null ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _filterTag = null);
                  Navigator.pop(context);
                },
              ),
              ...tags.map(
                (tag) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tag),
                  trailing: _filterTag == tag ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _filterTag = tag);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filterDateRange,
    );
    if (picked != null) setState(() => _filterDateRange = picked);
  }

  Widget _buildAmountDisplay(ThemeData theme, BalanceState balState) {
    double owedToMe = 0;
    double iOwe = 0;

    if (balState is BalanceLoaded) {
      for (final b in balState.balances) {
        final rupees = b.netAmount / 100.0;
        if (rupees > 0) {
          owedToMe += rupees;
        } else if (rupees < 0) {
          iOwe += rupees.abs();
        }
      }
    }

    final amount = _showOwedToMe ? owedToMe : iOwe;
    final colors = theme.colorScheme;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (amount > 0) ...[
            const SizedBox(width: 4),
            Icon(
              _showOwedToMe
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: _showOwedToMe ? colors.primary : colors.error,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendCard(ThemeData theme, List<TransactionModel> transactions) {
    final colors = theme.colorScheme;
    final buckets = _bucketByPeriod(transactions);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Expenses',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildPeriodTabs(theme),
          const SizedBox(height: 20),
          if (buckets.every((v) => v == 0))
            _buildEmptyChartState(theme, 'No expenses in this period yet')
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final labels = _periodLabels();
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < buckets.length; i++)
                          FlSpot(i.toDouble(), buckets[i]),
                      ],
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              '₹${s.y.toStringAsFixed(0)}',
                              theme.textTheme.bodySmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs(ThemeData theme) {
    final colors = theme.colorScheme;
    final options = {
      _Period.daily: 'Daily',
      _Period.weekly: 'Weekly',
      _Period.monthly: 'Monthly',
      _Period.yearly: 'Yearly',
    };
    return Row(
      children: options.entries.map((entry) {
        final selected = _period == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _period = entry.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? colors.primary.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? colors.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<double> _bucketByPeriod(List<TransactionModel> transactions) {
    final now = DateTime.now();
    late int bucketCount;
    late DateTime Function(int offset) bucketStart;
    late bool Function(DateTime txnDate, int offset) inBucket;

    switch (_period) {
      case _Period.daily:
        bucketCount = 7;
        bucketStart = (offset) =>
            DateTime(now.year, now.month, now.day - (bucketCount - 1 - offset));
        inBucket = (d, offset) {
          final start = bucketStart(offset);
          return d.year == start.year &&
              d.month == start.month &&
              d.day == start.day;
        };
        break;
      case _Period.weekly:
        bucketCount = 7;
        bucketStart = (offset) =>
            DateTime(now.year, now.month, now.day - (bucketCount - 1 - offset));
        inBucket = (d, offset) {
          final start = bucketStart(offset);
          return d.year == start.year &&
              d.month == start.month &&
              d.day == start.day;
        };
        break;
      case _Period.monthly:
        bucketCount = 6;
        bucketStart = (offset) =>
            DateTime(now.year, now.month - (bucketCount - 1 - offset), 1);
        inBucket = (d, offset) {
          final start = bucketStart(offset);
          return d.year == start.year && d.month == start.month;
        };
        break;
      case _Period.yearly:
        bucketCount = 5;
        bucketStart = (offset) =>
            DateTime(now.year - (bucketCount - 1 - offset), 1, 1);
        inBucket = (d, offset) {
          final start = bucketStart(offset);
          return d.year == start.year;
        };
        break;
    }

    final result = List<double>.filled(bucketCount, 0);
    for (final t in transactions) {
      for (int i = 0; i < bucketCount; i++) {
        if (inBucket(t.createdAt, i)) {
          result[i] += _absRupees(t);
          break;
        }
      }
    }
    return result;
  }

  List<String> _periodLabels() {
    final now = DateTime.now();
    switch (_period) {
      case _Period.daily:
      case _Period.weekly:
        const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        return List.generate(7, (i) {
          final d = DateTime(now.year, now.month, now.day - (6 - i));
          return dayNames[(d.weekday - 1) % 7];
        });
      case _Period.monthly:
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return List.generate(6, (i) {
          final m = DateTime(now.year, now.month - (5 - i), 1);
          return monthNames[m.month - 1];
        });
      case _Period.yearly:
        return List.generate(5, (i) => (now.year - (4 - i)).toString());
    }
  }

  Widget _buildEmptyChartState(ThemeData theme, String message) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 40,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(
    ThemeData theme,
    List<TransactionModel> transactions,
  ) {
    final byCategory = <String, double>{};
    double total = 0;
    for (final t in transactions) {
      final tag = t.tag ?? 'Other';
      final amt = _absRupees(t);
      byCategory[tag] = (byCategory[tag] ?? 0) + amt;
      total += amt;
    }

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you spent on',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty || total == 0)
            _buildEmptyChartState(theme, 'No spending to show yet')
          else ...[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        for (int i = 0; i < entries.length; i++)
                          PieChartSectionData(
                            value: entries[i].value,
                            color: _categoryColors[i % _categoryColors.length],
                            showTitle: false,
                            radius: 30,
                          ),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 400),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(entries.length, (i) {
              final pct = total == 0 ? 0 : (entries[i].value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _categoryColors[i % _categoryColors.length],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
