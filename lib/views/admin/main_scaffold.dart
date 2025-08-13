import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_utils.dart';
import 'admin_dashboard.dart';
import 'admin_attendance_screen.dart';
import 'admin_payroll_screen.dart';
import 'admin_shift_screen.dart';
import 'admin_leave_approval_screen.dart';
import 'qr_code_management_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../notifications_screen.dart';

class AdminMainScaffoldController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class AdminMainScaffold extends StatelessWidget {
  final UserModel userModel;
  const AdminMainScaffold({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminMainScaffoldController());

    final List<Widget> screens = [
      AdminDashboard(userModel: userModel),
      const AdminAttendanceScreen(),
      AdminPayrollScreen(),
      AdminShiftScreen(),
      const AdminLeaveApprovalScreen(),
      const QRCodeManagementScreen(),
    ];

    String getTitle() {
      switch (controller.selectedIndex.value) {
        case 0:
          return 'Admin Dashboard';
        case 1:
          return 'Attendance';
        case 2:
          return 'Payroll';
        case 3:
          return 'Shifts';
        case 4:
          return 'Leave Approvals';
        case 5:
          return 'QR Codes';
        default:
          return 'Admin Dashboard';
      }
    }

    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        return Scaffold(
          appBar: AppBar(
            title: Obx(() => Text(
                  getTitle(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getTitleFontSize(context) - 4,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            toolbarHeight: ResponsiveUtils.getAppBarHeight(context),
            actions: [
              Obx(() {
                final notificationController =
                    Get.find<NotificationController>();
                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        size: ResponsiveUtils.getIconSize(context) - 8,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () {
                        Get.to(() => NotificationsScreen());
                      },
                    ),
                    if (notificationController.unreadCount.value > 0)
                      Positioned(
                        right: ResponsiveUtils.isMobile(context) ? 8 : 12,
                        top: ResponsiveUtils.isMobile(context) ? 8 : 12,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${notificationController.unreadCount.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  ResponsiveUtils.isMobile(context) ? 10 : 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  size: ResponsiveUtils.getIconSize(context) - 8,
                ),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await Get.find<AuthController>().signOut();
                },
              ),
            ],
          ),
          body: Obx(() => screens[controller.selectedIndex.value]),
          bottomNavigationBar: Obx(() {
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeTab,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 8,
              showUnselectedLabels: true,
              selectedFontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
              unselectedFontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.dashboard,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.people,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.attach_money,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'Payroll',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.schedule,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'Shifts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.pending_actions,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'Leave Ap...',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.qr_code,
                    size: ResponsiveUtils.getIconSize(context) - 12,
                  ),
                  label: 'QR Codes',
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
