import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../theme/app_theme.dart';
import 'sale_form_dialog.dart';

// Helper para detectar dispositivos móviles (incluye PWA móviles)
bool isMobileDevice(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final platform = Theme.of(context).platform;
  
  // Si es app nativa, usar Platform
  if (!kIsWeb) {
    return Platform.isAndroid || Platform.isIOS;
  }
  
  // Si es web, detectar por pantalla y user agent
  return size.width < 768 || 
         platform == TargetPlatform.android || 
         platform == TargetPlatform.iOS;
}

class QrScannerDialog extends ConsumerStatefulWidget {
  const QrScannerDialog({super.key});

  @override
  ConsumerState<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends ConsumerState<QrScannerDialog> {
  final _codeController = TextEditingController();
  bool _isProcessing = false;
  bool? _showManualInput; // Se inicializa en build
  MobileScannerController? _scannerController;
  bool _initialized = false;

  void _initializeIfNeeded(BuildContext context) {
    if (_initialized) return;
    
    final isMobile = isMobileDevice(context);
    _showManualInput = !isMobile; // En móvil empezar con cámara por defecto
    
    // Siempre crear el controller para dispositivos móviles
    if (isMobile) {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        detectionTimeoutMs: 1000,
      );
    }
    
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    _initializeIfNeeded(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: (_showManualInput ?? true) ? null : MediaQuery.of(context).size.height * 0.7,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: (_showManualInput ?? true) ? 600 : MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: (_showManualInput ?? true) ? MainAxisSize.min : MainAxisSize.max,
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
                  Icon(
                    (_showManualInput ?? true) ? Icons.qr_code : Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      (_showManualInput ?? true) ? 'Buscar por Código' : 'Escanear QR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isMobileDevice(context))
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showManualInput = !(_showManualInput ?? true);
                        });
                      },
                      icon: Icon(
                        (_showManualInput ?? true) ? Icons.camera_alt : Icons.keyboard,
                        color: Colors.white,
                      ),
                      tooltip: (_showManualInput ?? true) ? 'Usar cámara' : 'Introducir código',
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            if (_showManualInput ?? true)
              _buildManualInput()
            else
              Expanded(child: _buildCameraScanner()),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInput() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info message
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    !isMobileDevice(context) 
                        ? 'Introduce el código QR del producto manualmente.'
                        : 'Introduce el código o usa el botón de cámara.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Input field
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Código QR del producto',
              hintText: 'TODACHIC:xxxxx-xxxxx-xxxxx',
              prefixIcon: Icon(Icons.qr_code),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            autofocus: true,
            onSubmitted: (_) => _searchProduct(),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Processing indicator
          if (_isProcessing)
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Buscando producto...'),
                ],
              ),
            ),
          
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _searchProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buscar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScanner() {
    if (!isMobileDevice(context) || _scannerController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text(
              !isMobileDevice(context) ? 'Escáner no disponible en web' : 'Error al inicializar cámara',
              style: const TextStyle(color: Colors.grey),
            ),
            if (isMobileDevice(context)) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showManualInput = true;
                  });
                },
                child: const Text('Usar entrada manual'),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
        child: Stack(
          children: [
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onQRDetected,
              fit: BoxFit.cover,
              errorBuilder: (context, error, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: AppSpacing.md),
                      const Text('Error con la cámara'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        error.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showManualInput = true;
                          });
                        },
                        child: const Text('Usar entrada manual'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Overlay con instrucciones
            if (!_isProcessing)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: const Text(
                    'Apunta la cámara hacia el código QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            
            // Processing overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Procesando código...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty && !_isProcessing) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _processQrCode(code);
      }
    }
  }

  Future<void> _processQrCode(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Pausar el scanner si está activo
      if (!(_showManualInput ?? true) && _scannerController != null) {
        await _scannerController!.stop();
      }
      
      // Buscar el producto por código QR
      final product = await _findProductByQrCode(qrCode);
      
      if (product != null) {
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar scanner
          
          // Mostrar diálogo de venta del producto encontrado
          showDialog(
            context: context,
            builder: (context) => SaleFormDialog(product: product),
          );
        }
      } else {
        // Producto no encontrado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto no encontrado: $qrCode'),
              backgroundColor: Colors.orange,
            ),
          );
          
          // Reactivar scanner si es móvil
          if (!(_showManualInput ?? true) && _scannerController != null) {
            await _scannerController!.start();
          }
          
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Reactivar scanner si es móvil
        if (!(_showManualInput ?? true) && _scannerController != null) {
          await _scannerController!.start();
        }
        
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _searchProduct() async {
    final qrCode = _codeController.text.trim();
    
    if (qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor introduce un código QR'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    _processQrCode(qrCode);
  }

  Future<Product?> _findProductByQrCode(String qrCode) async {
    final products = ref.read(productRepositoryProvider);
    
    // Buscar producto que tenga este código QR
    try {
      return products.firstWhere(
        (product) => product.qrCode == qrCode || 
                    product.qrCode == 'TODACHIC:${product.id}' && qrCode.contains(product.id),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }
}

// Función helper para mostrar el escáner
Future<void> showQrScannerDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const QrScannerDialog(),
  );
}