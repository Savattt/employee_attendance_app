import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../controllers/admin_controller.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import 'admin_payroll_screen.dart';
import 'admin_shift_screen.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel userModel;
  const AdminDashboard({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await Get.find<AuthController>().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => Get.to(() => AdminPayrollScreen()),
              child: const Text('Manage Payrolls'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => AdminShiftScreen()),
              child: const Text('Manage Shifts'),
            ),
            const SizedBox(height: 12),
            Text(
              'All Leave Requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => adminController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : adminController.leaveList.isEmpty
                    ? const Center(child: Text('No leave requests.'))
                    : ListView.separated(
                        itemCount: adminController.leaveList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final leave = adminController.leaveList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: theme.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${leave.type} (${DateFormat('yyyy-MM-dd').format(leave.startDate)} - ${DateFormat('yyyy-MM-dd').format(leave.endDate)})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Employee: ${leave.employeeEmail ?? 'Unknown'}',
                                            ),
                                            Text('Reason: ${leave.reason}'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                    ],
                                  ),
                                  if (leave.status == 'Pending') ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          tooltip: 'Approve',
                                          onPressed: () =>
                                              adminController.updateLeaveStatus(
                                                leave,
                                                'Approved',
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Reject',
                                          onPressed: () =>
                                              adminController.updateLeaveStatus(
                                                leave,
                                                'Rejected',
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
