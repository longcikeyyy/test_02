import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/network/api_client.dart';
import 'features/auth/presentation/pages/account_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/categories/data/datasources/category_remote_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/presentation/providers/category_provider.dart';
import 'features/orders/data/datasources/order_remote_datasource.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/presentation/pages/order_page.dart';
import 'features/orders/presentation/providers/order_provider.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/pages/product_management_page.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/report/data/datasources/report_remote_datasource.dart';
import 'features/report/data/repositories/report_repository_impl.dart';
import 'features/report/presentation/pages/report_page.dart';
import 'features/report/presentation/providers/report_provider.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0F766E),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFEA580C),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFB91C1C),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF102A43),
      primaryContainer: Color(0xFFCCFBF1),
      onPrimaryContainer: Color(0xFF134E4A),
      secondaryContainer: Color(0xFFFFEDD5),
      onSecondaryContainer: Color(0xFF7C2D12),
      tertiary: Color(0xFF2563EB),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDBEAFE),
      onTertiaryContainer: Color(0xFF1E3A8A),
      outline: Color(0xFFD0D8E2),
      outlineVariant: Color(0xFFE6EDF5),
      shadow: Color(0x40000000),
      scrim: Color(0x52000000),
      inverseSurface: Color(0xFF1F2937),
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: Color(0xFF5EEAD4),
      surfaceTint: Color(0xFF0F766E),
    );

    final textTheme = GoogleFonts.montserratTextTheme().copyWith(
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
    );

    return MaterialApp(
      title: 'POS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: const Color(0xFFF5F8FC),
          foregroundColor: colorScheme.onSurface,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FBFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: textTheme.titleMedium,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => textTheme.bodySmall?.copyWith(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return const LoginPage();
        }

        return AuthenticatedScope(
          token: authState.token!,
          child: const HomeShell(),
        );
      },
    );
  }
}

class AuthenticatedScope extends StatelessWidget {
  const AuthenticatedScope({
    super.key,
    required this.token,
    required this.child,
  });

  final String token;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(token: token);

    final productRepository = ProductRepositoryImpl(
      ProductRemoteDataSource(apiClient),
    );
    final categoryRepository = CategoryRepositoryImpl(
      CategoryRemoteDataSource(apiClient),
    );
    final orderRepository = OrderRepositoryImpl(OrderRemoteDataSource(apiClient));
    final reportRepository = ReportRepositoryImpl(
      ReportRemoteDataSource(apiClient),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>(
          create: (_) => ProductCubit(productRepository),
        ),
        BlocProvider<CategoryCubit>(
          create: (_) => CategoryCubit(categoryRepository),
        ),
        BlocProvider<OrderCubit>(
          create: (_) => OrderCubit(orderRepository),
        ),
        BlocProvider<ReportCubit>(
          create: (_) => ReportCubit(reportRepository),
        ),
      ],
      child: child,
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = [
    ProductManagementPage(),
    OrderPage(),
    ReportPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
