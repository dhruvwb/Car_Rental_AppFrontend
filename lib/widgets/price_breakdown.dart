import 'package:flutter/material.dart';
import '../utils/pricing_constants.dart';

class PriceBreakdownWidget extends StatelessWidget {
  final double dailyRate;
  final int numberOfDays;
  final double insuranceCost;
  final double addOnsCost;
  final double taxPercentage;

  const PriceBreakdownWidget({
    Key? key,
    required this.dailyRate,
    required this.numberOfDays,
    required this.insuranceCost,
    required this.addOnsCost,
    this.taxPercentage = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = dailyRate * numberOfDays;
    final tax = subtotal * (taxPercentage / 100);
    final total = subtotal + insuranceCost + addOnsCost + tax;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          _buildPriceRow(
            'Daily Rate',
            '${PricingConstants.currencySymbol}${dailyRate.toStringAsFixed(2)} × $numberOfDays days',
            '${PricingConstants.currencySymbol}${subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12),
          _buildPriceRow(
            'Insurance',
            '',
            '${PricingConstants.currencySymbol}${insuranceCost.toStringAsFixed(2)}',
          ),
          if (addOnsCost > 0) ...[
            SizedBox(height: 12),
            _buildPriceRow(
              'Add-ons',
              '',
              '${PricingConstants.currencySymbol}${addOnsCost.toStringAsFixed(2)}',
            ),
          ],
          SizedBox(height: 12),
          _buildPriceRow(
            'Tax (${taxPercentage.toStringAsFixed(0)}%)',
            '',
            '${PricingConstants.currencySymbol}${tax.toStringAsFixed(2)}',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 0),
          ),
          _buildPriceRow(
            'Total',
            '',
            '${PricingConstants.currencySymbol}${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String description,
    String price, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? Color(0xFF111827) : Color(0xFF4B5563),
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ),
          ],
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? Color(0xFF0F67B1) : Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
