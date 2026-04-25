import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../domain/customer_model.dart';
import 'providers/customer_providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});

  final int? customerId;

  bool get isEditing => customerId != null;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    if (widget.isEditing) {
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    setState(() => _isInitializing = true);

    final customer = await ref
        .read(customerRepositoryProvider)
        .getCustomerById(widget.customerId!);

    if (!mounted) {
      return;
    }

    if (customer != null) {
      _nameController.text = customer.name;
      _phoneController.text = customer.phone ?? '';
      _addressController.text = customer.address ?? '';
    }

    setState(() => _isInitializing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerManagerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.isEditing ? 'Edit Customer' : 'Add Customer'),
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
                      const SizedBox(height: AppSizes.spacingLarge),
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
                          if (raw.isEmpty) {
                            return null;
                          }

                          final onlyDigits = raw.replaceAll(RegExp(r'[^0-9]'), '');
                          if (onlyDigits.length < 7 || onlyDigits.length > 15) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacingLarge),
                      TextFormField(
                        controller: _addressController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXLarge),
                      AppButton(
                        onPressed: state.isSaving ? null : _handleSave,
                        isLoading: state.isSaving,
                        label: widget.isEditing ? 'Update Customer' : 'Save Customer',
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

    final draft = CustomerDraft(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    final notifier = ref.read(customerManagerProvider.notifier);
    final error = widget.isEditing
        ? await notifier.updateCustomer(widget.customerId!, draft)
        : await notifier.addCustomer(draft);

    if (!mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Customer updated successfully'
              : 'Customer added successfully',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}
