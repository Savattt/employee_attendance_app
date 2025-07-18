import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/leave_controller.dart';
import '../../models/leave_model.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatelessWidget {
  LeaveScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _reasonController = TextEditingController();
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _endDate = Rx<DateTime?>(null);

  @override
  Widget build(BuildContext context) {
    final leaveController = Get.put(LeaveController());
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Leave'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Balance Card (mocked for now)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.beach_access,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Leave Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sick: 5 | Vacation: 8 | Personal: 2',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leave Request Form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Leave',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: null,
                        decoration: InputDecoration(
                          labelText: 'Leave Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Sick Leave',
                            child: Text('Sick Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'Vacation',
                            child: Text('Vacation'),
                          ),
                          DropdownMenuItem(
                            value: 'Personal',
                            child: Text('Personal'),
                          ),
                        ],
                        onChanged: (val) => _typeController.text = val ?? '',
                        validator: (val) => val == null || val.isEmpty
                            ? 'Select leave type'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) _startDate.value = picked;
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _startDate.value == null
                                        ? 'Select'
                                        : DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(_startDate.value!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _startDate.value ?? DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) _endDate.value = picked;
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _endDate.value == null
                                        ? 'Select'
                                        : DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(_endDate.value!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter reason' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: theme.primaryColor,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _typeController.text.isNotEmpty &&
                                _startDate.value != null &&
                                _endDate.value != null) {
                              final leave = LeaveModel(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                type: _typeController.text,
                                startDate: _startDate.value!,
                                endDate: _endDate.value!,
                                reason: _reasonController.text,
                                status: 'Pending',
                                createdAt: DateTime.now(),
                              );
                              leaveController.requestLeave(leave);
                              Get.snackbar(
                                'Success',
                                'Leave request submitted!',
                                backgroundColor: Colors.green.shade50,
                                colorText: Colors.green.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              _typeController.clear();
                              _reasonController.clear();
                              _startDate.value = null;
                              _endDate.value = null;
                            }
                          },
                          child: const Text(
                            'Submit Request',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leave History
            Text(
              'Leave History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => leaveController.leaveList.isEmpty
                  ? const Center(child: Text('No leave history.'))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaveController.leaveList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final leave = leaveController.leaveList[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.event_note,
                              color: theme.primaryColor,
                            ),
                            title: Text(
                              '${leave.type} (${DateFormat('yyyy-MM-dd').format(leave.startDate)} - ${DateFormat('yyyy-MM-dd').format(leave.endDate)})',
                            ),
                            subtitle: Text(leave.reason),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: leave.status == 'Approved'
                                    ? Colors.green.shade100
                                    : leave.status == 'Pending'
                                    ? Colors.orange.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                leave.status,
                                style: TextStyle(
                                  color: leave.status == 'Approved'
                                      ? Colors.green.shade800
                                      : leave.status == 'Pending'
                                      ? Colors.orange.shade800
                                      : Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
