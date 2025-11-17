// ignore_for_file: body_might_complete_normally_nullable, unnecessary_null_comparison, must_be_immutable, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:money_tracker_1/model/money_model.dart';
import 'package:money_tracker_1/presentation/transaction_detail_screen.dart.dart';

class ScreenHome extends StatelessWidget {
  ScreenHome({super.key});

  // 1. ValueNotifier untuk Daftar Transaksi
  final ValueNotifier<List<MoneyModel>> myMoney = ValueNotifier([]);

  // 2. ValueNotifier BARU untuk Saldo Total
  final ValueNotifier<double> totalBalance = ValueNotifier(0.0);

  final _formKey = GlobalKey<FormState>();

  final transactioncontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  String? selectedType;

  // FUNGSI BARU: Menghitung ulang saldo total
  void calculateBalance() {
    double total = 0.0;
    for (var transaction in myMoney.value) {
      final amount = double.tryParse(transaction.transactionAmount) ?? 0.0;
      if (transaction.transactionType == 'Income') {
        total += amount;
      } else if (transaction.transactionType == 'Expense') {
        total -= amount;
      }
    }
    // Perbarui ValueNotifier Saldo
    totalBalance.value = total;
  }

  // FUNGSI BARU: Listener untuk memperbarui saldo setiap kali 'myMoney' berubah
  void setupBalanceListener() {
    myMoney.addListener(calculateBalance);
    // Jalankan pertama kali untuk saldo awal (jika ada data dummy)
    calculateBalance();
  }

  // Override metode initState atau konstruktor (karena ini StatelessWidget, kita panggil di constructor)
  // Catatan: Sebaiknya gunakan StatefulWidget dan panggil setupBalanceListener di initState
  // Namun, kita akan pertahankan StatelessWidget untuk saat ini.

  @override
  Widget build(BuildContext context) {
    // Panggil listener di build method (hati-hati, ini bisa dipanggil berkali-kali)
    // Di aplikasi nyata, pindahkan logika listener ke StatefulWidget's initState.
    // Untuk tujuan demo, ini akan bekerja karena myMoney belum memiliki listener
    if (myMoney.hasListeners == false) {
      setupBalanceListener();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 120, // Diperlebar untuk menampung saldo
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Money Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // MENGGUNAKAN ValueListenableBuilder untuk Saldo
            ValueListenableBuilder<double>(
              valueListenable: totalBalance,
              builder: (context, balance, child) {
                return Text(
                  "Saldo Total: Rp.${balance.toStringAsFixed(2)}", // Tampilkan 2 angka desimal
                  style: TextStyle(color: Colors.white, fontSize: 18),
                );
              },
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: myMoney,
        builder: (context, List<MoneyModel> value, _) {
          if (value.isEmpty) {
            return Center(child: Text("Belum ada transaksi. Tambahkan satu!"));
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              // ... (Kode ListView.separated tetap sama)
              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      value[index].transactionNarration,
                      style: TextStyle(fontSize: 25),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailScreen(
                              transaction: value[index],
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transaction Amt: Rp.${value[index].transactionAmount}",
                        ),
                        Text(
                          "Transaction Type: ${value[index].transactionType}",
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        final item = myMoney.value[index];
                        transactioncontroller.text = item.transactionNarration;
                        amountcontroller.text = item.transactionAmount;
                        selectedType = item.transactionType;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Center(
                                child: Text(
                                  "Edit Transaction",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: transactioncontroller,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter a Transaction";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Transaction",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: selectedType,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Select a Transaction Type";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Transaction Type",
                                        border: UnderlineInputBorder(),
                                      ),
                                      items: ['Income', 'Expense']
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        selectedType = value;
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 30),
                                      child: TextFormField(
                                        controller: amountcontroller,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter a Transaction";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Add Amount",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.purple),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final updated = MoneyModel(
                                        id: myMoney.value[index].id,
                                        transactionNarration:
                                            transactioncontroller.text,
                                        transactionType: selectedType!,
                                        transactionAmount:
                                            amountcontroller.text,
                                      );
                                      final updatedList = List<MoneyModel>.from(
                                        myMoney.value,
                                      );
                                      updatedList[index] = updated;
                                      myMoney.value = updatedList;

                                      // PENTING: Saldo akan diperbarui otomatis oleh Listener

                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Text("Update"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.edit, size: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Are you sure you want to delete"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Hapus item dari daftar
                                  myMoney.value = List.from(myMoney.value)
                                    ..removeAt(index);

                                  // PENTING: Saldo akan diperbarui otomatis oleh Listener

                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "No",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: value.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          transactioncontroller.clear();
          amountcontroller.clear();
          selectedType = null;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Center(
                  child: Text(
                    "Add a Transaction",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: transactioncontroller,
                        validator: (value) {
                          if (value!.isEmpty || value == null) {
                            return "Enter a Transaction";
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Transaction",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select a Transaction Type";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Transaction Type",
                          border: UnderlineInputBorder(),
                        ),
                        items: ['Income', 'Expense']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          selectedType = value;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: TextFormField(
                          controller: amountcontroller,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter a Transaction";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Add Amount",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final nextId = myMoney.value.length + 1;

                        final newTransaction = MoneyModel(
                          id: nextId.toString(),
                          transactionNarration: transactioncontroller.text,
                          transactionType: selectedType!,
                          transactionAmount: amountcontroller.text,
                        );
                        // Tambahkan transaksi baru
                        myMoney.value = [...myMoney.value, newTransaction];

                        // PENTING: Saldo akan diperbarui otomatis oleh Listener

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
