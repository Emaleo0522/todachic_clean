import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/confirmation_dialog.dart';

class SaleFormDialog extends ConsumerStatefulWidget {
  final Product? product;
  final Sale? sale;

  const SaleFormDialog({super.key, this.product, this.sale});

  @override
  ConsumerState<SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends ConsumerState<SaleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.sale != null) {
      _quantityController.text = widget.sale!.quantity.toString();
      _priceController.text = widget.sale!.unitPrice.toString();
    } else {
      _quantityController.text = '1';
      _priceController.text = widget.product?.unitPrice.toString() ?? '0';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final unitPrice = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * unitPrice;
    
    return AlertDialog(
      title: Text(widget.sale == null ? 'Nueva venta' : 'Editar venta'),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product?.name ?? 'Producto desconocido',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.product?.category ?? 'Sin categoría'),
                      Text(
                        widget.sale == null 
                          ? 'Stock disponible: ${widget.product?.quantity ?? 0}'
                          : 'Stock disponible: ${(widget.product?.quantity ?? 0) + widget.sale!.quantity} (incluyendo venta actual)',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Cantidad inválida';
                  }
                  
                  // For new sales, check if stock is sufficient
                  if (widget.sale == null) {
                    if (qty > (widget.product?.quantity ?? 0)) {
                      return 'Stock insuficiente';
                    }
                  } else {
                    // For editing sales, check available stock + original sale quantity
                    final originalQuantity = widget.sale!.quantity;
                    final availableStock = (widget.product?.quantity ?? 0) + originalQuantity;
                    if (qty > availableStock) {
                      return 'Stock insuficiente (disponible: $availableStock)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio unitario',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.sale == null ? 'Registrar' : 'Guardar'),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final unitPrice = double.parse(_priceController.text);
      
      final confirmed = await confirmAction(
        context,
        title: 'Confirmar venta',
        message: 'Total: \$${(quantity * unitPrice).toStringAsFixed(2)}',
        actionText: 'Confirmar',
        icon: Icons.point_of_sale,
      );

      if (confirmed != true) return;

      final productRepo = ref.read(productRepositoryProvider.notifier);

      if (widget.sale == null) {
        // Nueva venta
        final sale = Sale(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: widget.product?.id ?? '',
          productName: widget.product?.name ?? 'Producto desconocido',
          quantity: quantity,
          unitPrice: unitPrice,
          totalAmount: quantity * unitPrice,
          saleDate: DateTime.now(),
        );
        
        ref.read(saleRepositoryProvider.notifier).addSale(sale);
        
        // Actualizar stock y verificar stock bajo
        if (widget.product != null) {
          final updatedProduct = widget.product!.copyWith(
            quantity: widget.product!.quantity - quantity,
          );
          productRepo.updateProduct(updatedProduct);
          
          // Verificar stock bajo si las notificaciones están habilitadas
          final settings = ref.read(settingsRepositoryProvider);
          if (settings.enableNotifications && settings.showLowStockWarnings && 
              updatedProduct.quantity <= settings.lowStockThreshold) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Atención! Stock bajo para ${updatedProduct.name}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        
        Navigator.of(context).pop();
        
        // Notificación de venta completada si está habilitada
        final settings = ref.read(settingsRepositoryProvider);
        if (settings.enableNotifications) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Venta completada: ${widget.product!.name} x$quantity'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Editar venta existente
        final oldSale = widget.sale!;
        final updatedSale = oldSale.copyWith(
          quantity: quantity,
          unitPrice: unitPrice,
          totalAmount: quantity * unitPrice, // Recalculate total
        );
        
        ref.read(saleRepositoryProvider.notifier).updateSale(updatedSale);
        
        // Ajustar stock basado en la diferencia
        final stockDiff = oldSale.quantity - quantity; // Positive = restore stock, Negative = reduce stock
        if (widget.product != null) {
          final updatedProduct = widget.product!.copyWith(
            quantity: widget.product!.quantity + stockDiff,
          );
          productRepo.updateProduct(updatedProduct);
          
          // Check for low stock warning after edit si las notificaciones están habilitadas
          final settings = ref.read(settingsRepositoryProvider);
          if (settings.enableNotifications && settings.showLowStockWarnings && 
              updatedProduct.quantity <= settings.lowStockThreshold && updatedProduct.quantity >= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Stock bajo para ${updatedProduct.name}: ${updatedProduct.quantity} unidades'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        
        Navigator.of(context).pop();
        
        // Notificación de venta editada si está habilitada
        final settings = ref.read(settingsRepositoryProvider);
        if (settings.enableNotifications) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✏️ Venta actualizada: ${oldSale.quantity} → $quantity unidades'
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}