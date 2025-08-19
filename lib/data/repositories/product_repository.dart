import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/product.dart';

final productRepositoryProvider = StateNotifierProvider<ProductRepository, List<Product>>((ref) {
  return ProductRepository();
});

class ProductRepository extends StateNotifier<List<Product>> {
  late Box<Product> _box;
  bool _initialized = false;

  ProductRepository() : super([]) {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductAdapter());
      }
      
      _box = await Hive.openBox<Product>('products');
      _loadProducts();
      _initialized = true;
    } catch (e) {
      print('Error al inicializar ProductRepository: $e');
      state = [];
      _initialized = false;
    }
  }

  void _loadProducts() {
    try {
      state = _box.values.toList();
    } catch (e) {
      print('Error al cargar productos: $e');
      state = [];
    }
  }

  List<Product> getAllProducts() {
    if (!_initialized) return [];
    return state;
  }

  Product? getProduct(String id) {
    if (!_initialized) return null;
    try {
      return _box.get(id);
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  void addProduct(Product product) {
    if (!_initialized) return;
    try {
      _box.put(product.id, product);
      _loadProducts(); // Refresh state
    } catch (e) {
      print('Error al agregar producto: $e');
    }
  }

  void updateProduct(Product product) {
    if (!_initialized) return;
    try {
      _box.put(product.id, product);
      _loadProducts(); // Refresh state
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  void deleteProduct(String id) {
    if (!_initialized) return;
    try {
      _box.delete(id);
      _loadProducts(); // Refresh state
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  List<Product> searchProducts(String query) {
    return getAllProducts()
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Product> getProductsByCategory(String category) {
    return getAllProducts()
        .where((p) => p.category == category)
        .toList();
  }

  List<Product> getLowStockProducts(int threshold) {
    return getAllProducts()
        .where((p) => p.quantity <= threshold)
        .toList();
  }

  List<String> getCategories() {
    return getAllProducts()
        .map((p) => p.category)
        .toSet()
        .toList();
  }
}