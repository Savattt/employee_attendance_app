import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_utils.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();
  final AuthController _authController = Get.find<AuthController>();

  DateTime? _startDate;
  DateTime? _endDate;
  String _filterStatus = 'all';
  String? _selectedEmployeeId;
  List<UserModel> _employees = [];
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month (day 1 to current day)
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _loadEmployees();
    _loadAttendanceData();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
    });

    try {
      // Load all employees from Firestore
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .get();

      _employees = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading employees: $e');
      Get.snackbar('Error', 'Failed to load employees');
    } finally {
      setState(() {
        _isLoadingEmployees = false;
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    if (_startDate != null && _endDate != null) {
      await _attendanceController.loadAllAttendance(
        from: _startDate!.toIso8601String().split('T')[0],
        to: _endDate!
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0], // Include end date
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadAttendanceData();
    }
  }

  List<AttendanceModel> _getFilteredAttendance() {
    List<AttendanceModel> attendance = _attendanceController.attendanceList;

    // Filter by status
    if (_filterStatus != 'all') {
      attendance = attendance.where((a) => a.status == _filterStatus).toList();
    }

    // Filter by employee
    if (_selectedEmployeeId != null) {
      attendance =
          attendance.where((a) => a.userId == _selectedEmployeeId).toList();
    }

    return attendance;
  }

  String _calculateDuration(AttendanceModel attendance) {
    if (attendance.checkOutTime == null) return 'Not checked out';

    final duration =
        attendance.checkOutTime!.difference(attendance.checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'checked-in':
        return Colors.green;
      case 'checked-out':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'checked-in':
        return 'Checked In';
      case 'checked-out':
        return 'Checked Out';
      default:
        return 'Unknown';
    }
  }

  void _exportAttendanceData() {
    final filteredAttendance = _getFilteredAttendance();
    if (filteredAttendance.isEmpty) {
      Get.snackbar('No Data', 'No attendance data to export');
      return;
    }

    // Create CSV content
    final csvContent = _generateCSVContent(filteredAttendance);

    // Show export dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Attendance Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Records: ${filteredAttendance.length}'),
            const SizedBox(height: 8),
            Text(
                'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'),
            const SizedBox(height: 16),
            const Text('CSV Content Preview:'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.maxFinite,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csvContent.split('\n').take(10).join('\n'),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadCSV(csvContent);
            },
            child: const Text('Download CSV'),
          ),
        ],
      ),
    );
  }

  String _generateCSVContent(List<AttendanceModel> attendance) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'Employee Name,Employee Email,Date,Check-in Time,Check-out Time,Duration,Status,Location');

    // CSV Data
    for (final record in attendance) {
      final checkInDate = DateFormat('yyyy-MM-dd').format(record.checkInTime);
      final checkInTime = DateFormat('HH:mm:ss').format(record.checkInTime);
      final checkOutTime = record.checkOutTime != null
          ? DateFormat('HH:mm:ss').format(record.checkOutTime!)
          : 'Not checked out';
      final duration = _calculateDuration(record);

      buffer.writeln(
          '${record.employeeName},${record.employeeEmail},$checkInDate,$checkInTime,$checkOutTime,$duration,${record.status},${record.location}');
    }

    return buffer.toString();
  }

  void _downloadCSV(String csvContent) {
    // For now, we'll show the CSV content in a dialog
    // In a real app, you'd use a file download package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Content'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          return SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              children: [
                // Header Card with Date Range Selection and Filters
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.getCardBorderRadius(context),
                  ),
                  child: Padding(
                    padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: theme.primaryColor,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            SizedBox(
                                width:
                                    ResponsiveUtils.getSmallSpacing(context)),
                            Text(
                              'Employee Attendance',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.getTitleFontSize(context),
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),

                        // Date Range Selection
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDateRange(context),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      ResponsiveUtils.getSmallSpacing(context)),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        size: ResponsiveUtils.getIconSize(
                                                context) -
                                            8,
                                        color: theme.primaryColor,
                                      ),
                                      SizedBox(
                                          width:
                                              ResponsiveUtils.getSmallSpacing(
                                                  context)),
                                      Expanded(
                                        child: Text(
                                          _startDate != null && _endDate != null
                                              ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                                              : 'Select Date Range',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.getBodyFontSize(
                                                    context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: ResponsiveUtils.getSpacing(context)),

                        // Filters Row - Responsive Layout
                        ResponsiveBuilder(
                          builder: (context, isMobile, isTablet, isDesktop) {
                            if (isMobile) {
                              // Stack filters vertically on mobile
                              return Column(
                                children: [
                                  // Status Filter
                                  DropdownButtonFormField<String>(
                                    value: _filterStatus,
                                    decoration: InputDecoration(
                                      labelText: 'Status',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All Status')),
                                      DropdownMenuItem(
                                          value: 'checked-in',
                                          child: Text('Checked In')),
                                      DropdownMenuItem(
                                          value: 'checked-out',
                                          child: Text('Checked Out')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _filterStatus = value!;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                      height:
                                          ResponsiveUtils.getSpacing(context)),
                                  // Employee Filter
                                  _isLoadingEmployees
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : DropdownButtonFormField<String>(
                                          value: _selectedEmployeeId,
                                          decoration: InputDecoration(
                                            labelText: 'Employee',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text('All Employees'),
                                            ),
                                            ..._employees.map((employee) =>
                                                DropdownMenuItem<String>(
                                                  value: employee.uid,
                                                  child: Text(
                                                    employee.displayName ??
                                                        employee.email,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedEmployeeId = value;
                                            });
                                          },
                                        ),
                                ],
                              );
                            } else {
                              // Side by side on larger screens
                              return Row(
                                children: [
                                  // Status Filter
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _filterStatus,
                                      decoration: InputDecoration(
                                        labelText: 'Status',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'all',
                                            child: Text('All Status')),
                                        DropdownMenuItem(
                                            value: 'checked-in',
                                            child: Text('Checked In')),
                                        DropdownMenuItem(
                                            value: 'checked-out',
                                            child: Text('Checked Out')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _filterStatus = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          ResponsiveUtils.getSpacing(context)),
                                  // Employee Filter
                                  Expanded(
                                    child: _isLoadingEmployees
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : DropdownButtonFormField<String>(
                                            value: _selectedEmployeeId,
                                            decoration: InputDecoration(
                                              labelText: 'Employee',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem<String>(
                                                value: null,
                                                child: Text('All Employees'),
                                              ),
                                              ..._employees.map((employee) =>
                                                  DropdownMenuItem<String>(
                                                    value: employee.uid,
                                                    child: Text(
                                                      employee.displayName ??
                                                          employee.email,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedEmployeeId = value;
                                              });
                                            },
                                          ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),

                        SizedBox(height: ResponsiveUtils.getSpacing(context)),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _loadAttendanceData,
                                icon: Icon(
                                  Icons.refresh,
                                  size:
                                      ResponsiveUtils.getIconSize(context) - 8,
                                ),
                                label: Text(
                                  'Refresh Data',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveUtils.getSpacing(context),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveUtils.getSpacing(context)),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _exportAttendanceData,
                                icon: Icon(
                                  Icons.download,
                                  size:
                                      ResponsiveUtils.getIconSize(context) - 8,
                                ),
                                label: Text(
                                  'Export CSV',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveUtils.getSpacing(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),

                // Attendance Data Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.getCardBorderRadius(context),
                  ),
                  child: Padding(
                    padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: theme.primaryColor,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            SizedBox(
                                width:
                                    ResponsiveUtils.getSmallSpacing(context)),
                            Text(
                              'Attendance Records',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.getTitleFontSize(context),
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        Obx(() {
                          if (_attendanceController.isLoading.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final filteredAttendance = _getFilteredAttendance();

                          if (filteredAttendance.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: ResponsiveUtils.getIconSize(context) *
                                        2,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(
                                      height:
                                          ResponsiveUtils.getSpacing(context)),
                                  Text(
                                    'No attendance records found for the selected criteria',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                          context),
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Summary Stats
                              Container(
                                padding: EdgeInsets.all(
                                    ResponsiveUtils.getSpacing(context)),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatItem(
                                        'Total',
                                        filteredAttendance.length.toString(),
                                        Icons.people,
                                        Colors.blue,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatItem(
                                        'Checked In',
                                        filteredAttendance
                                            .where(
                                                (a) => a.status == 'checked-in')
                                            .length
                                            .toString(),
                                        Icons.login,
                                        Colors.green,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatItem(
                                        'Checked Out',
                                        filteredAttendance
                                            .where((a) =>
                                                a.status == 'checked-out')
                                            .length
                                            .toString(),
                                        Icons.logout,
                                        Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                  height: ResponsiveUtils.getSpacing(context)),

                              // Attendance List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredAttendance.length,
                                separatorBuilder: (_, __) => SizedBox(
                                    height: ResponsiveUtils.getSmallSpacing(
                                        context)),
                                itemBuilder: (context, index) {
                                  final attendance = filteredAttendance[index];
                                  return Container(
                                    padding: EdgeInsets.all(
                                        ResponsiveUtils.getSpacing(context)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    attendance.employeeName,
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                          .getBodyFontSize(
                                                              context),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    attendance.employeeEmail,
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                              .getBodyFontSize(
                                                                  context) -
                                                          2,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    DateFormat('MMM dd, yyyy')
                                                        .format(attendance
                                                            .checkInTime),
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                              .getBodyFontSize(
                                                                  context) -
                                                          2,
                                                      color: Colors.grey[500],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: ResponsiveUtils
                                                    .getSmallSpacing(context),
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    attendance.status),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusText(
                                                    attendance.status),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: ResponsiveUtils
                                                          .getBodyFontSize(
                                                              context) -
                                                      2,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(
                                            height:
                                                ResponsiveUtils.getSmallSpacing(
                                                    context)),

                                        // Time Details
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Check-in: ${DateFormat('HH:mm').format(attendance.checkInTime)}',
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                              .getBodyFontSize(
                                                                  context) -
                                                          2,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  if (attendance.checkOutTime !=
                                                      null) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Check-out: ${DateFormat('HH:mm').format(attendance.checkOutTime!)}',
                                                      style: TextStyle(
                                                        fontSize: ResponsiveUtils
                                                                .getBodyFontSize(
                                                                    context) -
                                                            2,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Duration: ${_calculateDuration(attendance)}',
                                                      style: TextStyle(
                                                        fontSize: ResponsiveUtils
                                                                .getBodyFontSize(
                                                                    context) -
                                                            2,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Location:',
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                              .getBodyFontSize(
                                                                  context) -
                                                          2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    attendance.location,
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils
                                                              .getBodyFontSize(
                                                                  context) -
                                                          2,
                                                      color: Colors.grey[600],
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ResponsiveUtils.getIconSize(context),
        ),
        SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context) - 2,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
