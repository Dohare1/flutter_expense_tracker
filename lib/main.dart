import 'package:flutter/material.dart';
import 'category_page.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        navigatorKey: navigatorKey,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyHomePage({
    super.key,
    required this.title,
    required this.navigatorKey,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> categories = [
    {'name': 'Tax', 'icon': Icons.receipt_long},
    {'name': 'Automobile', 'icon': Icons.directions_car},
    {'name': 'Medical', 'icon': Icons.medical_services},
    {'name': 'Transport', 'icon': Icons.emoji_transportation},
    {'name': 'Investment', 'icon': Icons.trending_up},
    {'name': 'Savings', 'icon': Icons.savings},
    {'name': 'Shopping', 'icon': Icons.shopping_cart},
    {'name': 'Personal', 'icon': Icons.person},
    {'name': 'Food', 'icon': Icons.fastfood},
  ];

  List<Map<String, dynamic>> transactions = [];

  // Helper to parse date string to DateTime
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime(1970, 1, 1);
    try {
      // Try parsing with common formats
      return DateTime.parse(dateStr);
    } catch (_) {
      // Fallback: try dd/MM/yyyy
      try {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
    return DateTime(1970, 1, 1);
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTransaction(
    Map<String, dynamic> transaction, {
    bool fromCategoryPage = false,
  }) {
    setState(() {
      transactions.add(transaction);
      if (fromCategoryPage) {
        _selectedIndex = 2; // Transactions tab
        // Show success dialog after adding expense
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Expense added successfully!'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Go to add new expense (Home tab)
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                ],
              );
            },
          );
        });
      }
    });
  }

  Widget _buildHomeTab() {
    final crossAxisCount = MediaQuery.of(context).size.width < 400 ? 2 : 3;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryPage(selectedCategory: category['name']),
                      ),
                    );
                    if (result is Map<String, dynamic>) {
                      _addTransaction(result, fromCategoryPage: true);
                      // Optionally show dialog for repeat entry, but not required for basic add
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 8.0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha((255 * 0.1).toInt()),
                              child: Icon(
                                category['icon'],
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTab() {
    // Date filter options
    final List<String> dateFilters = ['All', 'Today', 'This Month', 'Custom'];
    String selectedFilter = 'All';
    DateTime? customStart;
    DateTime? customEnd;

    // Filter transactions by selected date range
    List<Map<String, dynamic>> filteredTx = transactions.where((tx) {
      DateTime txDate = _parseDate(tx['date']);
      if (selectedFilter == 'Today') {
        DateTime now = DateTime.now();
        return txDate.year == now.year &&
            txDate.month == now.month &&
            txDate.day == now.day;
      } else if (selectedFilter == 'This Month') {
        DateTime now = DateTime.now();
        return txDate.year == now.year && txDate.month == now.month;
      } else if (selectedFilter == 'Custom' &&
          customStart != null &&
          customEnd != null) {
        return txDate.isAfter(customStart!.subtract(Duration(days: 1))) &&
            txDate.isBefore(customEnd!.add(Duration(days: 1)));
      }
      return true;
    }).toList();

    // Calculate total spent per category
    Map<String, double> categoryTotals = {};
    for (var tx in filteredTx) {
      final cat = tx['category'] as String? ?? '';
      final amt = tx['amount'] as double? ?? 0.0;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amt;
    }

    final totalSpent = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final chartSections = <PieChartSectionData>[];
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.brown,
    ];
    int colorIdx = 0;
    categoryTotals.forEach((cat, amt) {
      if (amt > 0) {
        chartSections.add(
          PieChartSectionData(
            color: colors[colorIdx % colors.length],
            value: amt,
            title: cat,
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIdx++;
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text('Filter: ', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: dateFilters
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      selectedFilter = val;
                      if (val != 'Custom') {
                        customStart = null;
                        customEnd = null;
                      }
                    });
                    if (val == 'Custom') {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((range) {
                        if (range != null) {
                          setState(() {
                            customStart = range.start;
                            customEnd = range.end;
                          });
                        }
                      });
                    }
                  },
                ),
                if (selectedFilter == 'Custom' &&
                    customStart != null &&
                    customEnd != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${customStart != null ? customStart!.toLocal().toString().split(' ')[0] : ''} - ${customEnd != null ? customEnd!.toLocal().toString().split(' ')[0] : ''}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (totalSpent == 0)
              Center(
                child: Text('No expenses yet', style: TextStyle(fontSize: 16)),
              )
            else ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: chartSections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Total Spent: ₹${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ...categoryTotals.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: TextStyle(fontSize: 15)),
                      Text(
                        '₹${e.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildTransactionsTab() {
    // Sort transactions by date descending (most recent at the top)
    List<Map<String, dynamic>> sortedTransactions = List.from(transactions);
    sortedTransactions.sort((a, b) {
      DateTime dateA = _parseDate(a['date']);
      DateTime dateB = _parseDate(b['date']);
      return dateB.compareTo(dateA); // descending
    });
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: sortedTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: sortedTransactions.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tx = sortedTransactions[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 18,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((255 * 0.15).toInt()),
                                  child: Icon(
                                    Icons.category,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 26,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx['subject'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        tx['category'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        tx['date'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 14),
                                Text(
                                  '₹${tx['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.grey[700],
                                  ),
                                  tooltip: 'Edit',
                                  onPressed: () async {
                                    final updatedTx =
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => CategoryPage(
                                              selectedCategory: tx['category'],
                                              initialDate: tx['date'],
                                              initialSubject: tx['subject'],
                                              initialAmount: tx['amount'],
                                            ),
                                          ),
                                        );
                                    if (updatedTx is Map<String, dynamic>) {
                                      setState(() {
                                        transactions[index] = updatedTx;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return Center(child: Text('My Account', style: TextStyle(fontSize: 24)));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _buildHomeTab(),
      _buildSpendingTab(),
      _buildTransactionsTab(),
      _buildAccountTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Expense Tracker'),
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Spending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'My Account',
          ),
        ],
      ),
    );
  }
}
