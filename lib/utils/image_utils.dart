import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImageUtils {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const double compressionQuality = 0.85;

  // Validar tipo de archivo de imagen
  static bool isValidImageType(String? fileName) {
    if (fileName == null) return false;
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  // Validar tamaño de archivo
  static bool isValidFileSize(Uint8List bytes) {
    return bytes.length <= maxFileSizeBytes;
  }

  // Comprimir imagen usando la librería image
  static String compressImageToBase64(Uint8List imageBytes, {double quality = 0.85}) {
    try {
      // Decodificar la imagen
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        // Si no se puede decodificar, usar compresión básica
        return _basicCompress(imageBytes);
      }
      
      // Redimensionar si es necesario
      if (image.width > maxWidth || image.height > maxHeight) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height > image.width ? maxHeight : null,
          interpolation: img.Interpolation.linear,
        );
      }
      
      // Comprimir a JPEG con calidad especificada
      final compressedBytes = img.encodeJpg(image, quality: (quality * 100).round());
      
      // Verificar si el resultado es aceptable
      if (compressedBytes.length <= maxFileSizeBytes) {
        return base64Encode(compressedBytes);
      }
      
      // Si aún es muy grande, reducir más la calidad
      final finalBytes = img.encodeJpg(image, quality: 60);
      return base64Encode(finalBytes);
      
    } catch (e) {
      // Si falla la compresión avanzada, usar método básico
      return _basicCompress(imageBytes);
    }
  }
  
  // Método de compresión básica como fallback
  static String _basicCompress(Uint8List imageBytes) {
    if (imageBytes.length <= maxFileSizeBytes) {
      return base64Encode(imageBytes);
    }
    
    final compressionRatio = imageBytes.length / maxFileSizeBytes;
    final step = math.max(1, compressionRatio.round());
    
    final compressedBytes = <int>[];
    for (int i = 0; i < imageBytes.length; i += step) {
      compressedBytes.add(imageBytes[i]);
    }
    
    return base64Encode(Uint8List.fromList(compressedBytes));
  }

  // Crear thumbnail (versión pequeña para listas)
  static String createThumbnail(String base64Image) {
    try {
      final bytes = base64Decode(base64Image);
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return base64Image;
      
      // Crear thumbnail de 200x200 máximo
      final thumbnail = img.copyResize(
        image,
        width: 200,
        height: 200,
        interpolation: img.Interpolation.linear,
      );
      
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);
      return base64Encode(thumbnailBytes);
    } catch (e) {
      return base64Image; // Retornar original si falla
    }
  }

  // Convertir Uint8List a Base64
  static String uint8ListToBase64(Uint8List bytes) {
    if (!isValidFileSize(bytes)) {
      return compressImageToBase64(bytes);
    }
    return base64Encode(bytes);
  }

  // Convertir Base64 a Uint8List
  static Uint8List? base64ToUint8List(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  // Obtener tamaño estimado de imagen en KB
  static int getImageSizeKB(String base64Image) {
    try {
      final bytes = base64Decode(base64Image);
      return (bytes.length / 1024).round();
    } catch (e) {
      return 0;
    }
  }

  // Formatear tamaño de archivo para mostrar al usuario
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}