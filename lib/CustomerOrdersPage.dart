import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerOrder extends StatelessWidget {
  const CustomerOrder({super.key});

  void _deleteOrder(DocumentReference docRef, BuildContext context) async {
    await docRef.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in.")),
      );
    }

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(user.uid)
        .collection('myOrders')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderDocs = snapshot.data?.docs ?? [];

          if (orderDocs.isEmpty) {
            return const Center(child: Text("No orders placed yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final doc = orderDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(
                      "₹${data['price'].toString()} • ${data['category'] ?? 'No Category'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(doc.reference, context),
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
