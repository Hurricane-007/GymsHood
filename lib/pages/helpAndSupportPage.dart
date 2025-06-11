import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
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
                'Getting Started',
                [
                  'Create your gym profile with essential information',
                  'Add gym media (photos and videos) to showcase your facility',
                  'Set up your gym plans and pricing',
                  'Add your bank details for receiving payments',
                ],
                Icons.rocket_launch,
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Managing Your Gym',
                [
                  'Update gym information anytime from the settings',
                  'Create and manage gym plans',
                  'Add or remove gym media',
                  'View and manage member registrations',
                ],
                Icons.business,
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Announcements',
                [
                  'Create announcements to keep members informed',
                  'Schedule announcements for future dates',
                  'Edit or delete existing announcements',
                  'View announcement history',
                ],
                Icons.campaign,
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Revenue Management',
                [
                  'Track daily, weekly, and monthly revenue',
                  'View detailed payment history',
                  'Generate revenue reports',
                  'Monitor member payments and dues',
                ],
                Icons.attach_money,
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Member Management',
                [
                  'View all registered members',
                  'Track member attendance',
                  'Manage member subscriptions',
                  'Handle member queries and support',
                ],
                Icons.people,
              ),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Account Settings',
                [
                  'Update bank details for payments',
                  'Manage notification preferences',
                  'Change password and security settings',
                  'View account activity',
                ],
                Icons.settings,
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'For any additional support, please contact our team',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.contact_support,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Contact Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildContactItem(
                        context,
                        Icons.email,
                        'Email',
                        'support@gymshood.com',
                        () {
                          // TODO: Implement email action
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(
                        context,
                        Icons.phone,
                        'Phone',
                        '+91 1234567890',
                        () {
                          // TODO: Implement phone action
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(
                        context,
                        Icons.access_time,
                        'Working Hours',
                        'Monday - Saturday: 9:00 AM - 6:00 PM',
                        null,
                      ),
                    ],
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

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> points,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...points.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
} 