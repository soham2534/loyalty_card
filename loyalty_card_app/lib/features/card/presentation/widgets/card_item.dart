import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/shared/models/card_model.dart';
import 'package:loyalty_card_app/core/constants/app_theme.dart';
import 'package:loyalty_card_app/core/services/local_database_service.dart';
import 'package:loyalty_card_app/features/card/presentation/pages/add_edit_card_page.dart';
import 'package:loyalty_card_app/features/card/presentation/pages/card_details_page.dart';
import 'dart:io';

class CardItem extends StatelessWidget {
  final CardModel card;

  const CardItem({super.key, required this.card});

  Future<void> _deleteCard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = Provider.of<LocalDatabaseService>(context, listen: false);
      await db.deleteCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCardPage(card: card),
                ),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteCard(context),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailsPage(card: card),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: card.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(card.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: card.imagePath == null
                      ? Center(
                          child: Icon(
                            Icons.credit_card,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.cardNumber,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires: ${card.expiryDate!.day}/${card.expiryDate!.month}/${card.expiryDate!.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.hintColor,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 