import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef TransactionCallback = void Function(Map<String, dynamic> transaction);

class CategoryPage extends StatefulWidget {
  final String selectedCategory;
  final TransactionCallback? onSubmit;
  final String? initialDate;
  final String? initialSubject;
  final double? initialAmount;
  const CategoryPage({
    super.key,
    required this.selectedCategory,
    this.onSubmit,
    this.initialDate,
    this.initialSubject,
    this.initialAmount,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String dropdownValue;
  DateTime? selectedDate;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<String> categories = [
    'Tax',
    'Automobile',
    'Medical',
    'Transport',
    'Investment',
    'Savings',
    'Shopping',
    'Personal',
    'Food',
  ];

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedCategory;
    if (widget.initialDate != null) {
      selectedDate = DateTime.tryParse(widget.initialDate!);
    } else {
      selectedDate = DateTime.now();
    }
    if (widget.initialSubject != null) {
      subjectController.text = widget.initialSubject!;
    }
    if (widget.initialAmount != null) {
      amountController.text = widget.initialAmount!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((255 * 0.07).toInt()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 18),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      selectedDate == null
                          ? 'Pick a date'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 18),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (selectedDate == null ||
                          subjectController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }
                      final amountValue = double.tryParse(
                        amountController.text,
                      );
                      if (amountValue == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Amount must be a valid number'),
                          ),
                        );
                        return;
                      }
                      final transaction = {
                        'category': dropdownValue,
                        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                        'subject': subjectController.text,
                        'amount': amountValue,
                      };
                      if (!mounted) return;
                      Navigator.pop(context, transaction);
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
