import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'chat_screen.dart'; // 👈 Add this import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> models = const [
    {
      'title': 'Pneumonia Detection',
      'desc': 'Upload a chest X-ray image to check for pneumonia.',
      'image': 'assets/pneumonia.jpg',
    },
    {
      'title': 'Brain Tumor Detection',
      'desc': 'Scan brain MRI images for tumor analysis.',
      'image': 'assets/brain_tumor.jpg',
    },
    {
      'title': 'Lung Cancer Detection',
      'desc': 'Detect signs of lung cancer from CT scans.',
      'image': 'assets/lung_cancer.jpg',
    },
    {
      'title': 'MedScan Chatbot',
      'desc': 'Ask any health or report-related questions.',
      'image': 'assets/chatbot.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Med Scan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      model['image']!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          model['desc']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (model['title'] == 'MedScan Chatbot') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScanScreen(
                                      modelName: model['title']!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              model['title'] == 'MedScan Chatbot'
                                  ? 'Chat Now'
                                  : "Let's Scan",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}