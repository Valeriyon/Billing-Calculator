import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../customers/domain/customer_model.dart';
import '../../../customers/presentation/providers/customer_providers.dart';

class AddCustomerModal extends ConsumerStatefulWidget {
  const AddCustomerModal({super.key});

  @override
  ConsumerState<AddCustomerModal> createState() => _AddCustomerModalState();
}

class _AddCustomerModalState extends ConsumerState<AddCustomerModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isSaving = true);

      final customerId = await ref
          .read(customerRepositoryProvider)
          .insertCustomer(
            CustomerDraft(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(customerId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding customer: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Customer'),
      contentPadding: const EdgeInsets.all(AppSizes.paddingLarge),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              TextFormField(
                controller: _phoneController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final raw = (value ?? '').trim();
                  if (raw.isEmpty) return null;
                  final onlyDigits = raw.replaceAll(RegExp(r'[^0-9]'), '');
                  if (onlyDigits.length < 7 || onlyDigits.length > 15) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.streetAddress,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _handleSave,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
