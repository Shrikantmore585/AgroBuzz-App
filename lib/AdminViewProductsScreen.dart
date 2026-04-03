import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminViewProductsScreen extends StatelessWidget {
  const AdminViewProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image_not_supported),
                  title: Text(data['name'] ?? 'No name'),
                  subtitle: Text(
                    '₹${data['price']}\n${data['description'] ?? 'No description'}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(doc.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Product deleted")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
