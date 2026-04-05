import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/invoices/presentation/invoice_list_screen.dart';
import '../../features/invoices/presentation/invoice_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/inventory/presentation/manage_items_screen.dart';
import '../../features/inventory/presentation/item_form_screen.dart';

/// App router configuration using go_router
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    // Calculator (Main) Screen
    GoRoute(path: '/', builder: (context, state) => const CalculatorScreen()),

    // Checkout Screen
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // Invoice List Screen
    GoRoute(
      path: '/invoices',
      builder: (context, state) => const InvoiceListScreen(),
    ),

    // Invoice Detail Screen
    GoRoute(
      path: '/invoices/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return InvoiceDetailScreen(invoiceId: id);
      },
    ),

    // Settings Screen
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Inventory Management Screen
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const ManageItemsScreen(),
    ),

    // Add Inventory Item Screen
    GoRoute(
      path: '/inventory/new',
      builder: (context, state) => const InventoryItemFormScreen(),
    ),

    // Edit Inventory Item Screen
    GoRoute(
      path: '/inventory/edit/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr);
        if (id == null) {
          return const ManageItemsScreen();
        }
        return InventoryItemFormScreen(itemId: id);
      },
    ),
  ],
);
