import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_tracker_1/model/money_model.dart';

class StatisticsScreen extends StatelessWidget {
  final ValueNotifier<List<MoneyModel>> myMoney;

  const StatisticsScreen({super.key, required this.myMoney});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Pengeluaran"),
        backgroundColor: Colors.blue,
      ),
      body: ValueListenableBuilder(
        valueListenable: myMoney,
        builder: (_, List<MoneyModel> value, __) {
          double food = 0, transport = 0, bill = 0;

          for (var t in value) {
            final amt = double.tryParse(t.transactionAmount) ?? 0;

            // hanya hitung EXPENSE
            if (t.transactionType == "Expense") {
              switch (t.transactionCategory.toLowerCase()) {
                case "makan":
                case "makanan":
                  food += amt;
                  break;

                case "transport":
                case "transportasi":
                  transport += amt;
                  break;

                case "tagihan":
                case "listrik":
                case "air":
                  bill += amt;
                  break;
              }
            }
          }

          final sections = <PieChartSectionData>[];

          if (food > 0) {
            sections.add(
              PieChartSectionData(
                value: food,
                title: "Makan",
                color: Colors.orange,
              ),
            );
          }
          if (transport > 0) {
            sections.add(
              PieChartSectionData(
                value: transport,
                title: "Transport",
                color: Colors.blue,
              ),
            );
          }
          if (bill > 0) {
            sections.add(
              PieChartSectionData(
                value: bill,
                title: "Tagihan",
                color: Colors.red,
              ),
            );
          }

          // jika tidak ada data kategori
          if (sections.isEmpty) {
            return const Center(
              child: Text("Belum ada data pengeluaran untuk ditampilkan."),
            );
          }

          return Center(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}
