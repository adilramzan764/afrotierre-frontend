import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VendorSalesStatisticsScreen extends StatefulWidget {
  const VendorSalesStatisticsScreen({super.key});

  @override
  State<VendorSalesStatisticsScreen> createState() =>
      _VendorSalesStatisticsScreenState();
}

class _VendorSalesStatisticsScreenState
    extends State<VendorSalesStatisticsScreen> {
  String _selectedMonth = 'Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sales Statistics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildDownloadReportCard(),
            const SizedBox(height: 16),
            _buildTimeframeSelector(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildSalesOverviewChart(),
          ],
        ),
      ),
    );
  }

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
        trailing: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.download, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return ListTile(
      leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
      title: const Text('Last 30 days'),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Sales',
          '\$20,783.63',
          '+0% from last week',
          Colors.green,
        ),
        _buildStatCard(
          'Online Sales',
          '\$20,783.63',
          '+0% from last week',
          Colors.green,
        ),
        _buildStatCard(
          'Gross Profit',
          '\$20,783.63',
          '+0% from last week',
          Colors.green,
        ),
        _buildStatCard(
          'Total Sales',
          '\$20,783.63',
          '+0% from last week',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    String change,
    Color changeColor,
  ) {
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
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_upward, color: changeColor, size: 14),
              Text(change, style: TextStyle(color: changeColor, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverviewChart() {
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
                _buildLegend(Colors.grey[300]!, 'Outcome'),
              ],
            ),
            DropdownButton<String>(
              value: _selectedMonth,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: ['Month', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
                  .map(
                    (label) => DropdownMenuItem(
                      value: label,
                      child: Text(label, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMonth = value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
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
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('Jan', style: style);
                          break;
                        case 1:
                          text = const Text('Feb', style: style);
                          break;
                        case 2:
                          text = const Text('Mar', style: style);
                          break;
                        case 3:
                          text = const Text('Apr', style: style);
                          break;
                        case 4:
                          text = const Text('May', style: style);
                          break;
                        case 5:
                          text = const Text('Jun', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 16.0,
                        child: text,
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
                      if (value % 20 != 0) return Container();
                      return Text(
                        value.toInt().toString(),
                        style: style,
                        textAlign: TextAlign.left,
                      );
                    },
                    reservedSize: 28,
                    interval: 1,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
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
    // Placeholder data
    final incomeData = [40.0, 60.0, 45.0, 80.0, 60.0, 65.0];
    final outcomeData = [20.0, 30.0, 10.0, 40.0, 25.0, 30.0];

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
            toY: outcomeData[index],
            color: Colors.grey[300],
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
