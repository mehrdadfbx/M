import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance/providers/finance_provider.dart';
import 'package:finance/widgets/transaction_item.dart';
import 'package:finance/screens/add_transaction_screen.dart';
import 'package:finance/l10n/app_localizations.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: l10n.income),
            Tab(text: l10n.expense),
          ],
        ),

        // Tab Content
        Expanded(
          child: Consumer<FinanceProvider>(
            builder: (context, financeProvider, child) {
              final currency = financeProvider.budget.currency;

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionsList(
                    financeProvider.transactions,
                    currency,
                  ),
                  _buildTransactionsList(
                    financeProvider.transactions
                        .where((t) => t.isIncome)
                        .toList(),
                    currency,
                  ),
                  _buildTransactionsList(
                    financeProvider.transactions
                        .where((t) => !t.isIncome)
                        .toList(),
                    currency,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List transactions, String currency) {
    final l10n = AppLocalizations.of(context)!;

    // Filter transactions based on search query
    final filteredTransactions = transactions.where((transaction) {
      return _searchQuery.isEmpty ||
          transaction.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          transaction.category.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? l10n.noTransactions
                  : 'No transactions found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.addFirstTransaction,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return TransactionItem(
          transaction: transaction,
          currency: currency,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AddTransactionScreen(transaction: transaction),
              ),
            );
          },
          onDelete: () {
            _deleteTransaction(transaction.id!);
          },
        );
      },
    );
  }

  Future<void> _deleteTransaction(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final financeProvider = Provider.of<FinanceProvider>(
          context,
          listen: false,
        );
        await financeProvider.deleteTransaction(id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
