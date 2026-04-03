import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final Query<Map<String, dynamic>> ordersRef =
      FirebaseFirestore.instance.collectionGroup('myOrders');

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Icon getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      case 'Delivered':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Future<void> deleteOrder(String userId, String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('myOrders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted successfully')),
      );
    } catch (e) {
      print("Error deleting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Manage Farmer Orders'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, ordersSnapshot) {
          if (ordersSnapshot.hasError) {
            print("Error fetching orders: ${ordersSnapshot.error}");
            return const Center(child: Text('Error loading orders.'));
          }

          if (ordersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderDocs = ordersSnapshot.data?.docs ?? [];
          if (orderDocs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: orderDocs.length,
            itemBuilder: (context, orderIndex) {
              final orderDoc = orderDocs[orderIndex];
              final orderData = orderDoc.data() as Map<String, dynamic>;
              final orderId = orderDoc.id;
              final userId = orderData['userId'] as String? ?? 'Unknown User';
              final name = orderData['name'] as String? ?? 'No Name';
              final price = (orderData['price'] as num?)?.toDouble() ?? 0.0;
              final category = orderData['category'] as String? ?? 'N/A';
              final status = orderData['status'] as String? ?? 'Pending';

              return Container(
                margin:
                    const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(name),
                  subtitle: Text(
                      "₹${price.toStringAsFixed(2)} • $category • Status: $status"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteOrder(userId, orderId),
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
