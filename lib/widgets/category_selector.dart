import 'package:flutter/material.dart';
import 'package:finance/models/category.dart';
import 'package:finance/l10n/app_localizations.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      value: selectedCategory.isEmpty ? null : selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: selectedCategory.isNotEmpty
            ? Icon(
                Categories.getCategoryByName(selectedCategory).icon,
                color: Categories.getCategoryByName(selectedCategory).color,
              )
            : const Icon(Icons.category),
      ),
      items: Categories.categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.name,
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 20),
              const SizedBox(width: 12),
              Text(_getCategoryName(l10n, category.name)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onCategorySelected(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
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
}
