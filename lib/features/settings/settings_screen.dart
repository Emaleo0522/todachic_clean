import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../models/settings.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      body: _buildSettingsContent(context, ref, settings),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, Settings settings) {
    return ListView(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl, // Más espacio para mobile
      ),
      children: [
        // App Info Section
        _buildSection(
          context,
          'Información de la Tienda',
          [
            _buildStoreName(context, ref, settings),
            _buildCurrency(context, ref, settings),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Inventory Settings
        _buildSection(
          context,
          'Inventario',
          [
            _buildLowStockWarnings(context, ref, settings),
            _buildLowStockThreshold(context, ref, settings),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // App Settings
        _buildSection(
          context,
          'Aplicación',
          [
            _buildDarkMode(context, ref, settings),
            _buildNotifications(context, ref, settings),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Backup Simple
        _buildSection(
          context,
          'Respaldo',
          [
            _buildExportButton(context, ref),
            _buildImportButton(context, ref),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // App Info
        _buildSection(
          context,
          'Acerca de',
          [
            _buildAppInfo(context),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }


  Widget _buildStoreName(BuildContext context, WidgetRef ref, Settings settings) {
    return ListTile(
      leading: const Icon(Icons.store),
      title: const Text('Nombre de la tienda'),
      subtitle: Text(settings.storeName),
      trailing: const Icon(Icons.edit),
      onTap: () => _editStoreName(context, ref, settings),
    );
  }

  Widget _buildCurrency(BuildContext context, WidgetRef ref, Settings settings) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Moneda'),
      subtitle: Text(settings.currency),
      trailing: const Icon(Icons.edit),
      onTap: () => _editCurrency(context, ref, settings),
    );
  }

  Widget _buildLowStockWarnings(BuildContext context, WidgetRef ref, Settings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.warning),
      title: const Text('Alertas de stock bajo'),
      subtitle: const Text('Mostrar avisos cuando el stock esté bajo'),
      value: settings.showLowStockWarnings,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(showLowStockWarnings: value);
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildLowStockThreshold(BuildContext context, WidgetRef ref, Settings settings) {
    return ListTile(
      leading: const Icon(Icons.inventory),
      title: const Text('Umbral de stock bajo'),
      subtitle: Text('Alertar cuando queden ${settings.lowStockThreshold} unidades o menos'),
      trailing: const Icon(Icons.edit),
      onTap: () => _editLowStockThreshold(context, ref, settings),
    );
  }

  Widget _buildDarkMode(BuildContext context, WidgetRef ref, Settings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode),
      title: const Text('Modo oscuro'),
      subtitle: const Text('Usar tema oscuro en la aplicación'),
      value: settings.darkMode,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(darkMode: value);
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildNotifications(BuildContext context, WidgetRef ref, Settings settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications),
      title: const Text('Notificaciones'),
      subtitle: const Text('Recibir notificaciones de la app'),
      value: settings.enableNotifications,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(enableNotifications: value);
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }



  Widget _buildAppInfo(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Versión'),
          subtitle: const Text('TODAChic v1.2.0 - Export/Import Ready'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Desarrollado con'),
          subtitle: const Text('Flutter & Dart'),
        ),
        ListTile(
          leading: const Icon(Icons.favorite, color: Colors.red),
          title: const Text('Hecho con amor'),
          subtitle: const Text('Para gestión de tiendas'),
        ),
      ],
    );
  }

  // Simple Export Button
  Widget _buildExportButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.download, color: Colors.blue.shade600),
      title: const Text('Exportar Datos'),
      subtitle: const Text('Descargar respaldo JSON'),
      onTap: () => _exportData(context, ref),
    );
  }

  // Simple Import Button  
  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.upload, color: Colors.green.shade600),
      title: const Text('Importar Datos'),
      subtitle: const Text('Cargar desde archivo JSON'),
      onTap: () => _importData(context, ref),
    );
  }

  // Export function - Anchor Download Method
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      // Get all data
      final products = ref.read(productRepositoryProvider);
      final sales = ref.read(saleRepositoryProvider);
      final settings = ref.read(settingsRepositoryProvider);

      // Create export data structure
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'storeName': settings.storeName,
        'data': {
          'products': products.map((p) => _productToMap(p)).toList(),
          'sales': sales.map((s) => _saleToMap(s)).toList(),
          'settings': _settingsToMap(settings),
        }
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Create download using anchor method
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final fileName = 'todachic_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
        
      html.Url.revokeObjectUrl(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos exportados: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Import function - HTML Input File Method
  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      // Create invisible file input
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
        ..accept = '.json'
        ..click();

      final completer = Completer<Map<String, dynamic>?>();
      
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files?.isNotEmpty == true) {
          final file = files![0];
          final reader = html.FileReader();
          reader.readAsText(file);
          reader.onLoadEnd.listen((e) {
            try {
              final jsonString = reader.result as String;
              final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
              completer.complete(jsonData);
            } catch (e) {
              completer.complete(null);
            }
          });
        } else {
          completer.complete(null);
        }
      });
      
      final jsonData = await completer.future;
      
      if (jsonData != null) {
        // Show confirmation dialog
        final confirmed = await _showImportConfirmation(context, jsonData);
        if (confirmed == true) {
          await _processImportData(ref, jsonData);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos importados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper functions for JSON conversion
  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'costPrice': product.costPrice,
      'quantity': product.quantity,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _saleToMap(Sale sale) {
    return {
      'id': sale.id,
      'productId': sale.productId,
      'productName': sale.productName,
      'quantity': sale.quantity,
      'unitPrice': sale.unitPrice,
      'totalAmount': sale.totalAmount,
      'saleDate': sale.saleDate.toIso8601String(),
      'customerName': sale.customerName,
      'notes': sale.notes,
    };
  }

  Map<String, dynamic> _settingsToMap(Settings settings) {
    return {
      'storeName': settings.storeName,
      'currency': settings.currency,
      'darkMode': settings.darkMode,
      'enableNotifications': settings.enableNotifications,
      'showLowStockWarnings': settings.showLowStockWarnings,
      'lowStockThreshold': settings.lowStockThreshold,
    };
  }

  // Import confirmation dialog
  Future<bool?> _showImportConfirmation(BuildContext context, Map<String, dynamic> jsonData) {
    final data = jsonData['data'] as Map<String, dynamic>? ?? {};
    final products = data['products'] as List? ?? [];
    final sales = data['sales'] as List? ?? [];
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Importar datos?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se encontraron:'),
            const SizedBox(height: 8),
            Text('• Productos: ${products.length}'),
            Text('• Ventas: ${sales.length}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ Los datos actuales serán reemplazados',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  // Process imported data
  Future<void> _processImportData(WidgetRef ref, Map<String, dynamic> jsonData) async {
    final data = jsonData['data'] as Map<String, dynamic>? ?? {};
    
    // Clear existing data
    final currentProducts = ref.read(productRepositoryProvider);
    for (final product in currentProducts) {
      ref.read(productRepositoryProvider.notifier).deleteProduct(product.id);
    }
    
    final currentSales = ref.read(saleRepositoryProvider);
    for (final sale in currentSales) {
      ref.read(saleRepositoryProvider.notifier).deleteSale(sale.id);
    }
    
    // Import products
    final productsData = data['products'] as List? ?? [];
    for (final productMap in productsData) {
      try {
        final product = Product(
          id: productMap['id']?.toString() ?? '',
          name: productMap['name']?.toString() ?? '',
          category: productMap['category']?.toString() ?? '',
          price: (productMap['price'] as num?)?.toDouble() ?? 0.0,
          costPrice: (productMap['costPrice'] as num?)?.toDouble() ?? 0.0,
          quantity: (productMap['quantity'] as num?)?.toInt() ?? 0,
          description: productMap['description']?.toString() ?? '',
          imageUrl: productMap['imageUrl']?.toString() ?? '',
          createdAt: DateTime.tryParse(productMap['createdAt']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(productMap['updatedAt']?.toString() ?? '') ?? DateTime.now(),
        );
        ref.read(productRepositoryProvider.notifier).addProduct(product);
      } catch (e) {
        print('Error importing product: $e');
        // Skip this product and continue
      }
    }
    
    // Import sales
    final salesData = data['sales'] as List? ?? [];
    for (final saleMap in salesData) {
      try {
        final sale = Sale(
          id: saleMap['id']?.toString() ?? '',
          productId: saleMap['productId']?.toString() ?? '',
          productName: saleMap['productName']?.toString() ?? '',
          quantity: (saleMap['quantity'] as num?)?.toInt() ?? 0,
          unitPrice: (saleMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
          totalAmount: (saleMap['totalAmount'] as num?)?.toDouble() ?? 0.0,
          saleDate: DateTime.tryParse(saleMap['saleDate']?.toString() ?? '') ?? DateTime.now(),
          customerName: saleMap['customerName']?.toString() ?? '',
          notes: saleMap['notes']?.toString() ?? '',
        );
        ref.read(saleRepositoryProvider.notifier).addSale(sale);
      } catch (e) {
        print('Error importing sale: $e');
        // Skip this sale and continue
      }
    }
    
    // Import settings
    final settingsData = data['settings'] as Map<String, dynamic>? ?? {};
    if (settingsData.isNotEmpty) {
      try {
        final currentSettings = ref.read(settingsRepositoryProvider);
        final updatedSettings = currentSettings.copyWith(
          storeName: settingsData['storeName']?.toString() ?? currentSettings.storeName,
          currency: settingsData['currency']?.toString() ?? currentSettings.currency,
          darkMode: settingsData['darkMode'] as bool? ?? currentSettings.darkMode,
          enableNotifications: settingsData['enableNotifications'] as bool? ?? currentSettings.enableNotifications,
          showLowStockWarnings: settingsData['showLowStockWarnings'] as bool? ?? currentSettings.showLowStockWarnings,
          lowStockThreshold: (settingsData['lowStockThreshold'] as num?)?.toInt() ?? currentSettings.lowStockThreshold,
        );
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      } catch (e) {
        print('Error importing settings: $e');
        // Continue without importing settings
      }
    }
  }

  void _editStoreName(BuildContext context, WidgetRef ref, Settings settings) {
    _showEditDialog(
      context,
      'Nombre de la tienda',
      settings.storeName,
      (value) {
        final updatedSettings = settings.copyWith(storeName: value);
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  void _editCurrency(BuildContext context, WidgetRef ref, Settings settings) {
    _showEditDialog(
      context,
      'Símbolo de moneda',
      settings.currency,
      (value) {
        final updatedSettings = settings.copyWith(currency: value);
        ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
      },
      maxLength: 3,
    );
  }

  void _editLowStockThreshold(BuildContext context, WidgetRef ref, Settings settings) {
    _showEditDialog(
      context,
      'Umbral de stock bajo',
      settings.lowStockThreshold.toString(),
      (value) {
        final threshold = int.tryParse(value);
        if (threshold != null && threshold > 0) {
          final updatedSettings = settings.copyWith(lowStockThreshold: threshold);
          ref.read(settingsRepositoryProvider.notifier).updateSettings(updatedSettings);
        }
      },
      keyboardType: TextInputType.number,
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave, {
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            counterText: maxLength != null ? null : '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

}