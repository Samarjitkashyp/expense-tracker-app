import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'auth_provider.dart';

class ExpenseState {
  final bool isLoading;
  final bool isActionLoading;
  final List<ExpenseModel> expenses;
  final List<CategoryModel> categories;
  final List<BudgetModel> budgets;
  final ExpenseStatsModel? stats;
  final List<MonthlyBudgetVsExpenseModel> monthlyComparison;
  final String selectedMonth; // format "YYYY-MM"
  final int? filterCategoryId;
  final String? errorMessage;

  ExpenseState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.expenses = const [],
    this.categories = const [],
    this.budgets = const [],
    this.stats,
    this.monthlyComparison = const [],
    required this.selectedMonth,
    this.filterCategoryId,
    this.errorMessage,
  });

  ExpenseState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<ExpenseModel>? expenses,
    List<CategoryModel>? categories,
    List<BudgetModel>? budgets,
    ExpenseStatsModel? stats,
    List<MonthlyBudgetVsExpenseModel>? monthlyComparison,
    String? selectedMonth,
    int? filterCategoryId,
    bool clearFilterCategory = false,
    String? errorMessage,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      expenses: expenses ?? this.expenses,
      categories: categories ?? this.categories,
      budgets: budgets ?? this.budgets,
      stats: stats ?? this.stats,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      filterCategoryId: clearFilterCategory ? null : (filterCategoryId ?? this.filterCategoryId),
      errorMessage: errorMessage, // Reset error if not explicitly supplied
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final Ref _ref;

  ExpenseNotifier(this._ref)
      : super(ExpenseState(selectedMonth: DateFormat('yyyy-MM').format(DateTime.now()))) {
    // Automatically load data when initialized
    refreshAll();
  }

  Dio get _dio => _ref.read(apiServiceProvider).dio;

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.wait([
        loadCategories(),
        loadExpenses(),
        loadBudgets(),
        loadStats(),
        loadBudgetVsExpenses(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _dio.get('/categories');
      final list = response.data as List;
      final categories = list.map((i) => CategoryModel.fromJson(i as Map<String, dynamic>)).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<void> loadExpenses() async {
    try {
      // Build parameters based on current month filter
      // Get first and last day of selectedMonth
      final parts = state.selectedMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0); // Last day of month

      final params = {
        'start_date': DateFormat('yyyy-MM-dd').format(start),
        'end_date': DateFormat('yyyy-MM-dd').format(end),
      };

      if (state.filterCategoryId != null) {
        params['category_id'] = state.filterCategoryId!.toString();
      }

      final response = await _dio.get('/expenses', queryParameters: params);
      final list = response.data as List;
      final expenses = list.map((i) => ExpenseModel.fromJson(i as Map<String, dynamic>)).toList();
      state = state.copyWith(expenses: expenses);
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  Future<void> loadBudgets() async {
    try {
      final response = await _dio.get('/budgets', queryParameters: {'month': state.selectedMonth});
      final list = response.data as List;
      final budgets = list.map((i) => BudgetModel.fromJson(i as Map<String, dynamic>)).toList();
      state = state.copyWith(budgets: budgets);
    } catch (e) {
      throw Exception('Failed to load budgets: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _dio.get('/expenses/stats', queryParameters: {'month': state.selectedMonth});
      final stats = ExpenseStatsModel.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(stats: stats);
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }

  Future<void> loadBudgetVsExpenses() async {
    try {
      final response = await _dio.get('/budgets/vs-expenses');
      final list = response.data as List;
      final comparison = list.map((i) => MonthlyBudgetVsExpenseModel.fromJson(i as Map<String, dynamic>)).toList();
      state = state.copyWith(monthlyComparison: comparison);
    } catch (e) {
      throw Exception('Failed to load monthly summary: $e');
    }
  }

  // --- ACTIONS ---

  void changeMonth(String month) {
    state = state.copyWith(selectedMonth: month);
    refreshAll();
  }

  void filterByCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearFilterCategory: true);
    } else {
      state = state.copyWith(filterCategoryId: categoryId);
    }
    loadExpenses();
  }

  Future<bool> addExpense({
    required double amount,
    required String? description,
    required DateTime date,
    required int categoryId,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _dio.post('/expenses', data: {
        'amount': amount,
        'description': description,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'category_id': categoryId,
      });
      await refreshAll();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Failed to add expense: $e');
      return false;
    }
  }

  Future<bool> updateExpense({
    required int expenseId,
    required double amount,
    required String? description,
    required DateTime date,
    required int categoryId,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _dio.put('/expenses/$expenseId', data: {
        'amount': amount,
        'description': description,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'category_id': categoryId,
      });
      await refreshAll();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Failed to update expense: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _dio.delete('/expenses/$expenseId');
      await refreshAll();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Failed to delete expense: $e');
      return false;
    }
  }

  Future<bool> addCategory({
    required String name,
    required String color,
    required String icon,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _dio.post('/categories', data: {
        'name': name,
        'color': color,
        'icon': icon,
      });
      await loadCategories();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Failed to create category: $e');
      return false;
    }
  }

  Future<bool> setBudget({
    required double amount,
    required String month,
    int? categoryId,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      await _dio.post('/budgets', data: {
        'amount': amount,
        'month': month,
        'category_id': categoryId,
      });
      await Future.wait([
        loadBudgets(),
        loadBudgetVsExpenses(),
      ]);
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Failed to set budget: $e');
      return false;
    }
  }
}

// Global provider for expenses
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final authState = ref.watch(authProvider);
  final notifier = ExpenseNotifier(ref);
  if (authState.isAuthenticated) {
    Future.microtask(() => notifier.refreshAll());
  }
  return notifier;
});
