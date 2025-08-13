import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/attendance_model.dart';
import '../../utils/responsive_utils.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();
  final AuthController _authController = Get.find<AuthController>();

  // State for showing limited vs all attendance history
  final _showAllHistory = false.obs;
  final int _initialDisplayCount = 5; // Show only 5 recent entries initially

  // Month selection for detailed view
  DateTime? _selectedMonth;
  bool _showDetailedView = false;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _loadAttendanceHistory();
    // Set default month to current month
    _selectedMonth = DateTime.now();
  }

  Future<void> _loadTodayAttendance() async {
    if (_authController.user.value != null) {
      await _attendanceController.loadTodayAttendance(
        _authController.user.value!.uid,
      );
    }
  }

  Future<void> _loadAttendanceHistory() async {
    if (_authController.user.value != null) {
      await _attendanceController.loadAttendanceHistory(
        _authController.user.value!.uid,
      );
    }
  }

  Future<void> _loadMonthlyAttendance() async {
    if (_authController.user.value != null && _selectedMonth != null) {
      final startOfMonth =
          DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
      final endOfMonth =
          DateTime(_selectedMonth!.year, _selectedMonth!.month + 1, 0);

      await _attendanceController.loadAllAttendance(
        from: startOfMonth.toIso8601String().split('T')[0],
        to: endOfMonth.toIso8601String().split('T')[0],
      );
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      await _loadMonthlyAttendance();
    }
  }

  void _exportAttendanceData() {
    final attendanceData = _attendanceController.attendanceList;

    if (attendanceData.isEmpty) {
      Get.snackbar('No Data', 'No attendance data to export');
      return;
    }

    // Create CSV content
    final csvContent = _generateCSVContent(attendanceData);

    // Show export dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Attendance Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Records: ${attendanceData.length}'),
            const SizedBox(height: 8),
            Text(_showDetailedView
                ? 'Month: ${DateFormat('MMMM yyyy').format(_selectedMonth!)}'
                : 'All Time Records'),
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
    buffer
        .writeln('Date,Check-in Time,Check-out Time,Duration,Status,Location');

    // CSV Data
    for (final record in attendance) {
      final checkInDate = DateFormat('yyyy-MM-dd').format(record.checkInTime);
      final checkInTime = DateFormat('HH:mm:ss').format(record.checkInTime);
      final checkOutTime = record.checkOutTime != null
          ? DateFormat('HH:mm:ss').format(record.checkOutTime!)
          : 'Not checked out';
      final duration = _calculateDuration(record);

      buffer.writeln(
          '$checkInDate,$checkInTime,$checkOutTime,$duration,${record.status},${record.location}');
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
                // Today's Status Card
                _buildTodayStatusCard(theme),
                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),

                // Comprehensive Attendance Data Card
                _buildAttendanceDataCard(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayStatusCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
      ),
      child: Padding(
        padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
        child: Obx(() {
          final user = _authController.user.value;
          if (user == null) return const SizedBox.shrink();

          final todayAttendance = _attendanceController.todayAttendance.value;
          final status = todayAttendance?.status ?? 'not-checked-in';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.primaryColor,
                    size: ResponsiveUtils.getIconSize(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getSmallSpacing(context)),
                  Text(
                    'Today\'s Attendance',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getSpacing(context),
                      vertical: ResponsiveUtils.getSmallSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                      ),
                    ),
                  ),
                ],
              ),
              if (todayAttendance != null) ...[
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                _buildInfoRow('Check-in Time', todayAttendance.checkInTime),
                if (todayAttendance.checkOutTime != null) ...[
                  SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
                  _buildInfoRow(
                      'Check-out Time', todayAttendance.checkOutTime!),
                  SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
                  _buildInfoRowString(
                      'Duration', _calculateDuration(todayAttendance)),
                ],
                SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
                _buildInfoRowString('Location', todayAttendance.location),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceDataCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
      ),
      child: Padding(
        padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and view toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: theme.primaryColor,
                        size: ResponsiveUtils.getIconSize(context),
                      ),
                      SizedBox(width: ResponsiveUtils.getSmallSpacing(context)),
                      Expanded(
                        child: Text(
                          'Attendance Data & History',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSmallSpacing(context)),
                // Export Button - Fixed overflow
                Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.isMobile(context) ? 80 : 100,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _exportAttendanceData,
                    icon: Icon(
                      Icons.download,
                      size: ResponsiveUtils.getIconSize(context) - 10,
                    ),
                    label: Text(
                      'Export',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context) - 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getSmallSpacing(context),
                        vertical: ResponsiveUtils.getSmallSpacing(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context)),

            // View Toggle Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDetailedView = false;
                      });
                      _loadAttendanceHistory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showDetailedView
                          ? Colors.grey[300]
                          : theme.primaryColor,
                      foregroundColor:
                          _showDetailedView ? Colors.grey[700] : Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: _showDetailedView ? 0 : 2,
                    ),
                    child: Text(
                      'Recent History',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context) - 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDetailedView = true;
                      });
                      _loadMonthlyAttendance();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showDetailedView
                          ? theme.primaryColor
                          : Colors.grey[300],
                      foregroundColor:
                          _showDetailedView ? Colors.white : Colors.grey[700],
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getSpacing(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: _showDetailedView ? 2 : 0,
                    ),
                    child: Text(
                      'Monthly View',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getBodyFontSize(context) - 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_showDetailedView) ...[
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
              // Month Selection
              InkWell(
                onTap: () => _selectMonth(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      EdgeInsets.all(ResponsiveUtils.getSmallSpacing(context)),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: ResponsiveUtils.getIconSize(context) - 8,
                        color: theme.primaryColor,
                      ),
                      SizedBox(width: ResponsiveUtils.getSmallSpacing(context)),
                      Expanded(
                        child: Text(
                          _selectedMonth != null
                              ? DateFormat('MMMM yyyy').format(_selectedMonth!)
                              : 'Select Month',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: theme.primaryColor,
                        size: ResponsiveUtils.getIconSize(context) - 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: ResponsiveUtils.getSpacing(context)),

            // See More/Less button for Recent History
            if (!_showDetailedView)
              Obx(() {
                if (_attendanceController.attendanceList.length >
                    _initialDisplayCount) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _showAllHistory.value = !_showAllHistory.value;
                        },
                        icon: Icon(
                          _showAllHistory.value
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: ResponsiveUtils.getIconSize(context) - 8,
                        ),
                        label: Text(
                          _showAllHistory.value ? 'Show Less' : 'See More',
                          style: TextStyle(
                            fontSize:
                                ResponsiveUtils.getBodyFontSize(context) - 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveUtils.getSmallSpacing(context),
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),

            SizedBox(height: ResponsiveUtils.getSpacing(context)),

            // Attendance Data Display
            Obx(() {
              if (_attendanceController.isLoading.value) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        Text(
                          'Loading attendance data...',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final attendanceData = _attendanceController.attendanceList;

              if (attendanceData.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: ResponsiveUtils.getIconSize(context) * 2,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        Text(
                          _showDetailedView
                              ? 'No attendance records found for ${_selectedMonth != null ? DateFormat('MMMM yyyy').format(_selectedMonth!) : 'selected month'}'
                              : 'No attendance history found',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getBodyFontSize(context),
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: ResponsiveUtils.getSmallSpacing(context)),
                        Text(
                          'Your attendance records will appear here',
                          style: TextStyle(
                            fontSize:
                                ResponsiveUtils.getBodyFontSize(context) - 2,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Determine how many items to show for recent history
              final displayCount = _showDetailedView
                  ? attendanceData.length
                  : (_showAllHistory.value
                      ? attendanceData.length
                      : _initialDisplayCount);
              final itemsToShow = attendanceData.take(displayCount).toList();

              return Column(
                children: [
                  // Summary Stats for Monthly View
                  if (_showDetailedView) ...[
                    Container(
                      padding:
                          EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Total Days',
                              itemsToShow.length.toString(),
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Checked In',
                              itemsToShow
                                  .where((a) => a.status == 'checked-in')
                                  .length
                                  .toString(),
                              Icons.login,
                              Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Checked Out',
                              itemsToShow
                                  .where((a) => a.status == 'checked-out')
                                  .length
                                  .toString(),
                              Icons.logout,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                  ],

                  // Attendance Records List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsToShow.length,
                    separatorBuilder: (_, __) => SizedBox(
                        height: ResponsiveUtils.getSmallSpacing(context)),
                    itemBuilder: (context, index) {
                      final attendance = itemsToShow[index];
                      return Container(
                        padding: EdgeInsets.all(
                            ResponsiveUtils.getSmallSpacing(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(attendance.checkInTime),
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                          context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.getSmallSpacing(
                                        context),
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(attendance.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    attendance.status
                                        .replaceAll('-', ' ')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                              context) -
                                          2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                          fontSize:
                                              ResponsiveUtils.getBodyFontSize(
                                                      context) -
                                                  2,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (attendance.checkOutTime != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Check-out: ${DateFormat('HH:mm').format(attendance.checkOutTime!)}',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.getBodyFontSize(
                                                        context) -
                                                    2,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Duration: ${_calculateDuration(attendance)}',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.getBodyFontSize(
                                                        context) -
                                                    2,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Location:',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveUtils.getBodyFontSize(
                                                      context) -
                                                  2,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        attendance.location,
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveUtils.getBodyFontSize(
                                                      context) -
                                                  2,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
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

                  // Show count indicator for Recent History
                  if (!_showDetailedView &&
                      !_showAllHistory.value &&
                      _attendanceController.attendanceList.length >
                          _initialDisplayCount)
                    Padding(
                      padding: EdgeInsets.only(
                        top: ResponsiveUtils.getSpacing(context),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getSpacing(context),
                            vertical: ResponsiveUtils.getSmallSpacing(context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Showing $_initialDisplayCount of ${_attendanceController.attendanceList.length} entries',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getBodyFontSize(context) - 2,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
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

  Widget _buildInfoRow(String label, DateTime time) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveUtils.getBodyFontSize(context),
          ),
        ),
        Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowString(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveUtils.getBodyFontSize(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
        ),
      ],
    );
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
        return 'Not Checked In';
    }
  }
}
