import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shift_controller.dart';
import 'package:intl/intl.dart';

class ShiftScreen extends StatelessWidget {
  ShiftScreen({super.key});

  final ShiftController shiftController = Get.put(ShiftController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('My Shifts'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Obx(
          () => shiftController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : shiftController.shiftList.isEmpty
              ? const Center(child: Text('No shifts found.'))
              : ListView.separated(
                  itemCount: shiftController.shiftList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final shift = shiftController.shiftList[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.schedule,
                          color: theme.primaryColor,
                        ),
                        title: Text(
                          DateFormat('yyyy-MM-dd').format(shift.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${shift.startTime} - ${shift.endTime} (${shift.shiftType})',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: shift.status == 'Scheduled'
                                ? Colors.blue.shade100
                                : shift.status == 'Completed'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            shift.status,
                            style: TextStyle(
                              color: shift.status == 'Scheduled'
                                  ? Colors.blue.shade800
                                  : shift.status == 'Completed'
                                  ? Colors.green.shade800
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
      ),
    );
  }
}
