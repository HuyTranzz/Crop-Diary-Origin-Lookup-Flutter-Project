import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: product.imageUrl.isNotEmpty
            ? CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
          backgroundColor: Colors.grey[200],
        )
            : CircleAvatar(
          child: Icon(Icons.eco, color: Colors.green),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(product.name),
        subtitle: Text('Giống: ${product.variety}'),
        trailing: Text('ID: ${product.productId}'),
        onTap: onTap,
      ),
    );
  }
}
