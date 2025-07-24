class TransactionModel {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isIncome;

  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
    };
  }

  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
    );
  }

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    bool? isIncome,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
