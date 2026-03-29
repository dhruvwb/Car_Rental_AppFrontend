import 'package:flutter/material.dart';
import 'dart:async';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'enquiry', 'success', 'info'
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  final StreamController<NotificationModel> _notificationStream =
      StreamController<NotificationModel>.broadcast();
  
  Timer? _pollTimer;

  List<NotificationModel> get notifications => _notifications;
  Stream<NotificationModel> get notificationStream =>
      _notificationStream.stream;
  
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Add a new notification
  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _notificationStream.add(notification);

    print('🔔 [Notification Added] $title - $message');

    // Auto-remove after 10 seconds if not manually cleared
    Future.delayed(const Duration(seconds: 10), () {
      if (_notifications.contains(notification)) {
        removeNotification(notification.id);
      }
    });

    notifyListeners();
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Start polling for new bookings/enquiries
  void startPolling(Function checkNewBookings, Function checkNewEnquiries) {
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await checkNewBookings();
      await checkNewEnquiries();
    });
    print('🔄 Notification polling started (every 15 seconds)');
  }

  /// Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    print('⏸ Notification polling stopped');
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _notificationStream.close();
    super.dispose();
  }

  /// Notify new booking
  void notifyNewBooking(String carName, String userName) {
    addNotification(
      title: '📅 New Booking',
      message: '$userName booked $carName',
      type: 'booking',
    );
  }

  /// Notify new enquiry
  void notifyNewEnquiry(String pickupLocation, String numCars) {
    addNotification(
      title: '💬 New Enquiry',
      message: 'Enquiry for $numCars car(s) at $pickupLocation',
      type: 'enquiry',
    );
  }

  /// Notify booking approved
  void notifyBookingApproved(String bookingId) {
    addNotification(
      title: '✅ Booking Confirmed',
      message: 'Booking $bookingId has been confirmed',
      type: 'success',
    );
  }

  /// Notify booking rejected
  void notifyBookingRejected(String bookingId) {
    addNotification(
      title: '❌ Booking Rejected',
      message: 'Booking $bookingId has been rejected',
      type: 'info',
    );
  }
}
