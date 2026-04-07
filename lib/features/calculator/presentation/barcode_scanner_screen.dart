import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/currency_format.dart';
import '../domain/calc_logic.dart';
import '../domain/bill_item.dart';

/// Barcode scanner screen with bill items at bottom
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late final MobileScannerController _scannerController;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  bool get _supportsCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();
    final lastTime = _lastScanTime;

    // Debounce: ignore scans within 500ms of the last scan
    if (lastTime != null && now.difference(lastTime).inMilliseconds < 500) {
      return;
    }

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      return;
    }

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    // Log the scan
    debugPrint('Barcode scanned: $code');

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: $code'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Barcode Scanner'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top: Camera scanner (50% of screen)
          Expanded(
            flex: 1,
            child: _supportsCamera
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppSizes.paddingLarge,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  const SizedBox(
                                    height: AppSizes.spacingMedium,
                                  ),
                                  Text(
                                    'Camera error',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.spacingSmall),
                                  Text(
                                    'Check camera permission and try again.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        placeholderBuilder: (context, child) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.spacingMedium),
                                Text(
                                  'Initializing camera...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.22),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.22),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 260,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLarge,
                              ),
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 56,
                          ),
                          const SizedBox(height: AppSizes.spacingMedium),
                          Text(
                            'Barcode scanning is available on Android and iOS.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingSmall),
                          Text(
                            'Use a mobile device to scan items.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom: Bill items (50% of screen)
          Expanded(
            flex: 1,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bill Items (${calcState.itemCount})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(calcState.subtotal),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: calcState.billItems.isEmpty
                        ? Center(
                            child: Text(
                              'No items added yet',
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                            ),
                            itemCount: calcState.billItems.length,
                            itemBuilder: (context, index) {
                              final item = calcState.billItems[index];
                              return _ScannerBillItemTile(
                                item: item,
                                index: index,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pop(),
        tooltip: 'Close scanner',
        child: const Icon(Icons.close),
      ),
    );
  }
}

class _ScannerBillItemTile extends StatelessWidget {
  const _ScannerBillItemTile({required this.item, required this.index});

  final BillItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${CurrencyFormatter.formatQuantity(item.quantity)} × ${CurrencyFormatter.formatWithoutSymbol(item.rate)}',
          style: theme.textTheme.labelSmall,
        ),
        trailing: Text(
          CurrencyFormatter.format(item.total),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
