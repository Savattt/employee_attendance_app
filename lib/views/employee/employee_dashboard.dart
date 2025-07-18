import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'leave_screen.dart';
import 'payroll_screen.dart';
import 'shift_screen.dart';
import '../../controllers/auth_controller.dart';

class EmployeeDashboard extends StatelessWidget {
  final String userName;
  final String? email;
  final bool isCheckedIn;
  final String attendanceStatus;

  const EmployeeDashboard({
    super.key,
    this.userName = 'Employee',
    this.email,
    this.isCheckedIn = false,
    this.attendanceStatus = 'Absent',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $userName!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (email != null)
                            Text(
                              email!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Attendance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: theme.primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Today\'s Attendance',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: attendanceStatus == 'Present'
                                ? Colors.green.shade100
                                : attendanceStatus == 'Late'
                                ? Colors.orange.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            attendanceStatus,
                            style: TextStyle(
                              color: attendanceStatus == 'Present'
                                  ? Colors.green.shade800
                                  : attendanceStatus == 'Late'
                                  ? Colors.orange.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCheckedIn
                              ? Colors.red
                              : theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(isCheckedIn ? Icons.logout : Icons.login),
                        label: Text(
                          isCheckedIn ? 'Check Out' : 'Check In',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          // TODO: Implement check-in/out logic
                          Get.snackbar(
                            'Action',
                            isCheckedIn ? 'Checked out!' : 'Checked in!',
                            backgroundColor: Colors.blue.shade50,
                            colorText: theme.primaryColor,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickActionCard(
                  icon: Icons.beach_access,
                  label: 'Leave',
                  color: Colors.orange,
                  onTap: () {
                    Get.to(() => LeaveScreen());
                  },
                ),
                _QuickActionCard(
                  icon: Icons.attach_money,
                  label: 'Payroll',
                  color: Colors.green,
                  onTap: () {
                    Get.to(() => PayrollScreen());
                  },
                ),
                _QuickActionCard(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  color: Colors.blue,
                  onTap: () {
                    Get.to(() => ShiftScreen());
                  },
                ),
              ],
            ),
            // Add more dashboard widgets as needed
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
