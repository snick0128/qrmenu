import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double serviceCharge;
  final double total;

  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.serviceCharge,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          // Subtotal
          _buildPriceRow(context, 'Item Total', subtotal, isSubtotal: true),

          const SizedBox(height: 8),

          // Tax
          _buildPriceRow(context, 'GST (18%)', tax, isSecondary: true),

          const SizedBox(height: 8),

          // Service charge
          _buildPriceRow(
            context,
            'Service Charge (10%)',
            serviceCharge,
            isSecondary: true,
          ),

          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: AppColors.textTertiary.withOpacity(0.3)),

          const SizedBox(height: 12),

          // Total
          _buildPriceRow(context, 'Grand Total', total, isTotal: true),

          const SizedBox(height: 8),

          // Savings message (if applicable)
          if (subtotal > 200) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re saving 5% on orders above ₹200!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isSubtotal = false,
    bool isSecondary = false,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : isSecondary
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )
              : isSecondary
              ? Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)
              : Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
