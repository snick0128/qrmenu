import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrmenu/core/models/date_filter_type.dart';
import '../../core/models/sales_analytics.dart';
import '../../core/models/table_model.dart';
import '../../core/services/admin_service.dart';
import '../../shared/widgets/responsive_layout.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DateFilterType _dateFilter = DateFilterType.today;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          DropdownButton<DateFilterType>(
            value: _dateFilter,
            onChanged: (value) {
              if (value != null) {
                setState(() => _dateFilter = value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: DateFilterType.today,
                child: Text('Today'),
              ),
              DropdownMenuItem(
                value: DateFilterType.week,
                child: Text('This Week'),
              ),
              DropdownMenuItem(
                value: DateFilterType.month,
                child: Text('This Month'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnalytics(),
            const SizedBox(height: 16),
            _buildTableStatus(),
            const SizedBox(height: 16),
            _buildActiveOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnalytics(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTableStatus()),
                const SizedBox(width: 16),
                Expanded(child: _buildActiveOrders()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildAnalytics(),
                const SizedBox(height: 16),
                Expanded(child: _buildTableStatus()),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildActiveOrders()),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return StreamBuilder<SalesAnalytics>(
      stream: AdminService.getSalesAnalyticsStream(_dateFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data ?? const SalesAnalytics();
        final currencyFormat = NumberFormat.currency(symbol: '₹');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Analytics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAnalyticsGrid([
                  AnalyticItem(
                    title: 'Total Orders',
                    value: analytics.totalOrders.toString(),
                    icon: Icons.receipt_long,
                  ),
                  AnalyticItem(
                    title: 'Total Sales',
                    value: currencyFormat.format(analytics.totalSales),
                    icon: Icons.attach_money,
                  ),
                  AnalyticItem(
                    title: 'Average Order',
                    value: currencyFormat.format(analytics.averageOrderValue),
                    icon: Icons.show_chart,
                  ),
                  AnalyticItem(
                    title: 'Ongoing Orders',
                    value: analytics.ongoingOrders.toString(),
                    icon: Icons.pending_actions,
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsGrid(List<AnalyticItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        final crossAxisCount = isSmall ? 2 : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isSmall ? 1.5 : 1.8,
          children: items.map((item) => _buildAnalyticCard(item)).toList(),
        );
      },
    );
  }

  Widget _buildAnalyticCard(AnalyticItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              item.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableStatus() {
    return StreamBuilder<List<TableModel>>(
      stream: AdminService.getTablesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tables = snapshot.data ?? [];
        final currencyFormat = NumberFormat.currency(symbol: '₹');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Table Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTableGrid(tables, currencyFormat),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableGrid(List<TableModel> tables, NumberFormat currencyFormat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        final crossAxisCount = isSmall ? 2 : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: tables
              .map((table) => _buildTableCard(table, currencyFormat))
              .toList(),
        );
      },
    );
  }

  Widget _buildTableCard(TableModel table, NumberFormat currencyFormat) {
    final theme = Theme.of(context);

    Color statusColor;
    switch (table.status) {
      case TableStatus.vacant:
        statusColor = Colors.green;
        break;
      case TableStatus.occupied:
        statusColor = Colors.red;
        break;
      case TableStatus.reserved:
        statusColor = Colors.orange;
        break;
      case TableStatus.cleaning:
        statusColor = Colors.blue;
        break;
    }

    return Card(
      child: InkWell(
        onTap: () => _showTableDetails(table),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Table ${table.number}', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  table.status.toString().split('.').last,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (table.status == TableStatus.occupied) ...[
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(table.currentTotal),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminService.getOrdersStream(statusFilter: 'pending'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return const Center(child: Text('No active orders'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderItem(order);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final timestamp = (order['createdAt'] as Timestamp).toDate();
    final timeString = DateFormat.jm().format(timestamp);

    return ListTile(
      onTap: () => _showOrderDetails(order),
      leading: Icon(
        order['type'] == 'dine_in' ? Icons.restaurant : Icons.takeout_dining,
      ),
      title: Text(
        order['type'] == 'dine_in'
            ? 'Table ${order['tableNumber']}'
            : 'Parcel Order',
      ),
      subtitle: Text(
        'Ordered at $timeString • ${order['items']?.length ?? 0} items',
      ),
      trailing: Text(
        currencyFormat.format(order['totalAmount'] ?? 0),
        style: theme.textTheme.titleMedium,
      ),
    );
  }

  void _showTableDetails(TableModel table) {
    // TODO: Show table details dialog
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    // TODO: Show order details dialog
  }
}

class AnalyticItem {
  final String title;
  final String value;
  final IconData icon;

  AnalyticItem({required this.title, required this.value, required this.icon});
}
