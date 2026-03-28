import '../models/index.dart';

class EnquiryService {
  static final List<Enquiry> _enquiries = [];
  static final List<AppNotification> _notifications = [];

  // Create a new enquiry
  Future<Enquiry?> createEnquiry({
    required String userId,
    required String pickupLocation,
    required String dropLocation,
    required DateTime pickupDateTime,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    String? additionalNotes,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final enquiry = Enquiry(
      id: 'ENQ-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      pickupDateTime: pickupDateTime,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      additionalNotes: additionalNotes,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    _enquiries.add(enquiry);

    // Create notification
    final notification = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      enquiryId: enquiry.id,
      title: 'Enquiry Submitted',
      message: 'Your enquiry from $pickupLocation to $dropLocation has been submitted.',
      type: 'enquiry_created',
      isRead: false,
      createdAt: DateTime.now(),
    );

    _notifications.add(notification);

    return enquiry;
  }

  // Get all enquiries for a user
  Future<List<Enquiry>> getUserEnquiries(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _enquiries.where((e) => e.userId == userId).toList();
  }

  // Get enquiry by ID
  Future<Enquiry?> getEnquiryById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _enquiries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Admin: Get all enquiries
  Future<List<Enquiry>> getAllEnquiries() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _enquiries;
  }

  // Admin: Respond to enquiry
  Future<bool> respondToEnquiry({
    required String enquiryId,
    required String response,
    required double quotedPrice,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final index = _enquiries.indexWhere((e) => e.id == enquiryId);
      if (index != -1) {
        final enquiry = _enquiries[index];
        _enquiries[index] = Enquiry(
          id: enquiry.id,
          userId: enquiry.userId,
          pickupLocation: enquiry.pickupLocation,
          dropLocation: enquiry.dropLocation,
          pickupDateTime: enquiry.pickupDateTime,
          contactName: enquiry.contactName,
          contactPhone: enquiry.contactPhone,
          contactEmail: enquiry.contactEmail,
          additionalNotes: enquiry.additionalNotes,
          status: 'Responded',
          createdAt: enquiry.createdAt,
          adminResponse: response,
          respondedAt: DateTime.now(),
          quotedPrice: quotedPrice,
        );

        // Create notification for response
        final notification = AppNotification(
          id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
          userId: enquiry.userId,
          enquiryId: enquiryId,
          title: 'Admin Response',
          message: 'Admin has responded to your enquiry. Quoted price: ₹$quotedPrice',
          type: 'admin_response',
          isRead: false,
          createdAt: DateTime.now(),
        );

        _notifications.add(notification);
        return true;
      }
      return false;
    } catch (e) {
      print('Error responding to enquiry: $e');
      return false;
    }
  }

  // Get all notifications for a user
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _notifications.where((n) => n.userId == userId).toList();
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = AppNotification(
          id: notification.id,
          userId: notification.userId,
          enquiryId: notification.enquiryId,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
          adminName: notification.adminName,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Cancel enquiry
  Future<bool> cancelEnquiry(String enquiryId) async {
    await Future.delayed(Duration(milliseconds: 200));

    try {
      final index = _enquiries.indexWhere((e) => e.id == enquiryId);
      if (index != -1) {
        final enquiry = _enquiries[index];
        _enquiries[index] = Enquiry(
          id: enquiry.id,
          userId: enquiry.userId,
          pickupLocation: enquiry.pickupLocation,
          dropLocation: enquiry.dropLocation,
          pickupDateTime: enquiry.pickupDateTime,
          contactName: enquiry.contactName,
          contactPhone: enquiry.contactPhone,
          contactEmail: enquiry.contactEmail,
          additionalNotes: enquiry.additionalNotes,
          status: 'Cancelled',
          createdAt: enquiry.createdAt,
          adminResponse: enquiry.adminResponse,
          respondedAt: enquiry.respondedAt,
          quotedPrice: enquiry.quotedPrice,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
