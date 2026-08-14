import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense; // If provided, we are in Edit mode

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final exp = widget.expense!;
      _amountController.text = exp.amount.toStringAsFixed(0);
      _descriptionController.text = exp.description ?? '';
      _selectedCategoryId = exp.categoryId;
      _selectedDate = exp.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final firstDate = DateTime(DateTime.now().year - 20, 1, 1);
    final initialDate = _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          DateTime tempDate = initialDate;
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
                          setState(() {
                            _selectedDate = tempDate;
                          });
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
                      initialDateTime: initialDate,
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
        initialDate: initialDate,
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
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    final description = _descriptionController.text.trim();
    final expenseNotifier = ref.read(expenseProvider.notifier);
    bool success;

    if (_isEditMode) {
      success = await expenseNotifier.updateExpense(
        expenseId: widget.expense!.id,
        amount: amount,
        description: description,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
      );
    } else {
      success = await expenseNotifier.addExpense(
        amount: amount,
        description: description.isEmpty ? null : description,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Expense updated!' : 'Expense added!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);

    // Seed default selection if null and categories are available
    if (_selectedCategoryId == null && expenseState.categories.isNotEmpty) {
      _selectedCategoryId = expenseState.categories.first.id;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: const Color(0xFF0F0C1B),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
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
                if (confirm == true) {
                  final success = await ref.read(expenseProvider.notifier).deleteExpense(widget.expense!.id);
                  if (success && mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Input Field (Big font size)
              Center(
                child: Column(
                  children: [
                    const Text('Amount Spent', style: TextStyle(color: Colors.white38, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('₹', style: TextStyle(color: Colors.tealAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 180,
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.white12),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter amount';
                              }
                              final amt = double.tryParse(value.trim());
                              if (amt == null || amt <= 0) {
                                return 'Invalid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Category Selection Grid Header
              const Text('Select Category', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Categories Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: expenseState.categories.length,
                  itemBuilder: (context, index) {
                    final cat = expenseState.categories[index];
                    final isSel = _selectedCategoryId == cat.id;
                    final catColor = _parseHexColor(cat.color);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSel ? catColor.withOpacity(0.15) : const Color(0xFF131320),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? catColor : Colors.white.withOpacity(0.05),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconData(cat.icon),
                              color: isSel ? catColor : Colors.white60,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white54,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Description notes field
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Notes / Description',
                  labelStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.tealAccent),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Picker Trigger
              InkWell(
                onTap: _presentDatePicker,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.tealAccent, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Save Button
              ElevatedButton(
                onPressed: expenseState.isActionLoading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: const Color(0xFF0F0C1B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                child: expenseState.isActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Color(0xFF0F0C1B), strokeWidth: 2),
                      )
                    : Text(
                        _isEditMode ? 'Save Changes' : 'Add Transaction',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
