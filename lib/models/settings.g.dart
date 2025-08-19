// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 5;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      storeName: fields[0] as String,
      currency: fields[1] as String,
      showLowStockWarnings: fields[2] as bool,
      lowStockThreshold: fields[3] as int,
      enableNotifications: fields[4] as bool,
      darkMode: fields[5] as bool,
      language: fields[6] as String,
      defaultPriceMode: fields[7] as PriceMode,
      enableBarcode: fields[8] as bool,
      lastBackup: fields[9] as DateTime,
      backupPath: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.storeName)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.showLowStockWarnings)
      ..writeByte(3)
      ..write(obj.lowStockThreshold)
      ..writeByte(4)
      ..write(obj.enableNotifications)
      ..writeByte(5)
      ..write(obj.darkMode)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.defaultPriceMode)
      ..writeByte(8)
      ..write(obj.enableBarcode)
      ..writeByte(9)
      ..write(obj.lastBackup)
      ..writeByte(10)
      ..write(obj.backupPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StockLevelAdapter extends TypeAdapter<StockLevel> {
  @override
  final int typeId = 2;

  @override
  StockLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StockLevel.high;
      case 1:
        return StockLevel.medium;
      case 2:
        return StockLevel.low;
      case 3:
        return StockLevel.outOfStock;
      default:
        return StockLevel.high;
    }
  }

  @override
  void write(BinaryWriter writer, StockLevel obj) {
    switch (obj) {
      case StockLevel.high:
        writer.writeByte(0);
        break;
      case StockLevel.medium:
        writer.writeByte(1);
        break;
      case StockLevel.low:
        writer.writeByte(2);
        break;
      case StockLevel.outOfStock:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SizeAdapter extends TypeAdapter<Size> {
  @override
  final int typeId = 3;

  @override
  Size read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Size.xs;
      case 1:
        return Size.s;
      case 2:
        return Size.m;
      case 3:
        return Size.l;
      case 4:
        return Size.xl;
      case 5:
        return Size.xxl;
      case 6:
        return Size.oneSize;
      case 7:
        return Size.noSize;
      default:
        return Size.xs;
    }
  }

  @override
  void write(BinaryWriter writer, Size obj) {
    switch (obj) {
      case Size.xs:
        writer.writeByte(0);
        break;
      case Size.s:
        writer.writeByte(1);
        break;
      case Size.m:
        writer.writeByte(2);
        break;
      case Size.l:
        writer.writeByte(3);
        break;
      case Size.xl:
        writer.writeByte(4);
        break;
      case Size.xxl:
        writer.writeByte(5);
        break;
      case Size.oneSize:
        writer.writeByte(6);
        break;
      case Size.noSize:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriceModeAdapter extends TypeAdapter<PriceMode> {
  @override
  final int typeId = 4;

  @override
  PriceMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PriceMode.fixed;
      case 1:
        return PriceMode.variable;
      case 2:
        return PriceMode.promotion;
      default:
        return PriceMode.fixed;
    }
  }

  @override
  void write(BinaryWriter writer, PriceMode obj) {
    switch (obj) {
      case PriceMode.fixed:
        writer.writeByte(0);
        break;
      case PriceMode.variable:
        writer.writeByte(1);
        break;
      case PriceMode.promotion:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
