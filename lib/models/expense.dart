import 'dart:convert';

class UserModel {
  final int id;
  final String username;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String color; // Hex string like #FF9800
  final String icon;  // Icon name like restaurant, directions_car
  final int? userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'user_id': userId,
    };
  }
}

class ExpenseModel {
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final int userId;
  final int categoryId;
  final CategoryModel category;

  ExpenseModel({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.userId,
    required this.categoryId,
    required this.category,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // yyyy-MM-dd
      'user_id': userId,
      'category_id': categoryId,
      'category': category.toJson(),
    };
  }
}

class BudgetModel {
  final int id;
  final double amount;
  final String month; // YYYY-MM
  final int userId;
  final int? categoryId;
  final CategoryModel? category;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.month,
    required this.userId,
    this.categoryId,
    this.category,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'user_id': userId,
      'category_id': categoryId,
      'category': category?.toJson(),
    };
  }
}

class CategoryStats {
  final int categoryId;
  final String categoryName;
  final String color;
  final String icon;
  final double totalAmount;
  final double percentage;

  CategoryStats({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.icon,
    required this.totalAmount,
    required this.percentage,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class ExpenseStatsModel {
  final double totalSpent;
  final List<CategoryStats> byCategory;

  ExpenseStatsModel({
    required this.totalSpent,
    required this.byCategory,
  });

  factory ExpenseStatsModel.fromJson(Map<String, dynamic> json) {
    var list = json['by_category'] as List;
    List<CategoryStats> categoryList =
        list.map((i) => CategoryStats.fromJson(i as Map<String, dynamic>)).toList();

    return ExpenseStatsModel(
      totalSpent: (json['total_spent'] as num).toDouble(),
      byCategory: categoryList,
    );
  }
}

class MonthlyBudgetVsExpenseModel {
  final String month;
  final double budgetAmount;
  final double expenseAmount;

  MonthlyBudgetVsExpenseModel({
    required this.month,
    required this.budgetAmount,
    required this.expenseAmount,
  });

  factory MonthlyBudgetVsExpenseModel.fromJson(Map<String, dynamic> json) {
    return MonthlyBudgetVsExpenseModel(
      month: json['month'] as String,
      budgetAmount: (json['budget_amount'] as num).toDouble(),
      expenseAmount: (json['expense_amount'] as num).toDouble(),
    );
  }
}
