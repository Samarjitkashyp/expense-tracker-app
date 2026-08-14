import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final catColor = _parseHexColor(expense.category.color);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('expense_${expense.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            title: const Text('Delete Expense', style: TextStyle(color: Colors.white)),
            content: const Text('Are you sure you want to delete this expense?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container with dynamic category color
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: catColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getIconData(expense.category.icon),
                  color: catColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Description and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description?.isNotEmpty == true
                          ? expense.description!
                          : expense.category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          expense.category.name,
                          style: TextStyle(
                            color: catColor.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(expense.date),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                '₹${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
