import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
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
    final catColor = _parseHexColor(category.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? catColor : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? catColor : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: catColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconData(category.icon),
              color: isSelected ? Colors.white : catColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
