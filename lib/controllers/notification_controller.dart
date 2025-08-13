import 'package:get/get.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  // Stream subscription for real-time updates
  StreamSubscription<QuerySnapshot>? _notificationsStream;

  @override
  void onInit() {
    super.onInit();
    print('NotificationController: onInit called');
    // Wait for user to be available before setting up listeners
    _initializeWhenUserReady();
  }

  void _initializeWhenUserReady() {
    // Check if user is already available
    final user = AuthController.to.user.value;
    if (user != null) {
      print(
          'NotificationController: User already available, initializing immediately');
      _initializeNotificationSystem();
    } else {
      print('NotificationController: User not available, waiting...');
      // Listen for user changes
      ever(AuthController.to.user, (user) {
        if (user != null) {
          print(
              'NotificationController: User became available, initializing now');
          _initializeNotificationSystem();
        } else {
          print('NotificationController: User logged out, cleaning up');
          _cleanupOnLogout();
        }
      });
    }
  }

  void _cleanupOnLogout() {
    print('NotificationController: Cleaning up on logout');
    // Cancel the real-time listener
    _notificationsStream?.cancel();
    _notificationsStream = null;

    // Clear all notifications and reset counts
    notifications.clear();
    unreadCount.value = 0;
    isLoading.value = false;

    print('NotificationController: Cleanup completed');
  }

  void _initializeNotificationSystem() {
    print('NotificationController: Initializing notification system');
    loadNotifications();
    _setupRealTimeListener();
  }

  @override
  void onClose() {
    _notificationsStream?.cancel();
    super.onClose();
  }

  void _setupRealTimeListener() {
    final user = AuthController.to.user.value;
    if (user != null) {
      print('Setting up real-time listener for user: ${user.uid}');
      // Listen for real-time notifications - simplified query to avoid index requirement
      _notificationsStream = FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        print(
            'Real-time notification update received - ${snapshot.docs.length} notifications');

        // Safety check - make sure user is still logged in
        if (AuthController.to.user.value == null) {
          print('User logged out during notification update, ignoring');
          return;
        }

        // Sort locally to avoid index requirement
        final sortedDocs = snapshot.docs.toList()
          ..sort((a, b) {
            final aTime = a.data()['timestamp'] as Timestamp?;
            final bTime = b.data()['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Descending order
          });

        notifications.value = sortedDocs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();

        print(
            'Updated notifications list - ${notifications.length} total notifications');
        _updateUnreadCount();
      }, onError: (error) {
        print('Error in real-time notification listener: $error');
        // If there's an error, try to clean up
        _cleanupOnLogout();
      });
    } else {
      print('No user available for real-time listener setup');
    }
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final user = AuthController.to.user.value;
      if (user != null) {
        final query = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .get();

        // Safety check - make sure user is still logged in after query
        if (AuthController.to.user.value == null) {
          print('User logged out during notification load, aborting');
          return;
        }

        // Sort locally to avoid index requirement
        final sortedDocs = query.docs.toList()
          ..sort((a, b) {
            final aTime = a.data()['timestamp'] as Timestamp?;
            final bTime = b.data()['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Descending order
          });

        notifications.value = sortedDocs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
        print('Loaded ${notifications.length} notifications');
        _updateUnreadCount();
      } else {
        print('No user available for loading notifications');
        notifications.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('Error loading notifications: $e');
      // Clear notifications on error
      notifications.clear();
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final user = AuthController.to.user.value;
      if (user != null) {
        // Update notification in Firestore
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notificationId)
            .update({'read': true});

        // Update local state
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(read: true);
          _updateUnreadCount();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = AuthController.to.user.value;
      if (user != null) {
        // Update all notifications in Firestore
        final batch = FirebaseFirestore.instance.batch();
        for (var notification in notifications) {
          if (!notification.read) {
            batch.update(
              FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(notification.id),
              {'read': true},
            );
          }
        }
        await batch.commit();

        // Update local state
        for (int i = 0; i < notifications.length; i++) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _updateUnreadCount() {
    final unreadNotifications = notifications.where((n) => !n.read).length;
    print('Updating unread count: $unreadNotifications unread notifications');
    unreadCount.value = unreadNotifications;
    print('Unread count updated to: ${unreadCount.value}');
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      type: type,
      additionalData: additionalData,
    );
  }

  Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    await _notificationService.sendNotificationToRole(
      role: role,
      title: title,
      body: body,
      type: type,
      additionalData: additionalData,
    );
  }

  // Test method to simulate sending a notification
  Future<void> testNotification() async {
    print('NotificationController: testNotification called');
    try {
      final user = AuthController.to.user.value;
      if (user != null) {
        print(
            'NotificationController: Sending test notification for user: ${user.uid}');

        final notificationData = {
          'userId': user.uid,
          'type': 'test_notification',
          'title': 'Test Notification',
          'body':
              'This is a test notification sent at ${DateTime.now().toString()}',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'data': {
            'test': true,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        };

        print('NotificationController: Adding notification to Firestore');
        await FirebaseFirestore.instance
            .collection('notifications')
            .add(notificationData);
        print('NotificationController: Test notification sent successfully');

        // Force refresh the notifications
        await loadNotifications();
        print('NotificationController: Notifications refreshed after test');
      } else {
        print(
            'NotificationController: No user available for test notification');
      }
    } catch (e) {
      print('NotificationController: Error sending test notification: $e');
    }
  }
}
