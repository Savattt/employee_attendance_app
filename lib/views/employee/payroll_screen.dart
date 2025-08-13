import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payroll_controller.dart';
import '../../models/payroll_model.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatelessWidget {
  PayrollScreen({super.key});

  final PayrollController payrollController = Get.put(PayrollController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(
          () => payrollController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : payrollController.payrollList.isEmpty
                  ? const Center(child: Text('No payroll records found.'))
                  : ListView.separated(
                      itemCount: payrollController.payrollList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final payroll = payrollController.payrollList[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.receipt_long,
                              color: theme.primaryColor,
                            ),
                            title: Text(
                              DateFormat(
                                'MMMM yyyy',
                              ).format(DateTime(payroll.year, payroll.month)),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Net Pay: ${payroll.netPay.toStringAsFixed(2)}',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: payroll.status == 'Paid'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                payroll.status,
                                style: TextStyle(
                                  color: payroll.status == 'Paid'
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) =>
                                    _PayrollDetailSheet(payroll: payroll),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

class _PayrollDetailSheet extends StatelessWidget {
  final PayrollModel payroll;
  const _PayrollDetailSheet({required this.payroll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '${DateFormat('MMMM yyyy').format(DateTime(payroll.year, payroll.month))} Payslip',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _payDetailRow('Basic Salary', payroll.basic),
          _payDetailRow('Allowances', payroll.allowances),
          _payDetailRow('Deductions', payroll.deductions),
          const Divider(height: 24),
          _payDetailRow('Net Pay', payroll.netPay, isBold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Status: ', style: theme.textTheme.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: payroll.status == 'Paid'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  payroll.status,
                  style: TextStyle(
                    color: payroll.status == 'Paid'
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Generated: ${DateFormat('yyyy-MM-dd').format(payroll.createdAt)}',
          ),
        ],
      ),
    );
  }

  Widget _payDetailRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value.toStringAsFixed(2),
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
