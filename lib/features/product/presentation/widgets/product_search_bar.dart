import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController hscodeController;
  final TextEditingController nameController;
  final VoidCallback onSearch;

  const ProductSearchBar({super.key, required this.hscodeController, required this.nameController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: hscodeController,
            decoration: const InputDecoration(labelText: 'HS Code', hintText: 'Enter HS Code', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              hintText: 'Enter product name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: onSearch, icon: const Icon(Icons.search), label: const Text('Search')),
        ],
      ),
    );
  }
}
