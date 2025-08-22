import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// Imports condicionales para web
import 'dart:html' as html show AnchorElement, Blob, Url;
import '../../models/product.dart';
import '../../theme/app_theme.dart';

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
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                  // QR Code real
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: product.hasQrCode
                        ? QrImageView(
                            data: product.qrCode!,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Sin código QR',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
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
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Solo botón de descarga
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: product.hasQrCode ? () => _downloadQR(context) : null,
                      icon: const Icon(Icons.download),
                      label: const Text('Descargar PNG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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


  Future<void> _downloadQR(BuildContext context) async {
    if (!product.hasQrCode) return;
    
    try {
      // Crear imagen PNG simple con QR y código
      await _createAndDownloadQrPng(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar QR: $e'),
          duration: AppDurations.snackBar,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createAndDownloadQrPng(BuildContext context) async {
    try {
      // Crear imagen compuesta con QR y código
      final imageData = await _createQrImageWithCode();
      
      // Nombre del archivo
      final fileName = 'QR_${product.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.png';
      
      if (!kIsWeb) {
        // App nativa - guardar archivo
        await _saveImageNative(imageData, fileName, context);
      } else {
        // Web - descargar archivo real
        await _downloadImageWeb(imageData, fileName, context);
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear QR: $e'),
            duration: AppDurations.snackBar,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<Uint8List> _createQrImageWithCode() async {
    // Crear el QR painter
    final qrPainter = QrPainter(
      data: product.qrCode!,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    );
    
    // Dimensiones de la imagen final
    const double qrSize = 300.0;
    const double totalWidth = 350.0;
    const double totalHeight = 400.0;
    const double margin = 25.0;
    
    // Crear el recorder para dibujar
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Fondo blanco
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, totalWidth, totalHeight),
      paint,
    );
    
    // Dibujar el QR centrado
    final qrRect = Rect.fromLTWH(
      (totalWidth - qrSize) / 2,
      margin,
      qrSize,
      qrSize,
    );
    canvas.save();
    canvas.translate(qrRect.left, qrRect.top);
    qrPainter.paint(canvas, qrRect.size);
    canvas.restore();
    
    // Preparar el texto del código
    final textPainter = TextPainter(
      text: TextSpan(
        text: product.qrCode!,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Dibujar el código debajo del QR
    final textY = margin + qrSize + 20;
    final textX = (totalWidth - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
    
    // Agregar nombre del producto (opcional, más pequeño)
    if (product.name.length <= 30) {
      final nameTextPainter = TextPainter(
        text: TextSpan(
          text: product.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      );
      nameTextPainter.layout(maxWidth: totalWidth - 40);
      
      final nameY = textY + textPainter.height + 10;
      final nameX = (totalWidth - nameTextPainter.width) / 2;
      nameTextPainter.paint(canvas, Offset(nameX, nameY));
    }
    
    // Convertir a imagen
    final picture = recorder.endRecording();
    final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  Future<void> _saveImageNative(Uint8List imageData, String fileName, BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageData);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR guardado: $fileName'),
            duration: AppDurations.snackBar,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            duration: AppDurations.snackBar,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _downloadImageWeb(Uint8List imageData, String fileName, BuildContext context) async {
    if (kIsWeb) {
      try {
        // Para web, crear un enlace de descarga
        final blob = html.Blob([imageData]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Descargando: $fileName'),
              duration: AppDurations.snackBar,
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Fallback a compartir si falla la descarga
        try {
          await Share.shareXFiles(
            [XFile.fromData(imageData, name: fileName, mimeType: 'image/png')],
            text: 'Código QR - ${product.name}',
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('QR compartido (descarga no disponible)'),
                duration: AppDurations.snackBar,
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (shareError) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $shareError'),
                duration: AppDurations.snackBar,
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
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