import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../data/repositories/product_repository.dart';
import '../../ui/widgets/stock_level_pill.dart';
import '../../theme/app_theme.dart';
import 'product_form_dialog.dart';
import 'qr_view_dialog.dart';
import '../sales/sale_form_dialog.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);
    final stockLevel = product.getStockLevel(lowThreshold: settings.lowStockThreshold);
    
    return Card(
      child: InkWell(
        onTap: () => _handleMenuAction(context, ref, 'edit'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Avatar con indicador de stock
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: StockLevelIndicator(
                      level: stockLevel,
                      size: 14,
                      showPulse: stockLevel == StockLevel.low,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Precio y cantidad
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${product.unitPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stock: ${product.quantity}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Talle y nivel de stock
                    Row(
                      children: [
                        if (product.size != null && product.size != Size.noSize) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              'Talle ${product.size!.name.toUpperCase()}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        StockLevelPill(
                          level: stockLevel,
                          quantity: product.quantity,
                          showQuantity: false,
                          size: 0.8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Acciones rápidas
              Column(
                children: [
                  // Botón de venta rápida (solo si hay stock)
                  if (product.quantity > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: IconButton(
                        onPressed: () => _handleMenuAction(context, ref, 'sell'),
                        icon: const Icon(Icons.point_of_sale),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Venta rápida',
                      ),
                    ),
                  
                  // Menú de acciones
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, ref, value),
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    itemBuilder: (context) => [
                      if (product.quantity > 0)
                        PopupMenuItem(
                          value: 'sell',
                          child: Row(
                            children: [
                              Icon(
                                Icons.point_of_sale,
                                size: 20,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Vender',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'qr',
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code_2_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Text('Ver QR'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'sell':
        showDialog(
          context: context,
          builder: (context) => SaleFormDialog(product: product),
        );
        break;
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => ProductFormDialog(product: product),
        );
        break;
      case 'qr':
        showDialog(
          context: context,
          builder: (context) => QrViewDialog(product: product),
        );
        break;
      case 'delete':
        final confirmed = await confirmDelete(
          context,
          itemName: 'producto',
          additionalMessage: '¿Estás seguro de que quieres eliminar "${product.name}"?',
        );
        if (confirmed == true) {
          final productRepo = ref.read(productRepositoryProvider.notifier);
          productRepo.deleteProduct(product.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto eliminado')),
            );
          }
        }
        break;
    }
  }
}