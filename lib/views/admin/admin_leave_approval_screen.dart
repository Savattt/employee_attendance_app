import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/leave_controller.dart';
import '../../models/leave_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLeaveApprovalScreen extends StatelessWidget {
  const AdminLeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaveController leaveController = Get.put(LeaveController());
    leaveController.fetchAllLeaves();
    final theme = Theme.of(context);

    // Add filter state
    final showOnlyPending = true.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTestPendingLeave(),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Create Test Pending Leave',
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (leaveController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading leave requests...'),
              ],
            ),
          );
        }

        // Filter leaves based on status
        final filteredLeaves = showOnlyPending.value
            ? leaveController.allLeaves
                .where((leave) => leave.status == 'Pending')
                .toList()
            : leaveController.allLeaves;

        if (filteredLeaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  showOnlyPending.value
                      ? 'No pending leave requests'
                      : 'No leave requests found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showOnlyPending.value
                      ? 'All leave requests have been processed.'
                      : 'When employees submit leave requests,\nthey will appear here for review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      showOnlyPending.value = !showOnlyPending.value,
                  child: Text(showOnlyPending.value
                      ? 'Show All Requests'
                      : 'Show Only Pending'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leave Requests',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredLeaves.length} ${showOnlyPending.value ? 'pending' : ''} request(s)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter toggle button
                  Obx(() => IconButton(
                        onPressed: () =>
                            showOnlyPending.value = !showOnlyPending.value,
                        icon: Icon(
                          showOnlyPending.value
                              ? Icons.filter_list
                              : Icons.filter_list_off,
                          color: Colors.white,
                        ),
                        tooltip: showOnlyPending.value
                            ? 'Show All'
                            : 'Show Only Pending',
                      )),
                ],
              ),
            ),

            // Leave Requests List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredLeaves.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final LeaveModel leave = filteredLeaves[index];
                  final duration =
                      leave.endDate.difference(leave.startDate).inDays + 1;

                  // Debug print to see leave status
                  print('Leave ${leave.id}: Status = ${leave.status}');

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with employee info and status
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    theme.primaryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      leave.employeeName ?? 'Unknown Employee',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      leave.employeeEmail ??
                                          'No email available',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: leave.status == 'Approved'
                                      ? Colors.green.shade100
                                      : leave.status == 'Pending'
                                          ? Colors.orange.shade100
                                          : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Leave details
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                leave.type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.calendar_today,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$duration day(s)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Date range
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${DateFormat('MMM d, yyyy').format(leave.startDate)} - ${DateFormat('MMM d, yyyy').format(leave.endDate)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Reason
                          if (leave.reason.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.note,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    leave.reason,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Request date
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Requested: ${DateFormat('MMM d, yyyy').format(leave.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Action buttons for pending requests
                          if (leave.status == 'Pending') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      leaveController.updateLeaveStatus(
                                          leave.id, 'Approved');
                                      Get.snackbar(
                                        'Success',
                                        'Leave request approved!',
                                        backgroundColor: Colors.green.shade50,
                                        colorText: Colors.green.shade900,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                    },
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      leaveController.updateLeaveStatus(
                                          leave.id, 'Rejected');
                                      Get.snackbar(
                                        'Success',
                                        'Leave request rejected!',
                                        backgroundColor: Colors.red.shade50,
                                        colorText: Colors.red.shade900,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                    },
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
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
          ],
        );
      }),
    );
  }

  void _createTestPendingLeave() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month, now.day + 1);
      final DateTime endDate = DateTime(now.year, now.month, now.day + 2);

      // Create test leave directly in Firestore
      await FirebaseFirestore.instance.collection('leaves').add({
        'type': 'Test Leave',
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'reason': 'This is a test pending leave request for debugging.',
        'status': 'Pending',
        'createdAt': Timestamp.fromDate(now),
        'userId': 'test_user_id',
        'employeeName': 'Test Employee',
        'employeeEmail': 'test@example.com',
      });

      // Refresh the leave list
      final LeaveController leaveController = Get.find();
      await leaveController.fetchAllLeaves();

      Get.snackbar(
        'Success',
        'Test pending leave request created!',
        backgroundColor: Colors.blue.shade50,
        colorText: Colors.blue.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error creating test leave: $e');
      Get.snackbar(
        'Error',
        'Failed to create test leave request: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
