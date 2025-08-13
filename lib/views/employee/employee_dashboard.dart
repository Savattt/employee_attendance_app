import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/responsive_utils.dart';
import 'main_scaffold.dart';

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
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          return SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Obx(() {
                  final userModel = Get.find<AuthController>().userModel.value;
                  final name = userModel?.displayName ?? 'Employee';
                  final email = userModel?.email;
                  final photoUrl = userModel?.photoUrl;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          ResponsiveUtils.getCardBorderRadius(context),
                    ),
                    child: Padding(
                      padding:
                          ResponsiveUtils.getCardPaddingEdgeInsets(context),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: ResponsiveUtils.isMobile(context) ? 28 : 35,
                            backgroundColor:
                                theme.primaryColor.withOpacity(0.1),
                            backgroundImage: (photoUrl != null &&
                                    photoUrl.isNotEmpty)
                                ? NetworkImage(
                                    CloudinaryService.getOptimizedProfileUrl(
                                        photoUrl))
                                : null,
                            child: (photoUrl == null || photoUrl.isEmpty)
                                ? Icon(Icons.person,
                                    size: ResponsiveUtils.getIconSize(context),
                                    color: theme.primaryColor)
                                : null,
                          ),
                          SizedBox(width: ResponsiveUtils.getSpacing(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getTitleFontSize(
                                        context),
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                if (email != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                              context) -
                                          2,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),

                // Quick Actions Grid
                ResponsiveBuilder(
                  builder: (context, isMobile, isTablet, isDesktop) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.qr_code_scanner,
                                label: 'QR Scanner',
                                color: Colors.blue,
                                onTap: () {
                                  Get.toNamed('/qr-scanner');
                                },
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveUtils.getSpacing(context)),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.history,
                                label: 'Attendance',
                                color: Colors.green,
                                onTap: () {
                                  Get.find<MainScaffoldController>()
                                      .changeTab(1);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.beach_access,
                                label: 'Leave',
                                color: Colors.orange,
                                onTap: () {
                                  Get.find<MainScaffoldController>()
                                      .changeTab(2);
                                },
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveUtils.getSpacing(context)),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.attach_money,
                                label: 'Payroll',
                                color: Colors.purple,
                                onTap: () {
                                  Get.find<MainScaffoldController>()
                                      .changeTab(3);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),

                // Test Notification Button (for debugging)
                if (ResponsiveUtils.isMobile(context)) // Only show on mobile
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final notificationController =
                            Get.find<NotificationController>();
                        notificationController.testNotification();
                        Get.snackbar(
                          'Test',
                          'Test notification sent!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.notifications),
                      label: const Text('Test Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getSpacing(context),
                          vertical: ResponsiveUtils.getSmallSpacing(context),
                        ),
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
            borderRadius: ResponsiveUtils.getCardBorderRadius(context),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.getSpacing(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: ResponsiveUtils.getIconSize(context),
                ),
                SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
