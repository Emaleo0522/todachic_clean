import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productId;

  @HiveField(2)
  String productName;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double unitPrice;

  @HiveField(5)
  double totalAmount;

  @HiveField(6)
  DateTime saleDate;

  @HiveField(7)
  String? customerName;

  @HiveField(8)
  String? notes;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.saleDate,
    this.customerName,
    this.notes,
  });

  Sale copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? saleDate,
    String? customerName,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      saleDate: saleDate ?? this.saleDate,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, productName: $productName, quantity: $quantity, totalAmount: $totalAmount, saleDate: $saleDate)';
  }
}