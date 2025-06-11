import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Introduction',
                'Welcome to Gymshood. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our application and tell you about your privacy rights.',
              ),
              _buildSection(
                context,
                'Information We Collect',
                'We collect several types of information from and about users of our application, including:\n\n'
                '• Personal identification information (Name, email address, phone number)\n'
                '• Gym-related information (Location, services, pricing)\n'
                '• Payment information (Bank details, transaction history)\n'
                '• Usage data (How you use our application)\n'
                '• Device information (Device type, operating system)',
              ),
              _buildSection(
                context,
                'How We Use Your Information',
                'We use the information we collect to:\n\n'
                '• Provide and maintain our services\n'
                '• Process your transactions\n'
                '• Send you important updates and notifications\n'
                '• Improve our application\n'
                '• Comply with legal obligations',
              ),
              _buildSection(
                context,
                'Data Security',
                'We have implemented appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way. We limit access to your personal data to those employees and third parties who have a business need to know.',
              ),
              _buildSection(
                context,
                'Your Rights',
                'Under data protection laws, you have rights including:\n\n'
                '• Right to access your personal data\n'
                '• Right to rectification of inaccurate data\n'
                '• Right to erasure of your data\n'
                '• Right to restrict processing\n'
                '• Right to data portability\n'
                '• Right to object to processing',
              ),
              _buildSection(
                context,
                'Data Retention',
                'We will only retain your personal data for as long as necessary to fulfill the purposes we collected it for, including for the purposes of satisfying any legal, accounting, or reporting requirements.',
              ),
              _buildSection(
                context,
                'Third-Party Services',
                'Our application may contain links to third-party websites and services. We are not responsible for the privacy practices or content of these third-party services. We encourage you to read their privacy policies.',
              ),
              _buildSection(
                context,
                'Changes to Privacy Policy',
                'We may update our privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last Updated" date.',
              ),
              _buildSection(
                context,
                'Contact Us',
                'If you have any questions about this privacy policy or our data practices, please contact us at:\n\n'
                'Email: privacy@gymshood.com\n'
                'Phone: +91 1234567890',
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Last Updated: March 2024',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 