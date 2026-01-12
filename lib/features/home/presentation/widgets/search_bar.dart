import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/routes/route_names.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => context.push(RouteNames.productList),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 16),
              Text('search_products'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
