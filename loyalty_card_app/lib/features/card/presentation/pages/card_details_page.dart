import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/shared/models/card_model.dart';
import 'package:loyalty_card_app/core/constants/app_theme.dart';
import 'package:loyalty_card_app/core/services/local_database_service.dart';
import 'package:loyalty_card_app/core/services/barcode_service.dart';

class CardDetailsPage extends StatelessWidget {
  final CardModel card;

  const CardDetailsPage({super.key, required this.card});

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final db = Provider.of<LocalDatabaseService>(context, listen: false);
      final updatedCard = card.copyWith(isFavorite: !card.isFavorite);
      await db.updateCard(updatedCard);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite status. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            icon: Icon(
              card.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: card.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.imagePath != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(card.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Number',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.cardNumber,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    if (card.expiryDate != null) ...[
                      Text(
                        'Expiry Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${card.expiryDate!.day}/${card.expiryDate!.month}/${card.expiryDate!.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (card.notes != null && card.notes!.isNotEmpty) ...[
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.notes!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (card.barcode != null || card.qrCode != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barcode/QR Code',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            if (card.barcode != null) ...[
                              BarcodeService.generateBarcode(card.barcode!),
                              const SizedBox(height: 16),
                            ],
                            if (card.qrCode != null)
                              BarcodeService.generateQRCode(card.qrCode!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 