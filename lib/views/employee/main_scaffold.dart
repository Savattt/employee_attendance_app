import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/responsive_utils.dart';
import 'employee_dashboard.dart';
import 'leave_screen.dart';
import 'attendance_screen.dart';
import 'payroll_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../notifications_screen.dart';

class MainScaffoldController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure selectedIndex is initialized to 0
    selectedIndex.value = 0;
  }

  void changeTab(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    }
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== MainScaffold build START ===');
    // Ensure controller is properly initialized
    final controller = Get.put(MainScaffoldController());
    print('MainScaffold: selectedIndex = ${controller.selectedIndex.value}');

    // Force initialization of the controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          'MainScaffold postFrameCallback: selectedIndex = ${controller.selectedIndex.value}');
      if (controller.selectedIndex.value != 0) {
        controller.selectedIndex.value = 0;
        print('MainScaffold: reset selectedIndex to 0');
      }
    });

    final List<Widget> screens = [
      const EmployeeDashboard(), // Dashboard
      const AttendanceScreen(), // Attendance
      const LeaveScreen(), // Leave
      PayrollScreen(), // Payroll
    ];

    String getTitle() {
      switch (controller.selectedIndex.value) {
        case 0:
          return 'Dashboard';
        case 1:
          return 'Attendance';
        case 2:
          return 'Leave';
        case 3:
          return 'Payroll';
        default:
          return 'Dashboard';
      }
    }

    print('=== Scaffold build START ===');
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        return Scaffold(
          appBar: AppBar(
            title: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    getTitle(),
                    key: ValueKey(controller.selectedIndex.value),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getTitleFontSize(context) - 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            toolbarHeight: ResponsiveUtils.getAppBarHeight(context),
            actions: [
              Obx(() {
                final notificationController =
                    Get.find<NotificationController>();
                print(
                    'MainScaffold: Notification badge count = ${notificationController.unreadCount.value}');

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
          body: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                key: ValueKey(controller.selectedIndex.value),
                child: screens[controller.selectedIndex.value],
              )),
          bottomNavigationBar: Obx(() {
            print(
                '=== BottomNavigationBar build: selectedIndex = ${controller.selectedIndex.value} ===');
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Dashboard
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.dashboard,
                          label: 'Dashboard',
                          isSelected: controller.selectedIndex.value == 0,
                          onTap: () => controller.changeTab(0),
                          context: context,
                        ),
                      ),

                      // Attendance
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.history,
                          label: 'Attendance',
                          isSelected: controller.selectedIndex.value == 1,
                          onTap: () => controller.changeTab(1),
                          context: context,
                        ),
                      ),

                      // Centered QR Scanner Button
                      Expanded(
                        child: _buildCenteredQRButton(context),
                      ),

                      // Leave
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.beach_access,
                          label: 'Leave',
                          isSelected: controller.selectedIndex.value == 2,
                          onTap: () => controller.changeTab(2),
                          context: context,
                        ),
                      ),

                      // Payroll
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.attach_money,
                          label: 'Payroll',
                          isSelected: controller.selectedIndex.value == 3,
                          onTap: () => controller.changeTab(3),
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
    print('=== Scaffold build END ===');
    print('=== MainScaffold build END ===');
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.1 : 1.0,
                    child: Icon(
                      icon,
                      size: ResponsiveUtils.getIconSize(context) - 12,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredQRButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed('/qr-scanner');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.toNamed('/qr-scanner');
                },
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: ResponsiveUtils.getIconSize(context) - 8,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Scan',
          style: TextStyle(
            fontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
