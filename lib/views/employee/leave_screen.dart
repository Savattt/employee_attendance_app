import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/leave_controller.dart';
import '../../models/leave_model.dart';
import '../../utils/responsive_utils.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _startDate = Rx<DateTime?>(null);
  final _endDate = Rx<DateTime?>(null);
  final leaveController = Get.put(LeaveController());

  // State for showing limited vs all leave history
  final _showAllHistory = false.obs;
  final int _initialDisplayCount = 4; // Show only 4 recent entries initially

  @override
  void initState() {
    super.initState();
    // Load leaves when screen initializes
    leaveController.fetchLeaves();
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
                // Request Leave Form - Moved to top for easier access
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.getCardBorderRadius(context),
                  ),
                  child: Padding(
                    padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: theme.primaryColor,
                                size: ResponsiveUtils.getIconSize(context),
                              ),
                              SizedBox(
                                  width:
                                      ResponsiveUtils.getSmallSpacing(context)),
                              Text(
                                'Request Leave',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveUtils.getTitleFontSize(context),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context)),
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
                            onChanged: (val) =>
                                _typeController.text = val ?? '',
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context)),
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() => InkWell(
                                      onTap: () => _selectDate(context, true),
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            ResponsiveUtils.getSpacing(
                                                context)),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: theme.primaryColor),
                                            SizedBox(
                                                width: ResponsiveUtils
                                                    .getSmallSpacing(context)),
                                            Expanded(
                                              child: Text(
                                                _startDate.value != null
                                                    ? '${_startDate.value!.day}/${_startDate.value!.month}/${_startDate.value!.year}'
                                                    : 'Start Date',
                                                style: TextStyle(
                                                  fontSize: ResponsiveUtils
                                                      .getBodyFontSize(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                  width: ResponsiveUtils.getSpacing(context)),
                              Expanded(
                                child: Obx(() => InkWell(
                                      onTap: () => _selectDate(context, false),
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            ResponsiveUtils.getSpacing(
                                                context)),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: theme.primaryColor),
                                            SizedBox(
                                                width: ResponsiveUtils
                                                    .getSmallSpacing(context)),
                                            Expanded(
                                              child: Text(
                                                _endDate.value != null
                                                    ? '${_endDate.value!.day}/${_endDate.value!.month}/${_endDate.value!.year}'
                                                    : 'End Date',
                                                style: TextStyle(
                                                  fontSize: ResponsiveUtils
                                                      .getBodyFontSize(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context)),
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Reason (Optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.getSpacing(context)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveUtils.getSpacing(context)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    _typeController.text.isNotEmpty &&
                                    _startDate.value != null &&
                                    _endDate.value != null) {
                                  final success =
                                      await leaveController.requestLeave(
                                    type: _typeController.text,
                                    startDate: _startDate.value!
                                        .toIso8601String()
                                        .split('T')[0],
                                    endDate: _endDate.value!
                                        .toIso8601String()
                                        .split('T')[0],
                                    reason: _reasonController.text.isNotEmpty
                                        ? _reasonController.text
                                        : null,
                                  );

                                  if (success) {
                                    _typeController.clear();
                                    _reasonController.clear();
                                    _startDate.value = null;
                                    _endDate.value = null;
                                  }
                                }
                              },
                              child: Obx(() => leaveController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Submit Request',
                                      style: TextStyle(
                                        fontSize:
                                            ResponsiveUtils.getBodyFontSize(
                                                context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),
                // Leave History Section - Limited display with See More option
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: theme.primaryColor,
                                  size: ResponsiveUtils.getIconSize(context),
                                ),
                                SizedBox(
                                    width: ResponsiveUtils.getSmallSpacing(
                                        context)),
                                Text(
                                  'Recent Leave History',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getTitleFontSize(
                                        context),
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              if (leaveController.leaveList.length >
                                  _initialDisplayCount) {
                                return TextButton.icon(
                                  onPressed: () {
                                    _showAllHistory.value =
                                        !_showAllHistory.value;
                                  },
                                  icon: Icon(
                                    _showAllHistory.value
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: ResponsiveUtils.getIconSize(context) -
                                        4,
                                  ),
                                  label: Text(
                                    _showAllHistory.value
                                        ? 'Show Less'
                                        : 'See More',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                              context) -
                                          2,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        Obx(() {
                          if (leaveController.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (leaveController.leaveList.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(
                                      height:
                                          ResponsiveUtils.getSpacing(context)),
                                  Text(
                                    'No leave history yet',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                          context),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final displayCount = _showAllHistory.value
                              ? leaveController.leaveList.length
                              : _initialDisplayCount;
                          final itemsToShow = leaveController.leaveList
                              .take(displayCount)
                              .toList();

                          return Column(
                            children: itemsToShow.map((leave) {
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: ResponsiveUtils.getSmallSpacing(
                                        context)),
                                padding: EdgeInsets.all(
                                    ResponsiveUtils.getSpacing(context)),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leave.type,
                                            style: TextStyle(
                                              fontSize: ResponsiveUtils
                                                  .getBodyFontSize(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${leave.startDate.toString().split(' ')[0]} - ${leave.endDate.toString().split(' ')[0]}',
                                            style: TextStyle(
                                              fontSize: ResponsiveUtils
                                                      .getBodyFontSize(
                                                          context) -
                                                  2,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ResponsiveUtils.getSmallSpacing(
                                                context),
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(leave.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        leave.status,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              ResponsiveUtils.getBodyFontSize(
                                                      context) -
                                                  2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }),
                        if (!_showAllHistory.value &&
                            leaveController.leaveList.length >
                                _initialDisplayCount)
                          Padding(
                            padding: EdgeInsets.only(
                              top: ResponsiveUtils.getSpacing(context),
                            ),
                            child: Center(
                              child: Text(
                                'Showing $_initialDisplayCount of ${leaveController.leaveList.length} entries',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getBodyFontSize(context) -
                                          2,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isStartDate) {
        _startDate.value = picked;
        // If end date is before start date, reset it
        if (_endDate.value != null && _endDate.value!.isBefore(picked)) {
          _endDate.value = null;
        }
      } else {
        // Ensure end date is not before start date
        if (_startDate.value != null && picked.isBefore(_startDate.value!)) {
          Get.snackbar(
            'Invalid Date',
            'End date cannot be before start date',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          return;
        }
        _endDate.value = picked;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
