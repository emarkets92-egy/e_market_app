import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(product.name),
        subtitle: product.hscode != null
            ? Text('HS Code: ${product.hscode}')
            : null,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push(
            '${RouteNames.productDetail.replaceAll(':id', product.id)}',
          );
        },
      ),
    );
  }
}
