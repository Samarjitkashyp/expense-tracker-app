import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({Key? key}) : super(key: key);

  Color _parseHexColor(String hexStr) {
    try {
      final buffer = StringBuffer();
      if (hexStr.length == 7) {
        buffer.write('ff');
        buffer.write(hexStr.substring(1));
      } else if (hexStr.length == 9) {
        buffer.write(hexStr.substring(1));
      } else {
        return Colors.grey;
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie_filter;
      case 'receipt':
        return Icons.receipt_long;
      case 'attach_money':
        return Icons.monetization_on;
      case 'school':
        return Icons.school;
      case 'medical_services':
        return Icons.medical_services;
      case 'home':
        return Icons.home;
      default:
        return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);
    final auth = ref.watch(authProvider);
    final stats = expenseState.stats;
    final comparison = expenseState.monthlyComparison;

    if (expenseState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
    }

    final totalSpent = expenseState.expenses.fold<double>(0, (sum, item) => sum + item.amount);

    // Get current month's overall budget
    final overallBudgetModel = expenseState.budgets.firstWhere(
      (b) => b.categoryId == null,
      orElse: () => BudgetModel(id: -1, amount: 0, month: expenseState.selectedMonth, userId: -1),
    );
    final overallBudget = overallBudgetModel.amount;
    final remaining = overallBudget > 0 ? (overallBudget - totalSpent) : 0.0;
    final progress = overallBudget > 0 ? (totalSpent / overallBudget) : 0.0;
    final isOverBudget = totalSpent > overallBudget && overallBudget > 0;

    // Calculate Weekly Spending
    final weeklySpending = [0.0, 0.0, 0.0, 0.0];
    for (var exp in expenseState.expenses) {
      final day = exp.date.day;
      if (day <= 7) {
        weeklySpending[0] += exp.amount;
      } else if (day <= 14) {
        weeklySpending[1] += exp.amount;
      } else if (day <= 21) {
        weeklySpending[2] += exp.amount;
      } else {
        weeklySpending[3] += exp.amount;
      }
    }

    // Calculate Daily Average
    final currentDay = DateTime.now().day;
    final dailyAvg = totalSpent > 0 ? (totalSpent / currentDay) : 0.0;

    // Get Top Category details
    CategoryStats? topCategory;
    if (stats != null && stats.byCategory.isNotEmpty) {
      topCategory = stats.byCategory.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium Profile Header (Sticky at top, matches Home Screen)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF1E1E2C),
                      child: Text(
                        auth.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${auth.user?.username ?? "User"} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Welcome to your finance hub',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Logout Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              )
            ],
          ),
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Secondary Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Financial Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Report for ${_formatMonth(expenseState.selectedMonth)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const Icon(Icons.insights, color: Colors.tealAccent, size: 20),
                  ],
                ),

          const SizedBox(height: 20),

          // 1. Health Status Advice Banner
          _buildHealthStatusBanner(overallBudget, totalSpent, progress, isOverBudget, remaining),

          const SizedBox(height: 20),

          // 2. Metrics Grid Row (Daily Average, Top Category, Savings)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Daily Average',
                  '₹${dailyAvg.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: topCategory != null
                    ? _buildMetricTile(
                        'Top Category',
                        topCategory.categoryName,
                        _getIconData(topCategory.icon),
                        _parseHexColor(topCategory.color),
                        subtext: '₹${topCategory.totalAmount.toStringAsFixed(0)} spent',
                      )
                    : _buildMetricTile(
                        'Top Category',
                        'None',
                        Icons.category_outlined,
                        Colors.purpleAccent,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  'Saved Amount',
                  overallBudget > 0
                      ? (remaining > 0 ? '₹${remaining.toStringAsFixed(0)}' : '₹0')
                      : 'N/A',
                  Icons.savings_outlined,
                  Colors.greenAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Weekly Spending Line Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Spending Trend',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (expenseState.expenses.isEmpty) ...[
                  const SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        'No transaction data this month',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  )
                ] else ...[
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final wIdx = val.toInt();
                                if (wIdx >= 1 && wIdx <= 4) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Wk $wIdx', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(1, weeklySpending[0]),
                              FlSpot(2, weeklySpending[1]),
                              FlSpot(3, weeklySpending[2]),
                              FlSpot(4, weeklySpending[3]),
                            ],
                            isCurved: true,
                            color: Colors.tealAccent,
                            barWidth: 3.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.tealAccent.withOpacity(0.06),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Category Pie Chart Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category Share',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (stats == null || stats.byCategory.isEmpty) ...[
                  const SizedBox(
                    height: 140,
                    child: Center(
                      child: Text('No transaction history', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ),
                  )
                ] else ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: stats.byCategory.map((catStat) {
                              return PieChartSectionData(
                                color: _parseHexColor(catStat.color),
                                value: catStat.totalAmount,
                                title: '${catStat.percentage.toStringAsFixed(0)}%',
                                radius: 26,
                                titleStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: stats.byCategory.take(4).map((catStat) {
                            final catColor = _parseHexColor(catStat.color);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      catStat.categoryName,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '₹${catStat.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Monthly Trends (Budget vs Actual) Bar Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Budget vs Spend Trends',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (comparison.isEmpty) ...[
                  const SizedBox(
                    height: 160,
                    child: Center(
                      child: Text('Not enough details available', style: TextStyle(color: Colors.white38)),
                    ),
                  )
                ] else ...[
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(comparison),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF131320),
                            tooltipBorder: BorderSide(
                              color: Colors.tealAccent.withOpacity(0.3),
                              width: 1,
                            ),
                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final monthData = comparison[group.x.toInt()];
                              final isBudget = rodIndex == 0;
                              final typeLabel = isBudget ? 'Budget Limit' : 'Actual Spent';
                              final labelColor = isBudget ? Colors.tealAccent.withOpacity(0.6) : (
                                  monthData.expenseAmount > monthData.budgetAmount && monthData.budgetAmount > 0
                                      ? Colors.redAccent
                                      : Colors.tealAccent
                              );
                              return BarTooltipItem(
                                '${_formatShortMonth(monthData.month)} ${monthData.month.split('-')[0]}\n',
                                const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$typeLabel: ₹${rod.toY.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: labelColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < comparison.length) {
                                  final monthStr = comparison[index].month;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _formatShortMonth(monthStr),
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: comparison.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: idx,
                            barRods: [
                              BarChartRodData(
                                toY: data.budgetAmount,
                                color: Colors.tealAccent.withOpacity(0.3),
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: data.expenseAmount,
                                color: data.expenseAmount > data.budgetAmount && data.budgetAmount > 0
                                    ? Colors.redAccent
                                    : Colors.tealAccent,
                                width: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, color: Colors.tealAccent.withOpacity(0.3)),
                      const SizedBox(width: 6),
                      const Text('Limit / Budget', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      const SizedBox(width: 20),
                      Container(width: 8, height: 8, color: Colors.tealAccent),
                      const SizedBox(width: 6),
                      const Text('Spent Amount', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ],
              ],
            ),
          ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatusBanner(
      double budget, double spent, double progress, bool isOverBudget, double remaining) {
    if (budget == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blueAccent, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set a monthly budget on the dashboard to calculate your financial health index.',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    String title;
    String description;
    IconData icon;
    Color color;

    if (isOverBudget) {
      title = 'Over Budget!';
      description = 'You have exceeded your limit by ₹${(spent - budget).toStringAsFixed(0)}. Minimize shopping and eating out.';
      icon = Icons.warning_amber_rounded;
      color = Colors.redAccent;
    } else if (progress >= 0.85) {
      title = 'Budget Warning!';
      description = 'You have used ${(progress * 100).toStringAsFixed(0)}% of your budget. Only ₹${remaining.toStringAsFixed(0)} left.';
      icon = Icons.error_outline;
      color = Colors.orangeAccent;
    } else {
      title = 'On Track!';
      description = 'You have used ${(progress * 100).toStringAsFixed(0)}% of your budget. You are saving well this month!';
      icon = Icons.check_circle_outline_rounded;
      color = Colors.greenAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.02), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color, {String? subtext}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtext ?? label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<MonthlyBudgetVsExpenseModel> list) {
    double maxVal = 1000;
    for (var item in list) {
      if (item.budgetAmount > maxVal) maxVal = item.budgetAmount;
      if (item.expenseAmount > maxVal) maxVal = item.expenseAmount;
    }
    return maxVal * 1.15; // Give 15% headroom
  }

  String _formatMonth(String yyyyMM) {
    try {
      final date = DateFormat('yyyy-MM').parse(yyyyMM);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return yyyyMM;
    }
  }

  String _formatShortMonth(String yyyyMM) {
    try {
      final date = DateFormat('yyyy-MM').parse(yyyyMM);
      return DateFormat('MMM').format(date);
    } catch (_) {
      return yyyyMM;
    }
  }
}
