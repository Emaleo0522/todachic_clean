import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../models/categories.dart';
import '../../data/repositories/product_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_utils.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product; // null para crear, Product para editar

  const ProductFormDialog({
    super.key,
    this.product,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;
  bool _usePercentageCalculation = false;
  double _profitPercentage = 50.0;
  
  // Para el buscador de categorías
  final _categoryController = TextEditingController();
  String _categorySearchQuery = '';
  bool _showCategoryDropdown = false;
  
  // Para la imagen del producto
  String? _imageData; // Base64 de la imagen
  bool _isLoadingImage = false;
  
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _selectedCategory = product.category;
    _categoryController.text = product.category; // También poblar el controlador de texto
    _costPriceController.text = product.costPrice?.toString() ?? '';
    _salePriceController.text = product.price.toString();
    _quantityController.text = product.quantity.toString();
    _descriptionController.text = product.description ?? '';
    
    // Cargar imagen existente si la hay
    _imageData = product.imageData;
    
    // Si hay costo y precio, calcular el porcentaje
    if (product.costPrice != null && product.costPrice! > 0) {
      _profitPercentage = ((product.price - product.costPrice!) / product.costPrice!) * 100;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _calculateSalePrice() {
    if (_usePercentageCalculation) {
      final costPrice = double.tryParse(_costPriceController.text);
      if (costPrice != null && costPrice > 0) {
        final salePrice = costPrice * (1 + _profitPercentage / 100);
        _salePriceController.text = salePrice.toStringAsFixed(2);
      }
    }
  }

  // Filtrar categorías basado en la búsqueda
  List<String> get _filteredCategories {
    if (_categorySearchQuery.isEmpty) {
      return ClothingCategories.all;
    }
    return ClothingCategories.all
        .where((category) =>
            category.toLowerCase().contains(_categorySearchQuery.toLowerCase()))
        .toList();
  }

  // Seleccionar una categoría
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryController.text = category;
      _showCategoryDropdown = false;
      _categorySearchQuery = '';
    });
  }

  // Mostrar opciones para seleccionar imagen
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Seleccionar archivo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromFiles();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Seleccionar imagen desde la cámara
  Future<void> _pickImageFromCamera() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImage(bytes, image.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  // Seleccionar imagen desde la galería
  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImage(bytes, image.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  // Seleccionar imagen desde archivos (método original)
  Future<void> _pickImageFromFiles() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes != null) {
          await _processImage(file.bytes!, file.name);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  // Procesar imagen seleccionada
  Future<void> _processImage(Uint8List bytes, String fileName) async {
    try {
      // Validar tipo de archivo
      if (!ImageUtils.isValidImageType(fileName)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor selecciona una imagen válida (JPG, PNG, WEBP)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Comprimir y convertir a Base64
      final compressedBase64 = ImageUtils.uint8ListToBase64(bytes);

      setState(() {
        _imageData = compressedBase64;
      });

      if (mounted) {
        final finalSize = ImageUtils.base64ToUint8List(compressedBase64)?.length ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen procesada correctamente (${ImageUtils.formatFileSize(finalSize)})'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remover imagen
  void _removeImage() {
    setState(() {
      _imageData = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagen removida'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Generar código QR único para el producto
  String _generateQrCode(String productId) {
    return 'TODACHIC:$productId';
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final costPrice = _costPriceController.text.trim().isNotEmpty 
          ? double.tryParse(_costPriceController.text.trim()) 
          : null;
          
      final productId = _isEditing ? widget.product!.id : const Uuid().v4();
      final qrCode = _isEditing ? widget.product!.qrCode : _generateQrCode(productId);
      
      final product = _isEditing
          ? widget.product!.copyWith(
              name: _nameController.text.trim(),
              category: _selectedCategory ?? '',
              price: double.parse(_salePriceController.text),
              costPrice: costPrice,
              quantity: int.parse(_quantityController.text),
              description: _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              imageUrl: '', // Mantener compatibilidad
              imageData: _imageData, // Nueva imagen en Base64
              updatedAt: now,
            )
          : Product(
              id: productId,
              name: _nameController.text.trim(),
              category: _selectedCategory ?? '',
              price: double.parse(_salePriceController.text),
              costPrice: costPrice,
              quantity: int.parse(_quantityController.text),
              description: _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              imageUrl: '', // Mantener compatibilidad
              imageData: _imageData, // Nueva imagen en Base64
              qrCode: qrCode, // Código QR único
              createdAt: now,
              updatedAt: now,
            );

      final productRepository = ref.read(productRepositoryProvider.notifier);
      
      if (_isEditing) {
        productRepository.updateProduct(product);
      } else {
        productRepository.addProduct(product);
      }

      if (mounted) {
        Navigator.of(context).pop(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                ? 'Producto actualizado correctamente' 
                : 'Producto creado correctamente',
            ),
            backgroundColor: Colors.green,
            duration: AppDurations.snackBar,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el producto: $e'),
            backgroundColor: Colors.red,
            duration: AppDurations.snackBar,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.sm), // Reducir margen del diálogo
      child: GestureDetector(
        onTap: () {
          // Cerrar dropdown de categorías al hacer tap fuera
          if (_showCategoryDropdown) {
            setState(() {
              _showCategoryDropdown = false;
            });
          }
        },
        child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85, // Más responsive
        constraints: BoxConstraints(
          maxWidth: 500, 
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max, // Cambiar a max para mejor control
          children: [
            // Header - Reducir padding
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, 
                vertical: AppSpacing.sm, // Reducir padding vertical
              ),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Editar Producto' : 'Nuevo Producto',
                      style: theme.textTheme.titleMedium?.copyWith( // Reducir tamaño del título
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

            // Form - Hacer scrollable y reducir padding
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto *',
                        prefixIcon: Icon(Icons.shopping_bag),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Categoría con buscador
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'Categoría *',
                            prefixIcon: const Icon(Icons.category),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedCategory != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = null;
                                        _categoryController.clear();
                                        _showCategoryDropdown = false;
                                        _categorySearchQuery = '';
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _showCategoryDropdown 
                                        ? Icons.keyboard_arrow_up 
                                        : Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showCategoryDropdown = !_showCategoryDropdown;
                                      if (_showCategoryDropdown) {
                                        _categorySearchQuery = _categoryController.text;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _categorySearchQuery = value;
                              _showCategoryDropdown = true;
                              // Si el valor coincide exactamente con una categoría, seleccionarla
                              if (ClothingCategories.all.contains(value)) {
                                _selectedCategory = value;
                              } else {
                                _selectedCategory = null;
                              }
                            });
                          },
                          onTap: () {
                            setState(() {
                              _showCategoryDropdown = true;
                              _categorySearchQuery = _categoryController.text;
                            });
                          },
                          validator: (value) {
                            if (_selectedCategory == null || _selectedCategory!.isEmpty) {
                              return 'La categoría es requerida';
                            }
                            return null;
                          },
                        ),
                        // Dropdown con categorías filtradas
                        if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = _filteredCategories[index];
                                final group = ClothingCategories.getCategoryGroup(category);
                                final isSelected = _selectedCategory == category;
                                
                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  leading: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: group == 'Femenino' ? Colors.pink.shade300 :
                                             group == 'Masculino' ? Colors.blue.shade300 :
                                             Colors.orange.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  title: Text(category),
                                  trailing: Text(
                                    group.substring(0, 3),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  onTap: () => _selectCategory(category),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Costo básico
                    TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Costo básico (opcional)',
                        prefixIcon: Icon(Icons.shopping_cart),
                        border: OutlineInputBorder(),
                        helperText: 'Precio de compra o producción',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        if (_usePercentageCalculation) {
                          _calculateSalePrice();
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Costo inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Calculadora de precio
                    Card(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calculate, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Calculadora de precio',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Calcular por porcentaje',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        'Usar porcentaje de ganancia sobre el costo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: () {
                                    setState(() {
                                      _usePercentageCalculation = !_usePercentageCalculation;
                                      if (_usePercentageCalculation) {
                                        _calculateSalePrice();
                                      }
                                    });
                                  },
                                  child: Text(
                                    _usePercentageCalculation ? 'Cerrar' : 'Usar',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (_usePercentageCalculation) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Slider(
                                            value: _profitPercentage,
                                            min: 0,
                                            max: 200,
                                            divisions: 40,
                                            label: '${_profitPercentage.toStringAsFixed(0)}%',
                                            onChanged: (value) {
                                              setState(() {
                                                _profitPercentage = value;
                                                _calculateSalePrice();
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 60,
                                          child: Text(
                                            '${_profitPercentage.toStringAsFixed(0)}%',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    // Preview del precio calculado
                                    if (_costPriceController.text.isNotEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.preview, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Precio sugerido: \$${_salePriceController.text}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                    ],
                                    // Botones de acción
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _usePercentageCalculation = false;
                                              });
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () {
                                              // Aplicar el precio calculado y cerrar la calculadora
                                              _calculateSalePrice();
                                              setState(() {
                                                _usePercentageCalculation = false;
                                              });
                                              // Mostrar confirmación
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Precio aplicado: \$${_salePriceController.text} (${_profitPercentage.toStringAsFixed(0)}% ganancia)',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: const Text('Confirmar'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Precio de venta
                    TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio de venta *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      readOnly: _usePercentageCalculation,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio es requerido';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Cantidad (debajo del precio de venta)
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad *',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La cantidad es requerida';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity < 0) {
                          return 'Cantidad inválida';
                        }
                        return null;
                      },
                    ),

                    // Mostrar margen de ganancia si ambos precios están disponibles
                    if (_costPriceController.text.isNotEmpty && _salePriceController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Builder(
                        builder: (context) {
                          final cost = double.tryParse(_costPriceController.text) ?? 0;
                          final sale = double.tryParse(_salePriceController.text) ?? 0;
                          final profit = sale - cost;
                          final margin = cost > 0 ? (profit / cost) * 100 : 0;
                          
                          return Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: margin > 0 ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: margin > 0 ? Colors.green.shade200 : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  margin > 0 ? Icons.trending_up : Icons.info,
                                  color: margin > 0 ? Colors.green.shade600 : Colors.orange.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ganancia: \$${profit.toStringAsFixed(2)} (${margin.toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: margin > 0 ? Colors.green.shade800 : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),

                    // Sección de imagen del producto
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.photo_camera, 
                                     size: 20, 
                                     color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Foto del Producto',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '(Opcional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Agrega una foto para identificar fácilmente este producto',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            
                            // Preview de imagen o botón para agregar
                            if (_imageData != null) ...[
                              // Mostrar imagen existente
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.memory(
                                        ImageUtils.base64ToUint8List(_imageData!)!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Tamaño: ${ImageUtils.formatFileSize(ImageUtils.base64ToUint8List(_imageData!)!.length)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: _isLoadingImage ? null : _showImagePickerOptions,
                                            icon: const Icon(Icons.edit, size: 16),
                                            label: const Text('Cambiar'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: theme.colorScheme.primary,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: _removeImage,
                                            icon: const Icon(Icons.delete, size: 16),
                                            label: const Text('Quitar'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Botón para agregar imagen
                              Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    style: BorderStyle.solid,
                                  ),
                                  color: Colors.grey.shade50,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _isLoadingImage ? null : _showImagePickerOptions,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_isLoadingImage) ...[
                                          const CircularProgressIndicator(),
                                          const SizedBox(height: 8),
                                          const Text('Cargando imagen...'),
                                        ] else ...[
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 32,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Toca para agregar foto',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'JPG, PNG o WEBP (máx. 5MB)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons - Reducir padding
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm, // Reducir padding vertical
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), // Reducir padding del botón
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), // Reducir padding del botón
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditing ? 'Actualizar' : 'Crear'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// Función helper para mostrar el diálogo
Future<Product?> showProductFormDialog(
  BuildContext context, {
  Product? product,
}) {
  return showDialog<Product>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProductFormDialog(product: product),
  );
}