import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';

class QrViewDialog extends StatelessWidget {
  final Product product;

  const QrViewDialog({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productInfo = _buildProductInfo();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Código QR',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // QR Code placeholder (se podría implementar con qr_flutter)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'QR Code',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.id,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Product info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Producto',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...productInfo.map((info) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${info['label']}: ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    info['value']!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ID copyable
                  Card(
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID del Producto',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.id,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton(
                                onPressed: () => _copyToClipboard(context, product.id),
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copiar ID',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareProduct(context),
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printQR(context),
                      icon: const Icon(Icons.print),
                      label: const Text('Imprimir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _buildProductInfo() {
    return [
      {'label': 'Nombre', 'value': product.name},
      {'label': 'Categoría', 'value': product.category},
      {'label': 'Precio', 'value': '\$${product.price.toStringAsFixed(2)}'},
      {'label': 'Cantidad', 'value': product.quantity.toString()},
      if (product.description != null && product.description!.isNotEmpty)
        {'label': 'Descripción', 'value': product.description!},
    ];
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ID copiado al portapapeles'),
        duration: AppDurations.snackBar,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareProduct(BuildContext context) {
    final productText = '''
${product.name}
Categoría: ${product.category}
Precio: \$${product.price.toStringAsFixed(2)}
Cantidad: ${product.quantity}
${product.description != null ? 'Descripción: ${product.description}' : ''}
ID: ${product.id}
''';

    // En un proyecto real, se usaría share_plus para compartir
    Clipboard.setData(ClipboardData(text: productText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Información del producto copiada al portapapeles'),
        duration: AppDurations.snackBar,
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _printQR(BuildContext context) {
    // En un proyecto real, se implementaría la funcionalidad de impresión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidad de impresión no implementada'),
        duration: AppDurations.snackBar,
        backgroundColor: Colors.orange,
      ),
    );
  }
}

// Función helper para mostrar el diálogo
Future<void> showQrViewDialog(
  BuildContext context, {
  required Product product,
}) {
  return showDialog(
    context: context,
    builder: (context) => QrViewDialog(product: product),
  );
}