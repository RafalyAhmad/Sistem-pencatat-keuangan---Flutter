import 'package:flutter/material.dart';
import 'package:money_tracker_1/model/money_model.dart';
import 'screen_statistics.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final ValueNotifier<List<MoneyModel>> myMoney = ValueNotifier([]);
  final ValueNotifier<double> totalIncome = ValueNotifier(0.0);
  final ValueNotifier<double> totalExpense = ValueNotifier(0.0);
  final ValueNotifier<double> totalBalance = ValueNotifier(0.0);

  final _formKey = GlobalKey<FormState>();
  final transactioncontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  String? selectedType;
  String? selectedCategory;

  final List<String> categories = ["Makanan", "Transport", "Tagihan"];

  @override
  void initState() {
    super.initState();
    myMoney.addListener(calculateValues);
  }

  void calculateValues() {
    double income = 0.0;
    double expense = 0.0;

    for (var t in myMoney.value) {
      final amt = double.tryParse(t.transactionAmount) ?? 0.0;

      if (t.transactionType == "Income") {
        income += amt;
      } else {
        expense += amt;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Money Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<double>(
              valueListenable: totalBalance,
              builder: (_, v, __) => Text(
                "Saldo: Rp.${v.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: totalIncome,
              builder: (_, v, __) => Text(
                "Income: Rp.${v.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: totalExpense,
              builder: (_, v, __) => Text(
                "Expense: Rp.${v.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticsScreen(myMoney: myMoney),
              ),
            ),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: myMoney,
        builder: (_, List<MoneyModel> value, __) {
          if (value.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }

          return ListView.separated(
            itemCount: value.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final t = value[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(t.transactionNarration),
                subtitle: Text(
                  "${t.transactionType} | ${t.transactionCategory} | Rp.${t.transactionAmount}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    myMoney.value = List.from(myMoney.value)..removeAt(index);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          transactioncontroller.clear();
          amountcontroller.clear();
          selectedType = null;
          selectedCategory = null;

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text("Add Transaction"),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: transactioncontroller,
                        validator: (v) =>
                            v!.isEmpty ? "Enter transaction" : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Transaction Name",
                        ),
                      ),
                      const SizedBox(height: 12),

                      // TYPE SELECTOR
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: ["Income", "Expense"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        validator: (v) => v == null ? "Select type" : null,
                        onChanged: (v) {
                          setState(() {
                            selectedType = v;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Type",
                        ),
                      ),

                      const SizedBox(height: 12),

                      // CATEGORY SELECTOR – hanya wajib jika Expense
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        validator: (v) {
                          if (selectedType == "Expense") {
                            return v == null ? "Select category" : null;
                          }
                          return null; // Income bebas tanpa kategori
                        },
                        onChanged: (v) => selectedCategory = v,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Category (Expense only)",
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: amountcontroller,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Enter amount" : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Amount",
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newData = MoneyModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          transactionNarration: transactioncontroller.text,
                          transactionType: selectedType!,
                          transactionAmount: amountcontroller.text,

                          // Auto-category untuk Income
                          transactionCategory: selectedType == "Income"
                              ? "Income"
                              : selectedCategory!,
                        );

                        myMoney.value = [...myMoney.value, newData];
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
