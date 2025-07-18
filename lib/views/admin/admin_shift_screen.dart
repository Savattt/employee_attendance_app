import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shift_controller.dart';
import '../../models/shift_model.dart';
import '../../services/shift_service.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminShiftScreen extends StatelessWidget {
  AdminShiftScreen({super.key});

  final ShiftController shiftController = Get.put(ShiftController());

  @override
  Widget build(BuildContext context) {
    shiftController.fetchAllShifts();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Shift Management'),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditShiftDialog(context),
        child: const Icon(Icons.add),
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
                        onTap: () =>
                            _showAddOrEditShiftDialog(context, shift: shift),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showAddOrEditShiftDialog(BuildContext context, {ShiftModel? shift}) {
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
        child: _ShiftForm(shift: shift),
      ),
    );
  }
}

class _ShiftForm extends StatefulWidget {
  final ShiftModel? shift;
  const _ShiftForm({this.shift});

  @override
  State<_ShiftForm> createState() => _ShiftFormState();
}

class _ShiftFormState extends State<_ShiftForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId;
  List<UserModel> _users = [];
  DateTime? _selectedDate;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  String _shiftType = 'Morning';
  String _status = 'Scheduled';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    if (widget.shift != null) {
      _selectedUserId = widget.shift!.userId;
      _selectedDate = widget.shift!.date;
      _startTimeController.text = widget.shift!.startTime;
      _endTimeController.text = widget.shift!.endTime;
      _shiftType = widget.shift!.shiftType;
      _status = widget.shift!.status;
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
              widget.shift == null ? 'Add Shift' : 'Edit Shift',
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
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(
                  _selectedDate == null
                      ? 'Select'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time (e.g. 09:00)',
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Start time' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time (e.g. 17:00)',
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'End time' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _shiftType,
              decoration: const InputDecoration(labelText: 'Shift Type'),
              items: const [
                DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                DropdownMenuItem(value: 'Night', child: Text('Night')),
              ],
              onChanged: (val) => setState(() => _shiftType = val ?? 'Morning'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (val) => setState(() => _status = val ?? 'Scheduled'),
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
                      onPressed: _saveShift,
                      child: Text(
                        widget.shift == null ? 'Add Shift' : 'Update Shift',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    setState(() => _isLoading = true);
    final shift = ShiftModel(
      id: widget.shift?.id ?? '',
      userId: _selectedUserId!,
      date: _selectedDate!,
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      shiftType: _shiftType,
      status: _status,
      createdAt: widget.shift?.createdAt ?? DateTime.now(),
    );
    final service = ShiftService();
    if (widget.shift == null) {
      await service.addShift(shift);
    } else {
      await service.updateShift(widget.shift!.id, shift.toMap());
    }
    Get.back();
    Get.find<ShiftController>().fetchAllShifts();
    setState(() => _isLoading = false);
  }
}
