import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/category_chip.dart';
import 'add_expense_screen.dart';
import 'stats_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StorageService.checkLowStorage(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final authState = ref.watch(authProvider);

    final List<Widget> pages = [
      _buildDashboard(context, expenseState, authState),
      const StatsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0713), // Ultra dark obsidian background
      body: SafeArea(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.03),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF0F0C1B),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white38,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoIcons.square_grid_2x2
                    : Icons.space_dashboard_outlined),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? CupertinoIcons.square_grid_2x2_fill
                        : Icons.space_dashboard,
                    color: Colors.tealAccent),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoIcons.chart_bar
                    : Icons.analytics_outlined),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? CupertinoIcons.chart_bar_fill
                        : Icons.analytics,
                    color: Colors.tealAccent),
              ),
              label: 'Analytics',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                );
              },
              backgroundColor: Colors.tealAccent,
              foregroundColor: const Color(0xFF0F0C1B),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildDashboard(BuildContext context, ExpenseState state, AuthState auth) {
    // Calculate total spent
    final totalSpent = state.expenses.fold<double>(0, (sum, item) => sum + item.amount);

    // Get current month's overall budget (where category_id is null)
    final overallBudgetModel = state.budgets.firstWhere(
      (b) => b.categoryId == null,
      orElse: () => BudgetModel(id: -1, amount: 0, month: state.selectedMonth, userId: -1),
    );
    final overallBudget = overallBudgetModel.amount;
    
    final remaining = overallBudget > 0 ? (overallBudget - totalSpent) : 0.0;
    final progress = overallBudget > 0 ? (totalSpent / overallBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = totalSpent > overallBudget && overallBudget > 0;

    final formattedMonth = _formatSelectedMonth(state.selectedMonth);

    // Group expenses by Date for a timeline design
    final groupedExpenses = <String, List<ExpenseModel>>{};
    for (var exp in state.expenses) {
      final dateStr = DateFormat('yyyy-MM-dd').format(exp.date);
      if (!groupedExpenses.containsKey(dateStr)) {
        groupedExpenses[dateStr] = [];
      }
      groupedExpenses[dateStr]!.add(exp);
    }
    final dateKeys = groupedExpenses.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium Profile Header (Sticky at top)
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

        // Scrollable Body (Budget card, month, categories and transactions scroll together)
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Glowing Glass Budget Balance Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E1C30), // Dark Indigo-Violet mesh
                          Color(0xFF121422), // Deep Obsidian
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isOverBudget
                            ? Colors.redAccent.withOpacity(0.25)
                            : Colors.tealAccent.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isOverBudget
                              ? Colors.redAccent.withOpacity(0.08)
                              : Colors.tealAccent.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.credit_card_outlined, color: Colors.white30, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'SPENDWISE WALLET',
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOverBudget
                                    ? Colors.redAccent.withOpacity(0.1)
                                    : (overallBudget > 0 ? Colors.greenAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isOverBudget
                                      ? Colors.redAccent.withOpacity(0.2)
                                      : (overallBudget > 0 ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                isOverBudget
                                    ? 'OVER LIMIT'
                                    : (overallBudget > 0 ? 'ON TRACK' : 'NO LIMIT SET'),
                                style: TextStyle(
                                  color: isOverBudget
                                      ? Colors.redAccent
                                      : (overallBudget > 0 ? Colors.greenAccent : Colors.white38),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Total spent big amount
                        const Text(
                          'TOTAL EXPENSES',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalSpent.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Bottom row splits
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BUDGET LIMIT',
                                    style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _showSetBudgetDialog(context, overallBudget),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          overallBudget > 0 ? '₹${overallBudget.toStringAsFixed(0)}' : 'Set Limit',
                                          style: const TextStyle(
                                            color: Colors.tealAccent,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.mode_edit_outline, color: Colors.tealAccent, size: 12),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withOpacity(0.08),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOverBudget ? 'EXCEEDED BY' : 'SAFE BALANCE',
                                    style: TextStyle(
                                      color: isOverBudget ? Colors.redAccent.withOpacity(0.7) : Colors.white38,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOverBudget
                                        ? '₹${(totalSpent - overallBudget).toStringAsFixed(0)}'
                                        : (overallBudget > 0 ? '₹${remaining.toStringAsFixed(0)}' : 'N/A'),
                                    style: TextStyle(
                                      color: isOverBudget ? Colors.redAccent : Colors.greenAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Progress bar tracker
                        if (overallBudget > 0) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                isOverBudget ? 'Warning! Exceeded limit' : 'Safe to spend',
                                style: TextStyle(
                                  color: isOverBudget ? Colors.redAccent.withOpacity(0.8) : Colors.tealAccent.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isOverBudget
                                        ? [Colors.redAccent, Colors.orangeAccent]
                                        : [Colors.tealAccent, Colors.greenAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isOverBudget
                                          ? Colors.redAccent.withOpacity(0.2)
                                          : Colors.tealAccent.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Elegant Month Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171725),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white60, size: 14),
                            onPressed: () => _changeMonthOffset(-1),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showMonthPicker(context, state.selectedMonth),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Colors.tealAccent, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                formattedMonth.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.04)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 14),
                            onPressed: () => _changeMonthOffset(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 12),
              ),

              // Category Horizontal Selector
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    itemCount: state.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = state.filterCategoryId == null;
                        return GestureDetector(
                          onTap: () => ref.read(expenseProvider.notifier).filterByCategory(null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.tealAccent : const Color(0xFF1E1E2C),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.tealAccent : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'All Expenses',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF0F0C1B) : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final category = state.categories[index - 1];
                      return CategoryChip(
                        category: category,
                        isSelected: state.filterCategoryId == category.id,
                        onTap: () => ref.read(expenseProvider.notifier).filterByCategory(category.id),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 18),
              ),

              // Expenses Header Title
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 10),
              ),

              // Grouped Timeline Expense List
              if (state.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
                  ),
                )
              else if (state.expenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 52, color: Colors.white.withOpacity(0.15)),
                          const SizedBox(height: 12),
                          const Text(
                            'No items registered this month.',
                            style: TextStyle(color: Colors.white30, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, dateIndex) {
                      final dateKey = dateKeys[dateIndex];
                      final dayExpenses = groupedExpenses[dateKey]!;
                      final headerDate = DateTime.parse(dateKey);
                      final formattedHeader = _formatDateHeader(headerDate);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Timeline Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                              child: Text(
                                formattedHeader,
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            // List of cards on this date
                            ...dayExpenses.map((expense) {
                              return ExpenseCard(
                                expense: expense,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(expense: expense),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  ref.read(expenseProvider.notifier).deleteExpense(expense.id);
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                    childCount: dateKeys.length,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String val, Color valColor, {VoidCallback? onAction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onAction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                val,
                style: TextStyle(
                  color: valColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  decoration: onAction != null ? TextDecoration.underline : null,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.mode_edit_outline, color: Colors.tealAccent, size: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatSelectedMonth(String yyyyMM) {
    try {
      final date = DateFormat('yyyy-MM').parse(yyyyMM);
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return yyyyMM;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'TODAY';
    } else if (checkDate == yesterday) {
      return 'YESTERDAY';
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(date).toUpperCase();
    }
  }

  void _changeMonthOffset(int offset) {
    final state = ref.read(expenseProvider);
    try {
      final date = DateFormat('yyyy-MM').parse(state.selectedMonth);
      final newDate = DateTime(date.year, date.month + offset, 1);
      final newMonthStr = DateFormat('yyyy-MM').format(newDate);
      ref.read(expenseProvider.notifier).changeMonth(newMonthStr);
    } catch (_) {}
  }

  void _showMonthPicker(BuildContext context, String currentMonthStr) async {
    final firstDate = DateTime(DateTime.now().year - 20, 1, 1);
    final initialDate = DateFormat('yyyy-MM').parse(currentMonthStr);
    final safeInitialDate = initialDate.isBefore(firstDate) ? firstDate : initialDate;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          DateTime tempDate = safeInitialDate;
          return Container(
            height: 300,
            color: const Color(0xFF161625),
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF1B1B2C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Done', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final newMonthStr = DateFormat('yyyy-MM').format(tempDate);
                          ref.read(expenseProvider.notifier).changeMonth(newMonthStr);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: safeInitialDate,
                      minimumDate: firstDate,
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (DateTime newDate) {
                        tempDate = newDate;
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: safeInitialDate,
        firstDate: firstDate,
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.tealAccent,
                onPrimary: Color(0xFF0F0C1B),
                surface: Color(0xFF1E1E2C),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        final newMonthStr = DateFormat('yyyy-MM').format(picked);
        ref.read(expenseProvider.notifier).changeMonth(newMonthStr);
      }
    }
  }

  void _showSetBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161625),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.tealAccent.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.04),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 12, 24, 28 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle Indicator
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon & Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.savings_outlined, color: Colors.tealAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Set Monthly Budget',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Enter your budget limit for this month. We will notify you when expenses approach this range.',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              
              // Styled input field
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  labelStyle: TextStyle(color: Colors.tealAccent.withOpacity(0.7), fontSize: 13),
                  hintText: 'Enter limit (e.g. 5000)',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  prefixIcon: const Icon(Icons.currency_rupee, color: Colors.tealAccent, size: 18),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.02),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.tealAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.tealAccent, Color(0xFF00E676)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          final amt = double.tryParse(controller.text.trim());
                          if (amt != null && amt > 0) {
                            final month = ref.read(expenseProvider).selectedMonth;
                            await ref.read(expenseProvider.notifier).setBudget(amount: amt, month: month);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          }
                        },
                        child: const Text(
                          'Save Limit',
                          style: TextStyle(
                            color: Color(0xFF0F0C1B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
