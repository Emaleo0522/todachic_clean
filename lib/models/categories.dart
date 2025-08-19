class ClothingCategories {
  static const List<String> all = [
    // Ropa Femenina
    ...feminine,
    // Accesorios
    ...accessories,
    // Ropa Masculina
    ...masculine,
  ];

  static const List<String> feminine = [
    'Blusas',
    'Camisetas',
    'Vestidos',
    'Faldas',
    'Pantalones',
    'Jeans',
    'Shorts',
    'Chaquetas',
    'Abrigos',
    'Sweaters',
    'Cardigans',
    'Ropa Interior',
    'Trajes de Baño',
    'Ropa Deportiva',
    'Pijamas',
    'Vestidos de Noche',
    'Monos',
    'Leggings',
    'Joggers',
  ];

  static const List<String> accessories = [
    'Cinturones',
    'Bolsos',
    'Carteras',
    'Pañuelos',
    'Bufandas',
    'Sombreros',
    'Gorras',
    'Joyas',
    'Aretes',
    'Collares',
    'Pulseras',
    'Anillos',
    'Relojes',
    'Gafas de Sol',
    'Guantes',
    'Medias',
    'Calcetines',
  ];

  static const List<String> masculine = [
    'Camisas Hombre',
    'Camisetas Hombre',
    'Pantalones Hombre',
    'Jeans Hombre',
    'Shorts Hombre',
    'Chaquetas Hombre',
    'Abrigos Hombre',
    'Sweaters Hombre',
    'Ropa Interior Hombre',
    'Ropa Deportiva Hombre',
    'Trajes',
    'Corbatas',
    'Cinturones Hombre',
  ];

  static String getCategoryGroup(String category) {
    if (feminine.contains(category)) return 'Femenino';
    if (accessories.contains(category)) return 'Accesorios';
    if (masculine.contains(category)) return 'Masculino';
    return 'Otros';
  }
}