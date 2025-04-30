import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/core/services/local_database_service.dart';
import 'package:loyalty_card_app/shared/models/card_model.dart';
import 'package:loyalty_card_app/core/constants/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<CardModel> _expiringCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpiringCards();
  }

  Future<void> _loadExpiringCards() async {
    setState(() => _isLoading = true);
    final db = Provider.of<LocalDatabaseService>(context, listen: false);
    _expiringCards = await db.getExpiringCards();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expiringCards.isEmpty
              ? const Center(
                  child: Text('No expiring cards found.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _expiringCards.length,
                  itemBuilder: (context, index) {
                    final card = _expiringCards[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.credit_card,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(card.name),
                        subtitle: Text(
                          'Expires on: ${card.expiryDate!.day}/${card.expiryDate!.month}/${card.expiryDate!.year}',
                        ),
                        trailing: Text(
                          '${_daysUntilExpiry(card.expiryDate!)} days left',
                          style: TextStyle(
                            color: _getExpiryColor(card.expiryDate!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // TODO: Navigate to card details
                        },
                      ),
                    );
                  },
                ),
    );
  }

  int _daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final daysLeft = _daysUntilExpiry(expiryDate);
    if (daysLeft <= 7) {
      return AppTheme.errorColor;
    } else if (daysLeft <= 30) {
      return Colors.orange;
    }
    return Colors.green;
  }
} 