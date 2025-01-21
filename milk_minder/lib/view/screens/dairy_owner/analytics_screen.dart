import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controller/analytics_provider.dart';
import 'collection_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = 'Week';
  final List<String> periods = ['Week', 'Month', 'Year'];
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAnalyticsData(selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          DropdownButton<String>(
            value: selectedPeriod,
            items: periods.map((String period) {
              return DropdownMenuItem<String>(
                value: period,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(period),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedPeriod = newValue;
                });
                context.read<AnalyticsProvider>().fetchAnalyticsData(newValue);
              }
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analytics, child) {
          if (analytics.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (analytics.error != null) {
            return Center(child: Text(analytics.error!));
          }

          return RefreshIndicator(
            onRefresh: () => analytics.fetchAnalyticsData(selectedPeriod),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we're on a small screen
                final isSmallScreen = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards with responsive layout
                        Wrap(
                          spacing: isSmallScreen ? 12 : 16,
                          runSpacing: isSmallScreen ? 12 : 16,
                          children: [
                            SizedBox(
                              width: isSmallScreen
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 32) / 2,
                              child: _buildStatCard(
                                'Total Collection',
                                '${analytics.totalCollection.toStringAsFixed(1)} L',
                                Icons.water_drop,
                                Colors.blue,
                                _getGrowthRate(analytics, 'collection'),
                              ),
                            ),
                            SizedBox(
                              width: isSmallScreen
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 32) / 2,
                              child: _buildStatCard(
                                'Total Earnings',
                                currencyFormat.format(analytics.totalEarnings),
                                Icons.currency_rupee,
                                Colors.green,
                                _getGrowthRate(analytics, 'earnings'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Milk Type Distribution Card
                        _buildMilkTypeCard(analytics, constraints),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getGrowthRate(AnalyticsProvider analytics, String type) {
    double growthRate = type == 'collection'
        ? analytics.getCollectionGrowth()
        : analytics.getEarningsGrowth();

    String indicator = growthRate >= 0 ? '↑' : '↓';

    return '${growthRate.abs().toStringAsFixed(1)}% $indicator from last ${selectedPeriod.toLowerCase()}';
  }

  Widget _buildMilkTypeCard(
      AnalyticsProvider analytics, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Milk Type Distribution',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Responsive layout for milk progress bars
            LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 500;

                if (useColumn) {
                  return Column(
                    children: [
                      _buildMilkProgress(
                        'Cow Milk',
                        analytics.getCowMilkPercentage(),
                        analytics.getCowMilkLiters(),
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildMilkProgress(
                        'Buffalo Milk',
                        analytics.getBuffaloMilkPercentage(),
                        analytics.getBuffaloMilkLiters(),
                        Colors.amber,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMilkProgress(
                          'Cow Milk',
                          analytics.getCowMilkPercentage(),
                          analytics.getCowMilkLiters(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildMilkProgress(
                          'Buffalo Milk',
                          analytics.getBuffaloMilkPercentage(),
                          analytics.getBuffaloMilkLiters(),
                          Colors.amber,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkProgress(
    String title,
    double percentage,
    double liters,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallWidth = constraints.maxWidth < 300;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallWidth ? 14 : 16,
                  ),
                ),
                Text(
                  '${liters.toStringAsFixed(1)} L',
                  style: TextStyle(
                    fontSize: isSmallWidth ? 14 : 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: isSmallWidth ? 8 : 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: isSmallWidth ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallWidth = constraints.maxWidth < 300;

          return Padding(
            padding: EdgeInsets.all(isSmallWidth ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: isSmallWidth ? 20 : 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallWidth ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallWidth ? 6 : 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallWidth ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallWidth ? 3 : 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallWidth ? 10 : 12,
                    color: subtitle.contains('-') ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
