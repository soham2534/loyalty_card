import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loyalty_card_app/core/services/local_database_service.dart';
import 'package:loyalty_card_app/core/services/barcode_service.dart';
import 'package:loyalty_card_app/shared/models/card_model.dart';
import 'package:loyalty_card_app/core/constants/app_theme.dart';
import 'package:loyalty_card_app/core/services/notification_service.dart';

class AddEditCardPage extends StatefulWidget {
  final CardModel? card;

  const AddEditCardPage({super.key, this.card});

  @override
  State<AddEditCardPage> createState() => _AddEditCardPageState();
}

class _AddEditCardPageState extends State<AddEditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expiryDate;
  String? _imagePath;
  bool _isFavorite = false;
  bool _isSaving = false;
  String? _barcode;
  String? _qrCode;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _nameController.text = widget.card!.name;
      _cardNumberController.text = widget.card!.cardNumber;
      _notesController.text = widget.card!.notes ?? '';
      _expiryDate = widget.card!.expiryDate;
      _imagePath = widget.card!.imagePath;
      _isFavorite = widget.card!.isFavorite;
      _barcode = widget.card!.barcode;
      _qrCode = widget.card!.qrCode;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web, we store the path which will be a data URL
          setState(() {
            _imagePath = image.path;
          });
        } else {
          // For native platforms, store the file path
          setState(() {
            _imagePath = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final barcode = await BarcodeService.scanBarcode();
      if (barcode.isNotEmpty) {
        setState(() {
          _barcode = barcode;
          _cardNumberController.text = barcode;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to scan barcode')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final card = CardModel(
          id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          cardNumber: _cardNumberController.text,
          expiryDate: _expiryDate,
          notes: _notesController.text,
          imagePath: _imagePath,
          isFavorite: _isFavorite,
          createdAt: widget.card?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          barcode: _barcode,
          qrCode: _qrCode,
        );

        final database = Provider.of<LocalDatabaseService>(context, listen: false);
        if (widget.card == null) {
          await database.insertCard(card);
        } else {
          await database.updateCard(card);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save card: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Widget _buildImageWidget() {
    if (_imagePath == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 8),
            Text('Add Card Image'),
          ],
        ),
      );
    }

    if (kIsWeb) {
      // For web platform, use network image
      return Image.network(
        _imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Failed to load image'),
          );
        },
      );
    } else {
      // For native platforms, use file image
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Failed to load image'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card Name',
                prefixIcon: Icon(Icons.credit_card),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a card name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                prefixIcon: const Icon(Icons.numbers),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Select expiry date',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveCard,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(widget.card == null ? 'Add Card' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 