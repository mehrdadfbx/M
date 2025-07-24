import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Categories {
  static const List<CategoryModel> categories = [
    CategoryModel(name: 'food', icon: Icons.restaurant, color: Colors.orange),
    CategoryModel(
      name: 'transport',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    CategoryModel(
      name: 'shopping',
      icon: Icons.shopping_bag,
      color: Colors.green,
    ),
    CategoryModel(
      name: 'entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    CategoryModel(
      name: 'health',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    CategoryModel(name: 'education', icon: Icons.school, color: Colors.indigo),
    CategoryModel(name: 'bills', icon: Icons.receipt_long, color: Colors.brown),
    CategoryModel(name: 'other', icon: Icons.category, color: Colors.grey),
  ];

  static CategoryModel getCategoryByName(String name) {
    return categories.firstWhere(
      (category) => category.name == name,
      orElse: () => categories.last,
    );
  }
}
