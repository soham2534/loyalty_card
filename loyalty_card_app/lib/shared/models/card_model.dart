import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CardModel {
  final String id;
  final String name;
  final String cardNumber;
  final DateTime? expiryDate;
  final String? notes;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? barcode;
  final String? qrCode;

  CardModel({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.expiryDate,
    this.notes,
    this.imagePath,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.barcode,
    this.qrCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'barcode': barcode,
      'qrCode': qrCode,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String?,
      isFavorite: (json['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      barcode: json['barcode'] as String?,
      qrCode: json['qrCode'] as String?,
    );
  }

  CardModel copyWith({
    String? id,
    String? name,
    String? cardNumber,
    DateTime? expiryDate,
    String? notes,
    String? imagePath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? barcode,
    String? qrCode,
  }) {
    return CardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
    );
  }
} 