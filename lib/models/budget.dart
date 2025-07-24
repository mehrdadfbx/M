class BudgetModel {
  final double monthlyIncome;
  final double spendingLimit;
  final String currency;

  BudgetModel({
    required this.monthlyIncome,
    required this.spendingLimit,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthlyIncome': monthlyIncome,
      'spendingLimit': spendingLimit,
      'currency': currency,
    };
  }

  static BudgetModel fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      monthlyIncome: map['monthlyIncome'] ?? 0.0,
      spendingLimit: map['spendingLimit'] ?? 0.0,
      currency: map['currency'] ?? 'toman',
    );
  }

  BudgetModel copyWith({
    double? monthlyIncome,
    double? spendingLimit,
    String? currency,
  }) {
    return BudgetModel(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      currency: currency ?? this.currency,
    );
  }
}

class Currency {
  static const Map<String, String> symbols = {
    'rial': '﷼',
    'toman': 'تومان',
    'usd': '\$',
  };

  static String getSymbol(String currency) {
    return symbols[currency] ?? '';
  }

  static List<String> get currencies => symbols.keys.toList();
}
