import 'package:afrotierre/Models/SellerModels/SellerDashboardModels.dart';
import 'package:afrotierre/Repository/SellerRepository/SellerDashboardRepository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../res/Widgets/ShimmerBox.dart';

class VendorSalesStatisticsScreen extends StatefulWidget {
  const VendorSalesStatisticsScreen({super.key});

  @override
  State<VendorSalesStatisticsScreen> createState() =>
      _VendorSalesStatisticsScreenState();
}

class _VendorSalesStatisticsScreenState
    extends State<VendorSalesStatisticsScreen> {
  final SellerDashboardRepository _repository = SellerDashboardRepository();

  String _selectedTimeframe = 'Last 30 Days';
  String _selectedMonth = 'Month';

  // Loading states
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _error;

  // Data
  SalesStatisticsResponse? _salesData;

  // Chart selected month index
  int _selectedChartMonth = -1;

  // Timeframe mapping to API format
  String get _apiTimeframe {
    switch (_selectedTimeframe) {
      case 'Last 7 Days':
        return '7days';
      case 'Last 30 Days':
        return '30days';
      case 'Last 3 Months':
        return '3months';
      case 'Last 6 Months':
        return '6months';
      case 'This Year':
        return 'year';
      default:
        return '30days';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSalesStatistics();
  }

  Future<void> _loadSalesStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repository.getSalesStatistics(timeframe: _apiTimeframe);
      setState(() {
        _salesData = data;
        _isLoading = false;
        // Reset selected month to show all data
        _selectedChartMonth = -1;
        _selectedMonth = 'Month';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }



  Future<void> _downloadReport() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final file = await _repository.downloadSalesReport(
        format: 'csv',
        timeframe: _apiTimeframe,
      );

      if (file != null && mounted) {
        // Get file info
        final exists = await file.exists();
        final size = await file.length();
        final fileName = file.path.split('/').last;

        print("✅ File saved: ${file.path}");
        print("📁 File size: $size bytes");
        print("📄 File exists: $exists");

        // Show success dialog with file info
        _showDownloadSuccessDialog(file);
      }
    } catch (e) {
      print("❌ Download error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download report: ${e.toString().split('\n')[0]}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showDownloadSuccessDialog(File file) {
    final fileName = file.path.split('/').last;
    final fileSizeKB = (file.lengthSync() / 1024).toStringAsFixed(2);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Icon + Title row ───────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF16A34A),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Download Complete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Your sales report is ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── File details ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FILE DETAILS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _dialogRow(Icons.insert_drive_file_outlined, 'Name', fileName),
                      const SizedBox(height: 8),
                      _dialogRow(Icons.sd_card_outlined, 'Size', '$fileSizeKB KB'),
                      const SizedBox(height: 8),
                      _dialogRow(Icons.folder_outlined, 'Location', 'Downloads folder'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Hint ──────────────────────────────────────────────────
                const Text(
                  'Open your file manager app to view the CSV.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black38,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Done button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  // Get chart data based on selected month filter
  List<MonthlySalesData> get _filteredChartData {
    if (_salesData == null) return [];
    if (_selectedChartMonth == -1) {
      return _salesData!.chartData;
    }
    return _salesData!.chartData
        .where((data) => data.monthIndex == _selectedChartMonth)
        .toList();
  }

  // Get unique months for dropdown
  List<String> get _availableMonths {
    if (_salesData == null) return ['Month'];
    final months = _salesData!.chartData.map((data) => data.month).toList();
    return ['Month', ...months.toSet().toList()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sales Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSalesStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview heading
              const Text(
                'Overview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Download Report Card
              _buildDownloadReportCard(),
              const SizedBox(height: 16),

              // Timeframe filter
              _buildTimeframeSelector(),
              const SizedBox(height: 24),

              // Stats Grid
              _buildStatsGrid(),
              const SizedBox(height: 16),

              // Net Earnings Card
              _buildNetEarningsCard(),
              const SizedBox(height: 32),

              // Sales Overview Chart
              _buildSalesOverviewChart(),
              const SizedBox(height: 32),

              // Top Selling Product
              _buildTopSellingProduct(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DOWNLOAD REPORT CARD
  // ─────────────────────────────────────────────
  Widget _buildDownloadReportCard() {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        title: const Text(
          'Download Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'You can now download your daily report',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: _isDownloading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.download, color: Colors.white),
        ),
        onTap: _isDownloading ? null : _downloadReport,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIMEFRAME SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildTimeframeSelector() {
    if (_isLoading) {
      return ShimmerBox(
        width: double.infinity,
        height: 50,
        borderRadius: BorderRadius.circular(12),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _selectedTimeframe,
            isExpanded: true,
            icon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
            items: [
              'Last 7 Days',
              'Last 30 Days',
              'Last 3 Months',
              'Last 6 Months',
              'This Year',
            ].map((label) => DropdownMenuItem(
              value: label,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )).toList(),
            onChanged: (value) {
              if (value != null && value != _selectedTimeframe) {
                setState(() => _selectedTimeframe = value);
                _loadSalesStatistics();
              }
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS GRID (4 key metrics)
  // ─────────────────────────────────────────────
  Widget _buildStatsGrid() {
    if (_isLoading) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: List.generate(4, (index) => ShimmerBox(
          width: double.infinity,
          height: 100,
          borderRadius: BorderRadius.circular(16),
        )),
      );
    }

    if (_error != null || _salesData == null) {
      return _buildErrorWidget();
    }

    final stats = _salesData!.stats;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildStatCard(
          icon: Icons.attach_money_rounded,
          iconBg: Colors.green.withOpacity(0.12),
          iconColor: Colors.green,
          title: 'Total Revenue',
          amount: stats.totalRevenue.formatted,
          change: stats.totalRevenue.changeText,
          changeColor: stats.totalRevenue.changeColor,
          isPositive: stats.totalRevenue.isPositive,
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline_rounded,
          iconBg: Colors.blue.withOpacity(0.12),
          iconColor: Colors.blue,
          title: 'Orders Completed',
          amount: stats.ordersCompleted.formatted,
          change: stats.ordersCompleted.changeText,
          changeColor: stats.ordersCompleted.changeColor,
          isPositive: stats.ordersCompleted.isPositive,
        ),
        _buildStatCard(
          icon: Icons.receipt_long_outlined,
          iconBg: Colors.purple.withOpacity(0.12),
          iconColor: Colors.purple,
          title: 'Avg Order Value',
          amount: stats.avgOrderValue.formatted,
          change: stats.avgOrderValue.changeText,
          changeColor: stats.avgOrderValue.changeColor,
          isPositive: stats.avgOrderValue.isPositive,
        ),
        _buildStatCard(
          icon: Icons.replay_outlined,
          iconBg: Colors.red.withOpacity(0.12),
          iconColor: Colors.red,
          title: 'Refunds',
          amount: stats.refunds.formatted,
          change: stats.refunds.changeText,
          changeColor: stats.refunds.changeColor,
          isPositive: stats.refunds.isPositive,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String amount,
    required String change,
    required Color changeColor,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 12,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  change,
                  style: TextStyle(color: changeColor, fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NET EARNINGS CARD
  // ─────────────────────────────────────────────
  Widget _buildNetEarningsCard() {
    if (_isLoading) {
      return ShimmerBox(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(16),
      );
    }

    if (_error != null || _salesData == null) {
      return const SizedBox.shrink();
    }

    final netEarnings = _salesData!.netEarnings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Net Earnings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                netEarnings.formatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'After refunds & fees',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SALES OVERVIEW CHART (Income vs Refunds)
  // ─────────────────────────────────────────────
  Widget _buildSalesOverviewChart() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 150, height: 20),
          const SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 200, borderRadius: BorderRadius.circular(16)),
        ],
      );
    }

    if (_error != null || _salesData == null || _salesData!.chartData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No chart data available for this period',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final chartData = _filteredChartData;
    final hasData = chartData.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildLegend(Colors.green, 'Income'),
                const SizedBox(width: 16),
                _buildLegend(Colors.red[200]!, 'Refunds'),
              ],
            ),
            if (hasData && _salesData!.chartData.length > 1)
              DropdownButton<String>(
                value: _selectedMonth,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: _availableMonths.map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label, style: const TextStyle(fontSize: 12)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                      if (value == 'Month') {
                        _selectedChartMonth = -1;
                      } else {
                        final selectedData = _salesData!.chartData.firstWhere(
                              (data) => data.month == value,
                          orElse: () => _salesData!.chartData.first,
                        );
                        _selectedChartMonth = selectedData.monthIndex;
                      }
                    });
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // t: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome = rodIndex == 0;
                      return BarTooltipItem(
                        '${isIncome ? 'Income' : 'Refunds'}\n\$${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        final idx = value.toInt();
                        String label = '';
                        if (hasData && idx < chartData.length) {
                          label = chartData[idx].month;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 16.0,
                          child: Text(label, style: style),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        return Text(
                          '\$${value.toInt()}',
                          style: style,
                          textAlign: TextAlign.left,
                        );
                      },
                      reservedSize: 40,
                      interval: 20,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[100]!,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroupsFromData(chartData),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroupsFromData(List<MonthlySalesData> data) {
    if (data.isEmpty) return [];

    // Find max value for scaling
    double maxIncome = 0;
    double maxRefunds = 0;
    for (final item in data) {
      if (item.income > maxIncome) maxIncome = item.income;
      if (item.refunds > maxRefunds) maxRefunds = item.refunds;
    }
    final maxValue = maxIncome > maxRefunds ? maxIncome : maxRefunds;
    // Scale to fit chart (add 10% padding)
    final scaleFactor = maxValue > 0 ? 100 / maxValue : 1;

    return List.generate(data.length, (index) {
      final item = data[index];
      final scaledIncome = item.income * scaleFactor;
      final scaledRefunds = item.refunds * scaleFactor;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: scaledIncome,
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: scaledRefunds,
            color: Colors.red[200],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    // Fallback mock data
    final incomeData = [40.0, 60.0, 45.0, 80.0, 60.0, 65.0];
    final refundData = [5.0, 8.0, 3.0, 10.0, 6.0, 7.0];

    return List.generate(incomeData.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: incomeData[index],
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: refundData[index],
            color: Colors.red[200],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────
  // TOP SELLING PRODUCT
  // ─────────────────────────────────────────────
  Widget _buildTopSellingProduct() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 150, height: 20),
          const SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 90, borderRadius: BorderRadius.circular(16)),
        ],
      );
    }

    if (_error != null || _salesData == null || _salesData!.topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final topProduct = _salesData!.topProducts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Selling Product',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topProduct.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sold: ${topProduct.quantity} units',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    topProduct.revenueFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Revenue',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Show more products if available
        if (_salesData!.topProducts.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_salesData!.topProducts.length - 1} more products',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ERROR WIDGET
  // ─────────────────────────────────────────────
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 12),
          Text(
            'Failed to load sales data',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSalesStatistics,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}