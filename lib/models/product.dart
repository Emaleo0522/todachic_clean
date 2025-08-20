import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'settings.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double price;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  Size? size;

  @HiveField(10)
  double? costPrice;

  @HiveField(11)
  String? imageData; // Base64 encoded image data

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.size,
    this.costPrice,
    this.imageData,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Size? size,
    double? costPrice,
    String? imageData,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size,
      costPrice: costPrice ?? this.costPrice,
      imageData: imageData ?? this.imageData,
    );
  }

  double get totalValue => price * quantity;

  bool get isLowStock => quantity < 10;

  // Método para obtener el nivel de stock
  StockLevel getStockLevel({int lowThreshold = 10, int highThreshold = 50}) {
    if (quantity <= 0) {
      return StockLevel.outOfStock;
    } else if (quantity <= lowThreshold) {
      return StockLevel.low;
    } else if (quantity <= highThreshold) {
      return StockLevel.medium;
    } else {
      return StockLevel.high;
    }
  }

  // Getter para compatibilidad con código existente
  double get unitPrice => price;

  // Calcular margen de ganancia
  double get profitMargin {
    if (costPrice == null || costPrice == 0) return 0.0;
    return ((price - costPrice!) / costPrice!) * 100;
  }

  // Calcular ganancia unitaria
  double get unitProfit {
    if (costPrice == null) return price;
    return price - costPrice!;
  }

  // Método para actualizar stock
  Product updateStock(int newQuantity) {
    return copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
  }

  // Método para reducir stock (para ventas)
  Product reduceStock(int soldQuantity) {
    final newQuantity = quantity - soldQuantity;
    return copyWith(
      quantity: newQuantity >= 0 ? newQuantity : 0,
      updatedAt: DateTime.now(),
    );
  }

  // Método para aumentar stock (para reabastecimiento)
  Product increaseStock(int addedQuantity) {
    return copyWith(
      quantity: quantity + addedQuantity,
      updatedAt: DateTime.now(),
    );
  }

  // Verificar si hay suficiente stock para una venta
  bool hasEnoughStock(int requiredQuantity) {
    return quantity >= requiredQuantity;
  }

  // Verificar si el producto tiene imagen
  bool get hasImage => imageData != null && imageData!.isNotEmpty;

  // Obtener imagen como Uint8List desde Base64
  Uint8List? get imageBytes {
    if (!hasImage) return null;
    try {
      return base64Decode(imageData!);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price, quantity: $quantity)';
  }
}