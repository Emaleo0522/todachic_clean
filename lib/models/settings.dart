import 'package:hive/hive.dart';

part 'settings.g.dart';

// Enum para niveles de stock
@HiveType(typeId: 2)
enum StockLevel {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
  @HiveField(3)
  outOfStock,
}

// Enum para tallas
@HiveType(typeId: 3)
enum Size {
  @HiveField(0)
  xs,
  @HiveField(1)
  s,
  @HiveField(2)
  m,
  @HiveField(3)
  l,
  @HiveField(4)
  xl,
  @HiveField(5)
  xxl,
  @HiveField(6)
  oneSize,
  @HiveField(7)
  noSize,
}

// Enum para modo de precios
@HiveType(typeId: 4)
enum PriceMode {
  @HiveField(0)
  fixed,
  @HiveField(1)
  variable,
  @HiveField(2)
  promotion,
}

// Extensiones para obtener valores legibles
extension StockLevelExtension on StockLevel {
  String get displayName {
    switch (this) {
      case StockLevel.high:
        return 'Alto';
      case StockLevel.medium:
        return 'Medio';
      case StockLevel.low:
        return 'Bajo';
      case StockLevel.outOfStock:
        return 'Sin Stock';
    }
  }

  String get description {
    switch (this) {
      case StockLevel.high:
        return 'Stock suficiente';
      case StockLevel.medium:
        return 'Stock moderado';
      case StockLevel.low:
        return 'Stock bajo - Reabastecer pronto';
      case StockLevel.outOfStock:
        return 'Sin stock disponible';
    }
  }
}

extension SizeExtension on Size {
  String get displayName {
    switch (this) {
      case Size.xs:
        return 'XS';
      case Size.s:
        return 'S';
      case Size.m:
        return 'M';
      case Size.l:
        return 'L';
      case Size.xl:
        return 'XL';
      case Size.xxl:
        return 'XXL';
      case Size.oneSize:
        return 'Única';
      case Size.noSize:
        return 'Sin Talle';
    }
  }

  String get name {
    switch (this) {
      case Size.xs:
        return 'xs';
      case Size.s:
        return 's';
      case Size.m:
        return 'm';
      case Size.l:
        return 'l';
      case Size.xl:
        return 'xl';
      case Size.xxl:
        return 'xxl';
      case Size.oneSize:
        return 'onesize';
      case Size.noSize:
        return 'nosize';
    }
  }
}

extension PriceModeExtension on PriceMode {
  String get displayName {
    switch (this) {
      case PriceMode.fixed:
        return 'Precio Fijo';
      case PriceMode.variable:
        return 'Precio Variable';
      case PriceMode.promotion:
        return 'Promoción';
    }
  }
}

// Clase principal de configuraciones
@HiveType(typeId: 5)
class Settings extends HiveObject {
  @HiveField(0)
  String storeName;

  @HiveField(1)
  String currency;

  @HiveField(2)
  bool showLowStockWarnings;

  @HiveField(3)
  int lowStockThreshold;

  @HiveField(4)
  bool enableNotifications;

  @HiveField(5)
  bool darkMode;

  @HiveField(6)
  String language;

  @HiveField(7)
  PriceMode defaultPriceMode;

  @HiveField(8)
  bool enableBarcode;

  @HiveField(9)
  DateTime lastBackup;

  @HiveField(10)
  String backupPath;

  Settings({
    this.storeName = 'TODAChic',
    this.currency = '\$',
    this.showLowStockWarnings = true,
    this.lowStockThreshold = 10,
    this.enableNotifications = true,
    this.darkMode = false,
    this.language = 'es',
    this.defaultPriceMode = PriceMode.fixed,
    this.enableBarcode = true,
    required this.lastBackup,
    this.backupPath = '',
  });

  Settings copyWith({
    String? storeName,
    String? currency,
    bool? showLowStockWarnings,
    int? lowStockThreshold,
    bool? enableNotifications,
    bool? darkMode,
    String? language,
    PriceMode? defaultPriceMode,
    bool? enableBarcode,
    DateTime? lastBackup,
    String? backupPath,
  }) {
    return Settings(
      storeName: storeName ?? this.storeName,
      currency: currency ?? this.currency,
      showLowStockWarnings: showLowStockWarnings ?? this.showLowStockWarnings,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      defaultPriceMode: defaultPriceMode ?? this.defaultPriceMode,
      enableBarcode: enableBarcode ?? this.enableBarcode,
      lastBackup: lastBackup ?? this.lastBackup,
      backupPath: backupPath ?? this.backupPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'currency': currency,
      'showLowStockWarnings': showLowStockWarnings,
      'lowStockThreshold': lowStockThreshold,
      'enableNotifications': enableNotifications,
      'darkMode': darkMode,
      'language': language,
      'defaultPriceMode': defaultPriceMode.index,
      'enableBarcode': enableBarcode,
      'lastBackup': lastBackup.toIso8601String(),
      'backupPath': backupPath,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      storeName: json['storeName'] ?? 'TODAChic',
      currency: json['currency'] ?? '\$',
      showLowStockWarnings: json['showLowStockWarnings'] ?? true,
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      enableNotifications: json['enableNotifications'] ?? true,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'es',
      defaultPriceMode: PriceMode.values[json['defaultPriceMode'] ?? 0],
      enableBarcode: json['enableBarcode'] ?? true,
      lastBackup: DateTime.parse(json['lastBackup'] ?? DateTime.now().toIso8601String()),
      backupPath: json['backupPath'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Settings(storeName: $storeName, currency: $currency, darkMode: $darkMode)';
  }
}