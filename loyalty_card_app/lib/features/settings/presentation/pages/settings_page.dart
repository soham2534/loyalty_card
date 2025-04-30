import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty_card_app/core/constants/app_theme.dart';
import 'package:loyalty_card_app/core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/core/services/local_database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _darkMode = false;
  bool _sortByExpiry = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _sortByExpiry = prefs.getBool('sort_by_expiry') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await _saveSetting('notifications_enabled', value);
    
    if (value) {
      // If notifications are enabled, schedule notifications for all cards
      final database = Provider.of<LocalDatabaseService>(context, listen: false);
      final cards = await database.getAllCards();
      for (final card in cards) {
        if (card.expiryDate != null) {
          await NotificationService().scheduleCardExpiryNotification(card);
        }
      }
    } else {
      // If notifications are disabled, cancel all notifications
      await NotificationService().cancelAllNotifications();
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                  _saveSetting('dark_mode', value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get alerts for expiring cards'),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ],
          ),
          _buildSection(
            title: 'Card Management',
            children: [
              SwitchListTile(
                title: const Text('Sort by Expiry Date'),
                subtitle: const Text('Show expiring cards first'),
                value: _sortByExpiry,
                onChanged: (value) {
                  setState(() => _sortByExpiry = value);
                  _saveSetting('sort_by_expiry', value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
} 