import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
            decoration: InputDecoration(labelText: 'hs_code'.tr(), hintText: 'hs_code'.tr(), prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'name'.tr(),
              hintText: 'name'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: onSearch, icon: const Icon(Icons.search), label: Text('search'.tr())),
        ],
      ),
    );
  }
}
