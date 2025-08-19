import 'package:hive/hive.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/settings.dart';

void registerAdapters() {
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(StockLevelAdapter());
  Hive.registerAdapter(PriceModeAdapter());
  Hive.registerAdapter(SizeAdapter());
}

class StockLevelAdapter extends TypeAdapter<StockLevel> {
  @override
  final int typeId = 3;

  @override
  StockLevel read(BinaryReader reader) {
    return StockLevel.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, StockLevel obj) {
    writer.writeByte(obj.index);
  }
}

class PriceModeAdapter extends TypeAdapter<PriceMode> {
  @override
  final int typeId = 4;

  @override
  PriceMode read(BinaryReader reader) {
    return PriceMode.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, PriceMode obj) {
    writer.writeByte(obj.index);
  }
}

class SizeAdapter extends TypeAdapter<Size> {
  @override
  final int typeId = 5;

  @override
  Size read(BinaryReader reader) {
    return Size.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, Size obj) {
    writer.writeByte(obj.index);
  }
}