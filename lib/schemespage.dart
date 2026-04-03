import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SchemesPage extends StatefulWidget {
  const SchemesPage({super.key});

  @override
  State<SchemesPage> createState() => _SchemesPageState();
}

class _SchemesPageState extends State<SchemesPage> {
  final List<Map<String, String>> schemes = [
    {
      "title": "PM-KISAN",
      "description": "Income support to farmers up to ₹6,000/year.",
      "url": "https://pmkisan.gov.in"
    },
    {
      "title": "Soil Health Card",
      "description": "Promotes soil testing to improve crop productivity.",
      "url": "https://soilhealth.dac.gov.in"
    },
    {
      "title": "PMFBY",
      "description": "Crop insurance scheme to protect against losses.",
      "url": "https://pmfby.gov.in"
    },
    {
      "title": "eNAM",
      "description": "National Agriculture Market for better price discovery.",
      "url": "https://enam.gov.in"
    },
    {
      "title": "RKVY",
      "description":
          "Rashtriya Krishi Vikas Yojana - holistic agri development.",
      "url": "https://rkvy.nic.in"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Government Schemes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Explore the latest schemes for farmers",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return buildSchemeCard(
                  scheme["title"]!,
                  scheme["description"]!,
                  scheme["url"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSchemeCard(String title, String description, String url) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.agriculture, color: Colors.lightGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SchemeWebViewPage(title: title, url: url),
            ),
          );
        },
      ),
    );
  }
}

class SchemeWebViewPage extends StatelessWidget {
  final String title;
  final String url;

  const SchemeWebViewPage({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(title),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
