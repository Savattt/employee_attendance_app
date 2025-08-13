import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payroll_controller.dart';
import '../../models/payroll_model.dart';
import '../../services/payroll_service.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPayrollScreen extends StatelessWidget {
  AdminPayrollScreen({super.key});

  final PayrollController payrollController = Get.put(PayrollController());

  @override
  Widget build(BuildContext context) {
    payrollController.fetchAllPayrolls();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditPayrollDialog(context),
        child: const Icon(Icons.add),
      ),
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
                            onTap: () => _showAddOrEditPayrollDialog(
                              context,
                              payroll: payroll,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  void _showAddOrEditPayrollDialog(
    BuildContext context, {
    PayrollModel? payroll,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: _PayrollForm(payroll: payroll),
      ),
    );
  }
}

class _PayrollForm extends StatefulWidget {
  final PayrollModel? payroll;
  const _PayrollForm({this.payroll});

  @override
  State<_PayrollForm> createState() => _PayrollFormState();
}

class _PayrollFormState extends State<_PayrollForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId;
  List<UserModel> _users = [];
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _basicController = TextEditingController();
  final _allowancesController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _netPayController = TextEditingController();
  String _status = 'Paid';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    if (widget.payroll != null) {
      _selectedUserId = widget.payroll!.userId;
      _monthController.text = widget.payroll!.month.toString();
      _yearController.text = widget.payroll!.year.toString();
      _basicController.text = widget.payroll!.basic.toString();
      _allowancesController.text = widget.payroll!.allowances.toString();
      _deductionsController.text = widget.payroll!.deductions.toString();
      _netPayController.text = widget.payroll!.netPay.toString();
      _status = widget.payroll!.status;
    }
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.payroll == null ? 'Add Payroll' : 'Edit Payroll',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _users.any((u) => u.uid == _selectedUserId)
                  ? _selectedUserId
                  : null,
              decoration: const InputDecoration(labelText: 'Employee'),
              items: _users
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.uid,
                      child: Text(
                        user.displayName != null && user.displayName!.isNotEmpty
                            ? '${user.displayName} (${user.email})'
                            : user.email,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedUserId = val),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Select employee' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    decoration: const InputDecoration(labelText: 'Month'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Month' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: 'Year'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Year' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _basicController,
              decoration: const InputDecoration(labelText: 'Basic Salary'),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Basic' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _allowancesController,
              decoration: const InputDecoration(labelText: 'Allowances'),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Allowances' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _deductionsController,
              decoration: const InputDecoration(labelText: 'Deductions'),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Deductions' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _netPayController,
              decoration: const InputDecoration(labelText: 'Net Pay'),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Net Pay' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              ],
              onChanged: (val) => setState(() => _status = val ?? 'Paid'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _savePayroll,
                      child: Text(
                        widget.payroll == null
                            ? 'Add Payroll'
                            : 'Update Payroll',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePayroll() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final payroll = PayrollModel(
      id: widget.payroll?.id ?? '',
      userId: _selectedUserId!,
      month: int.parse(_monthController.text.trim()),
      year: int.parse(_yearController.text.trim()),
      basic: double.parse(_basicController.text.trim()),
      allowances: double.parse(_allowancesController.text.trim()),
      deductions: double.parse(_deductionsController.text.trim()),
      netPay: double.parse(_netPayController.text.trim()),
      status: _status,
      createdAt: widget.payroll?.createdAt ?? DateTime.now(),
    );
    final service = PayrollService();
    if (widget.payroll == null) {
      await service.addPayroll(payroll);
    } else {
      await service.updatePayroll(widget.payroll!.id, payroll.toMap());
    }
    Get.back();
    Get.find<PayrollController>().fetchPayrolls();
    setState(() => _isLoading = false);
  }
}
