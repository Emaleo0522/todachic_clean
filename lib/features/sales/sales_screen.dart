import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../models/sale.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import 'product_selector_dialog.dart';
import 'sale_form_dialog.dart';
import '../../widgets/confirmation_dialog.dart';

// Provider para filtro de fecha
final salesDateFilterProvider = StateProvider<DateTime?>((ref) => null);

// Provider para ventas filtradas
final filteredSalesProvider = Provider<List<Sale>>((ref) {
  final sales = ref.watch(saleRepositoryProvider);
  final dateFilter = ref.watch(salesDateFilterProvider);

  if (dateFilter == null) {
    return sales..sort((a, b) => b.saleDate.compareTo(a.saleDate));
  }

  final startOfDay = DateTime(dateFilter.year, dateFilter.month, dateFilter.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return sales
      .where((sale) =>
          sale.saleDate.isAfter(startOfDay) && sale.saleDate.isBefore(endOfDay))
      .toList()
    ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
});

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSales = ref.watch(filteredSalesProvider);
    final dateFilter = ref.watch(salesDateFilterProvider);

    // Calcular estadísticas
    final totalSales = filteredSales.length;
    final totalRevenue = filteredSales.fold<double>(
      0.0,
      (sum, sale) => sum + sale.totalAmount,
    );
    final averageTicket = totalSales > 0 ? totalRevenue / totalSales : 0.0;

    return Scaffold(
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Date filter
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _selectDate(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFilter == null
                                      ? 'Filtrar por fecha'
                                      : 'Ventas del ${_formatDate(dateFilter)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  dateFilter == null
                                      ? 'Toca para seleccionar una fecha específica'
                                      : 'Toca para cambiar la fecha del filtro',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dateFilter == null)
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref.read(salesDateFilterProvider.notifier).state = null;
                              },
                              tooltip: 'Mostrar todas las ventas',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Ventas',
                        totalSales.toString(),
                        Icons.shopping_cart,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total',
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Promedio',
                        '\$${averageTicket.toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sales list
          Expanded(
            child: filteredSales.isEmpty
                ? EmptyState(
                    icon: Icons.point_of_sale,
                    title: dateFilter == null ? 'No hay ventas' : 'Sin ventas en esta fecha',
                    message: dateFilter == null
                        ? 'Comienza registrando tu primera venta'
                        : 'No se registraron ventas en la fecha seleccionada',
                    actionText: 'Nueva Venta',
                    onAction: () => _showAddSaleDialog(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return _buildSaleCard(context, ref, sale);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSaleDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Nueva Venta',
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, WidgetRef ref, Sale sale) {
    // Obtener el producto actual para mostrar la imagen
    final products = ref.watch(productRepositoryProvider);
    final product = products.cast<Object?>().firstWhere(
      (p) => (p as dynamic)?.id == sale.productId,
      orElse: () => null,
    ) as dynamic;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: _buildSaleLeading(context, product),
        title: Text(
          sale.productName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cantidad: ${sale.quantity}'),
            Text(
              '${_formatDate(sale.saleDate)} ${_formatTime(sale.saleDate)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            if (sale.customerName != null && sale.customerName!.isNotEmpty)
              Text(
                'Cliente: ${sale.customerName}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${sale.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  '\$${sale.unitPrice.toStringAsFixed(2)} c/u',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditSaleDialog(context, ref, sale);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, ref, sale);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleLeading(BuildContext context, dynamic product) {
    final theme = Theme.of(context);
    
    if (product != null && product.hasImage == true) {
      return GestureDetector(
        onTap: () => _showProductImage(context, product),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Image.memory(
                  product.imageBytes!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.shopping_bag,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    );
                  },
                ),
                // Overlay sutil para indicar que es clickeable
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Ícono por defecto si no hay producto o no tiene imagen
      return CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.shopping_bag,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      );
    }
  }

  void _showProductImage(BuildContext context, dynamic product) {
    if (product?.hasImage != true) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          product?.name ?? 'Producto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                // Imagen
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      child: Image.memory(
                        product.imageBytes!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white70,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Error al cargar la imagen',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.read(salesDateFilterProvider) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );

    if (picked != null) {
      ref.read(salesDateFilterProvider.notifier).state = picked;
    }
  }

  void _showAddSaleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ProductSelectorDialog(),
    );
  }

  void _showEditSaleDialog(BuildContext context, WidgetRef ref, Sale sale) {
    final productRepository = ref.read(productRepositoryProvider);
    final product = productRepository.where((p) => p.id == sale.productId).firstOrNull;
    
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede editar: producto no encontrado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => SaleFormDialog(
        product: product,
        sale: sale,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Sale sale) {
    confirmDelete(
      context,
      itemName: 'venta',
      additionalMessage: 'Venta de ${sale.productName} por \$${sale.totalAmount.toStringAsFixed(2)}\n\n⚠️ Se restaurará el stock del producto (${sale.quantity} unidades)',
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteSaleWithStockReversal(context, ref, sale);
      }
    });
  }

  void _deleteSaleWithStockReversal(BuildContext context, WidgetRef ref, Sale sale) {
    final saleRepo = ref.read(saleRepositoryProvider.notifier);
    final productRepo = ref.read(productRepositoryProvider.notifier);
    
    // Get the product to restore stock
    final product = ref.read(productRepositoryProvider)
        .where((p) => p.id == sale.productId)
        .firstOrNull;
    
    if (product != null) {
      // Restore stock
      final updatedProduct = product.copyWith(
        quantity: product.quantity + sale.quantity,
      );
      productRepo.updateProduct(updatedProduct);
    }
    
    // Delete the sale
    saleRepo.deleteSale(sale.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product != null 
            ? 'Venta eliminada y stock restaurado (+${sale.quantity} ${sale.productName})'
            : 'Venta eliminada (producto no encontrado para restaurar stock)'
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}