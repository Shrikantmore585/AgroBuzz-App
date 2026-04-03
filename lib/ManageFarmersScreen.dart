import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFarmersScreen extends StatefulWidget {
  const ManageFarmersScreen({super.key});

  @override
  _ManageFarmersScreenState createState() => _ManageFarmersScreenState();
}

class _ManageFarmersScreenState extends State<ManageFarmersScreen> {
  final CollectionReference farmers =
      FirebaseFirestore.instance.collection('users');

  Map<String, String> extractNameFromEmail(String email) {
    final username = email.split('@').first;

    if (username.contains('.')) {
      final parts = username.split('.');
      return {
        'firstName': capitalize(parts[0]),
        'lastName': capitalize(parts[1]),
      };
    } else {
      return {
        'firstName': capitalize(username),
        'lastName': '',
      };
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> deleteFarmer(String id) async {
    try {
      await farmers.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Farmer deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete farmer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F5F9),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Manage Registered Farmers'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: farmers.where('role', isEqualTo: 'customer').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final farmerDocs = snapshot.data?.docs ?? [];

          if (farmerDocs.isEmpty) {
            return Center(child: Text('No registered farmers found.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: farmerDocs.length,
            itemBuilder: (context, index) {
              final farmer = farmerDocs[index];
              final email = farmer['email'] ?? '';
              final names = extractNameFromEmail(email);
              final fullName = '${names['firstName']} ${names['lastName']}';

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.person, color: Colors.green[800]),
                  ),
                  title: Text(
                    fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    email,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[600]),
                    onPressed: () => deleteFarmer(farmer.id),
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
