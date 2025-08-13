import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/responsive_utils.dart';
import 'create_user_screen.dart';
import 'main_scaffold.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel userModel;
  const AdminDashboard({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());
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
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: ResponsiveUtils.getCardBorderRadius(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Admin!',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getSmallSpacing(context)),
                      Text(
                        'Manage your organization efficiently',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),

                // Quick Actions Grid
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      ResponsiveUtils.getGridCrossAxisCount(context),
                  crossAxisSpacing: ResponsiveUtils.getSpacing(context),
                  mainAxisSpacing: ResponsiveUtils.getSpacing(context),
                  childAspectRatio:
                      ResponsiveUtils.getGridChildAspectRatio(context),
                  children: [
                    _buildActionCard(
                      context,
                      'Attendance Overview',
                      Icons.people,
                      Colors.indigo,
                      () => _navigateToTab(1),
                      isMobile: isMobile,
                    ),
                    _buildActionCard(
                      context,
                      'Manage Payroll',
                      Icons.attach_money,
                      Colors.green,
                      () => _navigateToTab(2),
                      isMobile: isMobile,
                    ),
                    _buildActionCard(
                      context,
                      'Manage Shifts',
                      Icons.schedule,
                      Colors.blue,
                      () => _navigateToTab(3),
                      isMobile: isMobile,
                    ),
                    _buildActionCard(
                      context,
                      'Leave Approvals',
                      Icons.pending_actions,
                      Colors.orange,
                      () => _navigateToTab(4),
                      isMobile: isMobile,
                    ),
                    _buildActionCard(
                      context,
                      'QR Code Management',
                      Icons.qr_code,
                      Colors.teal,
                      () => _navigateToTab(5),
                      isMobile: isMobile,
                    ),
                    _buildActionCard(
                      context,
                      'Create User',
                      Icons.person_add,
                      Colors.purple,
                      () => Get.to(() => const CreateUserScreen()),
                      isMobile: isMobile,
                    ),
                    if (isMobile) // Only show test button on mobile for space
                      _buildActionCard(
                        context,
                        'Test Leave Request',
                        Icons.bug_report,
                        Colors.red,
                        () => _createTestLeaveRequest(),
                        isMobile: isMobile,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToTab(int index) {
    // Find the AdminMainScaffoldController and change the selected tab
    final controller = Get.find<AdminMainScaffoldController>();
    controller.changeTab(index);
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap,
      {required bool isMobile}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: ResponsiveUtils.getCardBorderRadius(context),
        child: Container(
          padding: ResponsiveUtils.getCardPaddingEdgeInsets(context),
          decoration: BoxDecoration(
            borderRadius: ResponsiveUtils.getCardBorderRadius(context),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.getIconSize(context),
                color: Colors.white,
              ),
              SizedBox(height: ResponsiveUtils.getSmallSpacing(context)),
              Text(
                title,
                style: TextStyle(
                  fontSize:
                      isMobile ? 14 : ResponsiveUtils.getBodyFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createTestLeaveRequest() {
    // This is a placeholder for creating a test leave request.
    // In a real application, you would navigate to a new screen or pass data.
    // For now, we'll just show a snackbar.
    Get.snackbar(
      'Test Leave Request',
      'This button is for testing leave approval/rejection functionality.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
