import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../widgets/todachic_logo.dart';
import '../../ui/widgets/gradient_app_bar.dart';

enum ChartMode { category, topProducts }

final chartModeProvider = StateProvider<ChartMode>((ref) => ChartMode.category);

final balanceStatsProvider = Provider<BalanceStats>((ref) {
  ref.watch(saleRepositoryProvider);
  ref.watch(productRepositoryProvider);
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);
  
  final saleRepository = ref.read(saleRepositoryProvider.notifier);
  final productRepository = ref.read(productRepositoryProvider.notifier);
  
  final allSales = saleRepository.getAllSales();
  final todaySales = allSales.where((s) => s.saleDate.isAfter(today)).toList();
  final weekSales = allSales.where((s) => s.saleDate.isAfter(weekStart)).toList();
  final monthSales = allSales.where((s) => s.saleDate.isAfter(monthStart)).toList();
  
  // Revenue by product
  final Map<String, double> productRevenue = {};
  for (final sale in allSales) {
    productRevenue[sale.productId] = (productRevenue[sale.productId] ?? 0) + sale.totalAmount;
  }
  
  final allProducts = productRepository.getAllProducts();
  final productRevenueWithNames = <ProductRevenue>[];
  
  for (final entry in productRevenue.entries) {
    final product = allProducts.where((p) => p.id == entry.key).firstOrNull;
    if (product != null) {
      productRevenueWithNames.add(ProductRevenue(
        productName: product.name,
        revenue: entry.value,
        category: product.category,
      ));
    }
  }
  
  productRevenueWithNames.sort((a, b) => b.revenue.compareTo(a.revenue));
  
  // Revenue by category
  final Map<String, double> categoryRevenue = {};
  for (final pr in productRevenueWithNames) {
    categoryRevenue[pr.category] = (categoryRevenue[pr.category] ?? 0) + pr.revenue;
  }
  
  return BalanceStats(
    todayRevenue: todaySales.fold(0.0, (sum, sale) => sum + sale.totalAmount),
    weekRevenue: weekSales.fold(0.0, (sum, sale) => sum + sale.totalAmount),
    monthRevenue: monthSales.fold(0.0, (sum, sale) => sum + sale.totalAmount),
    todaySales: todaySales.length,
    weekSales: weekSales.length,
    monthSales: monthSales.length,
    topProducts: productRevenueWithNames.take(5).toList(),
    bottomProducts: productRevenueWithNames.length > 5 
        ? productRevenueWithNames.skip(productRevenueWithNames.length - 3).toList() 
        : [],
    categoryRevenue: categoryRevenue,
  );
});

class BalanceStats {
  final double todayRevenue;
  final double weekRevenue;
  final double monthRevenue;
  final int todaySales;
  final int weekSales;
  final int monthSales;
  final List<ProductRevenue> topProducts;
  final List<ProductRevenue> bottomProducts;
  final Map<String, double> categoryRevenue;

  BalanceStats({
    required this.todayRevenue,
    required this.weekRevenue,
    required this.monthRevenue,
    required this.todaySales,
    required this.weekSales,
    required this.monthSales,
    required this.topProducts,
    required this.bottomProducts,
    required this.categoryRevenue,
  });
}

class ProductRevenue {
  final String productName;
  final double revenue;
  final String category;

  ProductRevenue({
    required this.productName,
    required this.revenue,
    required this.category,
  });
}

class BalanceScreen extends ConsumerWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(balanceStatsProvider);
    final chartMode = ref.watch(chartModeProvider);
    
    return Scaffold(
      appBar: GradientAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TODAChicLogo(
              fontSize: 20, 
              showButterflies: true, // Activar mariposas como en el branding
              color: Colors.white, // Color blanco para contraste
            ),
            const SizedBox(width: 8),
            const Text(
              '- Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Colors.white, // Asegurar color blanco
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRevenueCards(context, stats),
          const SizedBox(height: 24),
          _buildSalesCards(context, stats),
          const SizedBox(height: 24),
          _buildChartCard(context, ref, stats, chartMode),
          const SizedBox(height: 24),
          _buildTopProductsCard(context, stats),
          const SizedBox(height: 24),
          if (stats.bottomProducts.isNotEmpty)
            _buildBottomProductsCard(context, stats),
        ],
      ),
    );
  }

  Widget _buildRevenueCards(BuildContext context, BalanceStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Hoy',
            '\$${stats.todayRevenue.toStringAsFixed(2)}',
            Icons.today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Semana',
            '\$${stats.weekRevenue.toStringAsFixed(2)}',
            Icons.date_range,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Mes',
            '\$${stats.monthRevenue.toStringAsFixed(2)}',
            Icons.calendar_month,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesCards(BuildContext context, BalanceStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Hoy',
            '${stats.todaySales}',
            Icons.shopping_cart,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Semana',
            '${stats.weekSales}',
            Icons.shopping_bag,
            Colors.teal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Mes',
            '${stats.monthSales}',
            Icons.store,
            Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, WidgetRef ref, BalanceStats stats, ChartMode mode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle buttons moved above title
            Center(
              child: SegmentedButton<ChartMode>(
                segments: const [
                  ButtonSegment(
                    value: ChartMode.category,
                    label: Text('Categorías'),
                  ),
                  ButtonSegment(
                    value: ChartMode.topProducts,
                    label: Text('Productos'),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selected) {
                  ref.read(chartModeProvider.notifier).state = selected.first;
                },
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title below toggle
            Center(
              child: Text(
                'Ingresos por ${mode == ChartMode.category ? 'Categoría' : 'Top Productos'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildPieChart(stats, mode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BalanceStats stats, ChartMode mode) {
    final data = mode == ChartMode.category
        ? stats.categoryRevenue
        : Map.fromEntries(
            stats.topProducts.take(5).map(
              (p) => MapEntry(p.productName, p.revenue),
            ),
          );

    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final sections = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final percentage = (mapEntry.value / data.values.fold(0.0, (a, b) => a + b)) * 100;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: mapEntry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final mapEntry = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mapEntry.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard(BuildContext context, BalanceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Productos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (stats.topProducts.isEmpty)
              const Text('No hay datos disponibles')
            else
              ...stats.topProducts.map((product) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.trending_up, color: Colors.white),
                ),
                title: Text(product.productName),
                subtitle: Text(product.category),
                trailing: Text(
                  '\$${product.revenue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomProductsCard(BuildContext context, BalanceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos con Menor Venta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.bottomProducts.map((product) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.trending_down, color: Colors.white),
              ),
              title: Text(product.productName),
              subtitle: Text(product.category),
              trailing: Text(
                '\$${product.revenue.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ],
        ),
      ),
    );
  }
}