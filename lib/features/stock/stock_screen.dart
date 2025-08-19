import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import 'product_card.dart';
import 'product_form_dialog.dart';

// Provider para el término de búsqueda
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider para la categoría seleccionada
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider para filtros especiales (sin stock, stock bajo)
enum SpecialFilter { none, sinStock, stockBajo }
final specialFilterProvider = StateProvider<SpecialFilter>((ref) => SpecialFilter.none);

// Provider para productos filtrados
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final specialFilter = ref.watch(specialFilterProvider);

  var filtered = products.where((product) {
    final matchesSearch = searchQuery.isEmpty ||
        product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        product.category.toLowerCase().contains(searchQuery.toLowerCase());

    final matchesCategory = selectedCategory == null ||
        product.category == selectedCategory;

    // Aplicar filtros especiales
    bool matchesSpecialFilter = true;
    switch (specialFilter) {
      case SpecialFilter.sinStock:
        matchesSpecialFilter = product.quantity == 0;
        break;
      case SpecialFilter.stockBajo:
        // Obtener threshold de settings (por defecto 10)
        final settingsRepo = ref.watch(settingsRepositoryProvider);
        matchesSpecialFilter = product.quantity > 0 && product.quantity <= settingsRepo.lowStockThreshold;
        break;
      case SpecialFilter.none:
        matchesSpecialFilter = true;
        break;
    }

    return matchesSearch && matchesCategory && matchesSpecialFilter;
  }).toList();

  // Ordenar por nombre
  filtered.sort((a, b) => a.name.compareTo(b.name));
  
  return filtered;
});

// Provider para categorías disponibles
final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productRepositoryProvider);
  final categories = products.map((p) => p.category).toSet().toList();
  categories.sort();
  return categories;
});

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Filtros especiales
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: ref.watch(specialFilterProvider) == SpecialFilter.none,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(specialFilterProvider.notifier).state = SpecialFilter.none;
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Sin Stock'),
                        selected: ref.watch(specialFilterProvider) == SpecialFilter.sinStock,
                        backgroundColor: Colors.red.shade50,
                        selectedColor: Colors.red.shade100,
                        onSelected: (selected) {
                          ref.read(specialFilterProvider.notifier).state = 
                              selected ? SpecialFilter.sinStock : SpecialFilter.none;
                          if (selected) ref.read(selectedCategoryProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilterChip(
                        label: const Text('Stock Bajo'),
                        selected: ref.watch(specialFilterProvider) == SpecialFilter.stockBajo,
                        backgroundColor: Colors.orange.shade50,
                        selectedColor: Colors.orange.shade100,
                        onSelected: (selected) {
                          ref.read(specialFilterProvider.notifier).state = 
                              selected ? SpecialFilter.stockBajo : SpecialFilter.none;
                          if (selected) ref.read(selectedCategoryProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                ),
                
                // Category filter
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...categories.map((category) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              ref.read(selectedCategoryProvider.notifier).state =
                                  selected ? category : null;
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stock stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Productos',
                    '${filteredProducts.length}',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Stock Bajo',
                    '${filteredProducts.where((p) => p.isLowStock).length}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Sin Stock',
                    '${filteredProducts.where((p) => p.quantity == 0).length}',
                    Icons.remove_circle,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Products list
          Expanded(
            child: filteredProducts.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2,
                    title: 'No hay productos',
                    message: ref.watch(searchQueryProvider).isEmpty
                        ? 'Comienza agregando tu primer producto'
                        : 'No se encontraron productos con ese criterio',
                    actionText: ref.watch(searchQueryProvider).isEmpty
                        ? 'Agregar Producto'
                        : 'Limpiar Búsqueda',
                    onAction: ref.watch(searchQueryProvider).isEmpty
                        ? () => _showAddProductDialog(context)
                        : () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ProductCard(product: filteredProducts[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Agregar Producto',
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showProductFormDialog(context);
  }
}