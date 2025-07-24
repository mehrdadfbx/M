import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance/models/transaction.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/budget.dart';
import 'package:finance/l10n/app_localizations.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.currency,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = Categories.getCategoryByName(transaction.category);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryName(l10n, transaction.category),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)} ${Currency.getSymbol(currency)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(AppLocalizations l10n, String category) {
    switch (category) {
      case 'food':
        return l10n.food;
      case 'transport':
        return l10n.transport;
      case 'shopping':
        return l10n.shopping;
      case 'entertainment':
        return l10n.entertainment;
      case 'health':
        return l10n.health;
      case 'education':
        return l10n.education;
      case 'bills':
        return l10n.bills;
      case 'other':
        return l10n.other;
      default:
        return category;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
