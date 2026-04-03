import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerCart extends StatefulWidget {
  const CustomerCart({super.key});

  @override
  State<CustomerCart> createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  final user = FirebaseAuth.instance.currentUser;
  final Set<String> selectedItemIds = {};

  Future<void> _placeOrder(List<DocumentSnapshot> cartDocs) async {
    if (user == null || selectedItemIds.isEmpty) return;

    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(user!.uid)
        .collection('myOrders');

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(user!.uid)
        .collection('items');

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in cartDocs) {
      if (!selectedItemIds.contains(doc.id)) continue;

      final data = doc.data() as Map<String, dynamic>;
      final orderData = {
        'name': data['name'],
        'price': data['price'],
        'category': data['category'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      batch.set(ordersRef.doc(), orderData);
      batch.delete(doc.reference);
    }

    await batch.commit();

    setState(() {
      selectedItemIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected items ordered & removed from cart!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteItem(DocumentReference docRef) async {
    await docRef.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in.")),
      );
    }

    final cartStream = FirebaseFirestore.instance
        .collection('carts')
        .doc(user!.uid)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartDocs = snapshot.data?.docs ?? [];

          if (cartDocs.isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: selectedItemIds.contains(docId)
                              ? Colors.green.shade700
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Checkbox(
                          value: selectedItemIds.contains(docId),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                selectedItemIds.add(docId);
                              } else {
                                selectedItemIds.remove(docId);
                              }
                            });
                          },
                          activeColor: Colors.green.shade700,
                        ),
                        title: Text(
                          data['name'] ?? 'Unnamed',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "₹${num.tryParse(data['price'].toString()) ?? 0}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (data['category'] != null)
                              Text(
                                "Category: ${data['category']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(doc.reference),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton.icon(
                  onPressed: () => _placeOrder(cartDocs),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text(
                    "Place Selected Orders",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
