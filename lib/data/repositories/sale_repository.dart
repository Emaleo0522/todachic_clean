import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/sale.dart';

final saleRepositoryProvider = StateNotifierProvider<SaleRepository, List<Sale>>((ref) {
  return SaleRepository();
});

class SaleRepository extends StateNotifier<List<Sale>> {
  late Box<Sale> _box;
  bool _initialized = false;

  SaleRepository() : super([]) {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SaleAdapter());
      }
      
      _box = await Hive.openBox<Sale>('sales');
      state = _box.values.toList();
      _initialized = true;
    } catch (e) {
      print('Error initializing sales box: $e');
      state = [];
      _initialized = false;
    }
  }

  List<Sale> getAllSales() {
    if (!_initialized) return [];
    try {
      return _box.values.toList();
    } catch (e) {
      print('Error getting all sales: $e');
      return [];
    }
  }

  Sale? getSale(String id) {
    if (!_initialized) return null;
    try {
      return _box.get(id);
    } catch (e) {
      print('Error getting sale $id: $e');
      return null;
    }
  }

  void addSale(Sale sale) {
    if (!_initialized) return;
    try {
      _box.put(sale.id, sale);
      state = _box.values.toList();
    } catch (e) {
      print('Error adding sale: $e');
    }
  }

  void updateSale(Sale sale) {
    if (!_initialized) return;
    try {
      _box.put(sale.id, sale);
      state = _box.values.toList();
    } catch (e) {
      print('Error updating sale: $e');
    }
  }

  void deleteSale(String id) {
    if (!_initialized) return;
    try {
      _box.delete(id);
      state = _box.values.toList();
    } catch (e) {
      print('Error deleting sale: $e');
    }
  }

  // New method to handle sale deletion with stock reversal
  Sale? deleteSaleWithStockReversal(String id) {
    if (!_initialized) return null;
    try {
      final sale = _box.get(id);
      if (sale != null) {
        _box.delete(id);
        state = _box.values.toList();
        return sale; // Return the deleted sale for stock adjustment
      }
      return null;
    } catch (e) {
      print('Error deleting sale with stock reversal: $e');
      return null;
    }
  }

  List<Sale> getSalesByDateRange(DateTime start, DateTime end) {
    if (!_initialized) return [];
    try {
      return _box.values
          .where((sale) => 
              sale.saleDate.isAfter(start) && sale.saleDate.isBefore(end))
          .toList();
    } catch (e) {
      print('Error getting sales by date range: $e');
      return [];
    }
  }

  List<Sale> getSalesByProduct(String productId) {
    if (!_initialized) return [];
    try {
      return _box.values
          .where((sale) => sale.productId == productId)
          .toList();
    } catch (e) {
      print('Error getting sales by product: $e');
      return [];
    }
  }

  double getTotalRevenue() {
    if (!_initialized) return 0.0;
    try {
      return _box.values
          .map((sale) => sale.totalAmount)
          .fold(0.0, (sum, amount) => sum + amount);
    } catch (e) {
      print('Error calculating total revenue: $e');
      return 0.0;
    }
  }

  Map<String, double> getRevenueByProduct() {
    if (!_initialized) return {};
    try {
      final Map<String, double> revenueMap = {};
      for (final sale in _box.values) {
        revenueMap[sale.productId] = 
            (revenueMap[sale.productId] ?? 0.0) + sale.totalAmount;
      }
      return revenueMap;
    } catch (e) {
      print('Error getting revenue by product: $e');
      return {};
    }
  }
}