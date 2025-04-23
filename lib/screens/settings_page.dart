import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'profile_page.dart';
import 'change_passApp.dart';
import 'about_us_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.purple)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: ListView(
        children: [
          _buildSettingsTile(
            icon: Feather.user,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Feather.lock,
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Feather.trash_2,
            title: 'Delete Account',
            onTap: () {
              // Show confirmation dialog before deletion
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Confirm Deletion"),
                      content: const Text(
                        "Are you sure you want to delete your account?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement account deletion logic
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Feather.globe,
            title: 'Multi Language',
            onTap: () {
              // TODO: Show language selection dialog
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Choose Language'),
                      content: const Text('Language picker will be here.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Feather.info,
            title: 'About Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Feather.log_out,
            title: 'Log Out',
            onTap: () {
              // TODO: Handle log out logic
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
