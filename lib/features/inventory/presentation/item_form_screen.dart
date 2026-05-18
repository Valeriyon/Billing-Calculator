import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/image_storage.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../domain/inventory_item_model.dart';
import 'providers/inventory_providers.dart';

class InventoryItemFormScreen extends ConsumerStatefulWidget {
  const InventoryItemFormScreen({super.key, this.itemId});

  final int? itemId;

  bool get isEditing => itemId != null;

  @override
  ConsumerState<InventoryItemFormScreen> createState() =>
      _InventoryItemFormScreenState();
}

class _InventoryItemFormScreenState
    extends ConsumerState<InventoryItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitValueController;
  late final TextEditingController _brandController;
  late final TextEditingController _imagePathController;

  String? _selectedCategory;
  InventoryUom _selectedUom = InventoryUom.pcs;
  bool _isInitializing = false;
  String? _codeLoadError;

  static const List<String> _defaultCategories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
    'Beverages',
    'Snacks',
    'Poultry',
    'Electronics',
    'Home',
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _barcodeController = TextEditingController();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _unitValueController = TextEditingController(text: '1');
    _brandController = TextEditingController();
    _imagePathController = TextEditingController();

    if (widget.isEditing) {
      _loadItem();
    } else {
      _loadNextItemCode();
    }
  }

  Future<void> _loadNextItemCode() async {
    setState(() => _isInitializing = true);
    try {
      final code = await ref
          .read(inventoryRepositoryProvider)
          .getNextItemCode();
      if (!mounted) {
        return;
      }
      setState(() {
        _codeController.text = code;
        _codeLoadError = null;
      });
    } catch (error) {
      debugPrint('Error generating item code: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _codeController.text = '';
        _codeLoadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _loadItem() async {
    setState(() => _isInitializing = true);
    final item = await ref
        .read(inventoryRepositoryProvider)
        .getItemById(widget.itemId!);

    if (!mounted) {
      return;
    }

    if (item != null) {
      _codeController.text = item.code;
      _barcodeController.text = item.barcode ?? '';
      _nameController.text = item.name;
      _priceController.text = item.price.toStringAsFixed(2);
      _unitValueController.text = item.unitValue.toString();
      _brandController.text = item.brand;
      _imagePathController.text = item.imagePath ?? '';
      _selectedCategory = item.category;
      _selectedUom = item.uom;
    }

    setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _unitValueController.dispose();
    _brandController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryManagerProvider);
    final theme = Theme.of(context);
    final allCategoryOptions = <String>{
      ..._defaultCategories,
      ...state.allCategories,
    }.toList()..sort();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: Text(widget.isEditing ? 'Edit Inventory Item' : 'Add New Item'),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FormSection(
                        title: 'Item Image',
                        icon: Icons.image_outlined,
                        child: _ImageUploadSection(
                          imagePath: _imagePathController.text,
                          onPickFromGallery: () =>
                              _pickImage(ImageSource.gallery),
                          onPickFromCamera: () =>
                              _pickImage(ImageSource.camera),
                          onClear: _imagePathController.text.trim().isEmpty
                              ? null
                              : _clearImage,
                        ),
                      ),
                      _FormSection(
                        title: 'Basic Information',
                        icon: Icons.info_outline,
                        child: Column(
                          children: [
                            _LabeledTextField(
                              label: 'Barcode',
                              icon: Icons.qr_code_scanner,
                              controller: _barcodeController,
                              hintText: 'Tap to scan barcode',
                              readOnly: true,
                              onTap: _scanBarcode,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.center_focus_strong),
                                color: AppColors.primary,
                                onPressed: _scanBarcode,
                                tooltip: 'Scan barcode',
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingLarge),
                            _LabeledReadOnlyField(
                              label: 'Item Code',
                              value: _codeController.text,
                              icon: Icons.qr_code_2_outlined,
                            ),
                            if (_codeLoadError != null) ...[
                              const SizedBox(height: AppSizes.spacingSmall),
                              Text(
                                _codeLoadError!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.error),
                              ),
                              const SizedBox(height: AppSizes.spacingSmall),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _loadNextItemCode,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry code generation'),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSizes.spacingLarge),
                            _LabeledTextField(
                              label: 'Item Name',
                              isRequired: true,
                              icon: Icons.label_outline,
                              controller: _nameController,
                              hintText: 'e.g., Fresh Apples',
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Item name is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      _FormSection(
                        title: 'Pricing & Inventory',
                        icon: Icons.local_atm_outlined,
                        child: Column(
                          children: [
                            _LabeledTextField(
                              label: 'Price',
                              isRequired: true,
                              icon: Icons.currency_rupee,
                              controller: _priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              hintText: '0.00',
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Price is required';
                                }
                                final parsed = double.tryParse(value!.trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spacingLarge),
                            Row(
                              children: [
                                Expanded(
                                  child: _LabeledDropdownField<InventoryUom>(
                                    label: 'UOM',
                                    isRequired: true,
                                    icon: Icons.straighten,
                                    value: _selectedUom,
                                    items: InventoryUom.values,
                                    itemTextBuilder: (uom) => uom.label,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _selectedUom = value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSizes.spacingSmall),
                                Expanded(
                                  child: _LabeledTextField(
                                    label: 'Unit Value',
                                    isRequired: true,
                                    icon: Icons.numbers,
                                    controller: _unitValueController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    hintText: 'e.g., 1 or 500',
                                    validator: (value) {
                                      if ((value ?? '').trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final parsed = double.tryParse(
                                        value!.trim(),
                                      );
                                      if (parsed == null || parsed <= 0) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _FormSection(
                        title: 'Additional Details',
                        icon: Icons.description_outlined,
                        child: Column(
                          children: [
                            _LabeledDropdownField<String>(
                              label: 'Category',
                              isRequired: true,
                              icon: Icons.category_outlined,
                              value: _selectedCategory,
                              items: allCategoryOptions,
                              itemTextBuilder: (category) => category,
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                              },
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Category is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.spacingLarge),
                            _LabeledTextField(
                              label: 'Brand',
                              isRequired: true,
                              icon: Icons.business_outlined,
                              controller: _brandController,
                              hintText: 'e.g., Farm Fresh',
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Brand is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXLarge),
                      AppButton(
                        onPressed: state.isSaving ? null : _handleSave,
                        isLoading: state.isSaving,
                        label: widget.isEditing ? 'Update Item' : 'Save Item',
                        icon: Icons.save_outlined,
                        backgroundColor: AppColors.primary,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AppSizes.spacingMedium),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item code is unavailable. Please retry code generation.',
          ),
        ),
      );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final unitValue = double.parse(_unitValueController.text.trim());

    final draft = InventoryItemDraft(
      code: _codeController.text.trim(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      category: (_selectedCategory ?? '').trim(),
      brand: _brandController.text.trim(),
      price: price,
      uom: _selectedUom,
      unitValue: unitValue,
      imagePath: _imagePathController.text.trim(),
    );

    final notifier = ref.read(inventoryManagerProvider.notifier);
    final error = widget.isEditing
        ? await notifier.updateItem(widget.itemId!, draft)
        : await notifier.addItem(draft);

    if (!mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isEditing ? 'Item updated' : 'Item saved')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    final previousPath = _imagePathController.text.trim();

    try {
      final storedPath = await LocalImageStorage.pickAndStoreImage(
        source: source,
      );

      if (!mounted || storedPath == null) {
        return;
      }

      setState(() {
        _imagePathController.text = storedPath;
      });

      if (previousPath.isNotEmpty && previousPath != storedPath) {
        await LocalImageStorage.deleteIfManaged(previousPath);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select image. Please try again.'),
        ),
      );
    }
  }

  Future<void> _clearImage() async {
    final previousPath = _imagePathController.text.trim();
    if (previousPath.isEmpty) {
      return;
    }

    final shouldClear = await showConfirmationDialog(
      context,
      title: 'Remove image',
      message: 'Remove the current image from this item?',
      confirmLabel: 'Remove',
      isDestructive: true,
    );

    if (!shouldClear || !mounted) {
      return;
    }

    setState(() {
      _imagePathController.clear();
    });

    await LocalImageStorage.deleteIfManaged(previousPath);
  }

  Future<void> _scanBarcode() async {
    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );

    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) {
      return;
    }

    setState(() {
      _barcodeController.text = scannedCode.trim();
    });
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingLarge),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppSizes.iconSizeSmall,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.icon,
    this.isRequired = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: colorScheme.onSurfaceVariant),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdownField<T> extends StatelessWidget {
  const _LabeledDropdownField({
    required this.label,
    required this.items,
    required this.itemTextBuilder,
    required this.onChanged,
    this.icon,
    this.value,
    this.isRequired = false,
    this.validator,
  });

  final String label;
  final List<T> items;
  final String Function(T value) itemTextBuilder;
  final void Function(T? value) onChanged;
  final IconData? icon;
  final T? value;
  final bool isRequired;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppSizes.spacingSmall),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemTextBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.isRequired});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        Text(label, style: style),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _LabeledReadOnlyField extends StatelessWidget {
  const _LabeledReadOnlyField({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, isRequired: true),
        const SizedBox(height: AppSizes.spacingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSizes.spacingSmall),
              ],
              Expanded(
                child: Text(
                  value.trim().isEmpty ? 'Generating...' : value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageUploadSection extends StatelessWidget {
  const _ImageUploadSection({
    required this.imagePath,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    this.onClear,
  });

  final String imagePath;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final normalizedPath = imagePath.trim();
    final imageFile = normalizedPath.isEmpty ? null : File(normalizedPath);
    final hasImage = imageFile != null && imageFile.existsSync();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Image.file(
                imageFile,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else ...[
            const Icon(
              Icons.image_outlined,
              size: AppSizes.iconSizeXLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Upload Item Image',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXSmall),
            Text(
              'Optional - Add a photo of your item',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingSmall),
          const SizedBox(height: AppSizes.spacingMedium),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(
                      AppSizes.buttonHeightSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(
                      AppSizes.buttonHeightSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (onClear != null) ...[
            const SizedBox(height: AppSizes.spacingSmall),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Image'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.qrCode,
    ],
  );
  final AudioPlayer _beepPlayer = AudioPlayer();

  bool _hasDetected = false;

  @override
  void initState() {
    super.initState();
    _beepPlayer.setReleaseMode(ReleaseMode.stop);
    _beepPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  void dispose() {
    _beepPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_hasDetected) {
                return;
              }

              final code = capture.barcodes.isEmpty
                  ? null
                  : capture.barcodes.first.rawValue;
              if (code == null || code.trim().isEmpty) {
                return;
              }

              _hasDetected = true;
              _beepPlayer.play(AssetSource('sounds/scan_beep.wav'));
              Navigator.of(context).pop(code);
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Text(
                    'Unable to open camera for scanning. Please check permission and try again.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSizes.paddingLarge,
            child: Text(
              'Align barcode inside the frame',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
