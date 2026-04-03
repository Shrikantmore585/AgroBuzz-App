import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Dummy user data
  final String userName = "Nikhil Kasaralu";
  final String userEmail = "nikhil@example.com";
  final String userLocation = "Nanded, 431605";
  final String profileImage = "assets/default_profile.png"; // Replace as needed

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture & Name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('assets/default_profile.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Personal Info
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personal Info",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              buildCard(Icons.person, userName, screenWidth),
              buildCard(Icons.email, userEmail, screenWidth),
              buildCard(Icons.location_on, userLocation, screenWidth),

              const SizedBox(height: 25),

              // Utilities
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Utilities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              buildCard(Icons.download, "Downloads", screenWidth, onTap: () {}),
              buildCard(Icons.info, "About Us", screenWidth, onTap: () {}),
              buildCard(
                Icons.help_outline,
                "Help Desk",
                screenWidth,
                onTap: () {},
              ),
              buildCard(Icons.logout, "Logout", screenWidth, onTap: () {}),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(
    IconData icon,
    String title,
    double width, {
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(icon, color: Colors.lightGreen),
          title: Text(title),
          trailing: onTap != null
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
