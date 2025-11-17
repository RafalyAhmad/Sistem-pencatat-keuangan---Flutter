class MoneyModel {
  final String id;
  final String transactionNarration;
  final String transactionType;
  final String transactionAmount;
  final String transactionCategory; // <-- kategori baru

  MoneyModel({
    required this.id,
    required this.transactionNarration,
    required this.transactionType,
    required this.transactionAmount,
    required this.transactionCategory,
  });
}
