import '../models/index.dart';
import '../utils/http_client_service.dart';
import '../utils/api_constants.dart';

class EnquiryService {
  static final EnquiryService _instance = EnquiryService._internal();
  final _httpClient = HttpClientService();
  static final List<Enquiry> _enquiries = [];
  static final List<AppNotification> _notifications = [];

  factory EnquiryService() {
    return _instance;
  }

  EnquiryService._internal();

  // Convert API response to Enquiry object
  Enquiry _mapToEnquiry(Map<String, dynamic> data) {
    return Enquiry(
      id: data['id'].toString(),
      userId: data['user_email'] ?? '',
      pickupLocation: data['pickup_location'] ?? '',
      dropLocation: data['drop_location'] ?? '',
      pickupDateTime: DateTime.parse(data['pickup_datetime'] ?? DateTime.now().toIso8601String()),
      contactName: data['contact_name'] ?? '',
      contactPhone: data['contact_phone'] ?? '',
      contactEmail: data['contact_email'] ?? '',
      additionalNotes: data['additional_notes'],
      status: data['status'] ?? 'Pending',
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      adminResponse: data['admin_response'],
      respondedAt: data['responded_at'] != null ? DateTime.parse(data['responded_at']) : null,
      quotedPrice: (data['quoted_price'] ?? 0.0).toDouble(),
    );
  }

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
    int? numPeople,
    int? numCars,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.createEnquiryEndpoint,
        {
          'pickup_location': pickupLocation,
          'drop_location': dropLocation,
          'pickup_datetime': pickupDateTime.toIso8601String(),
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
          'additional_notes': additionalNotes,
          'num_people': numPeople ?? 1,
          'num_cars': numCars ?? 1,
        },
        includeAuth: true,
      );

      final enquiry = _mapToEnquiry(response as Map<String, dynamic>);
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
    } catch (e) {
      print('Error creating enquiry: $e');
      rethrow;
    }
  }

  // Get all enquiries for a user
  Future<List<Enquiry>> getUserEnquiries(String userId) async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getUserEnquiriesEndpoint,
        includeAuth: true,
      );

      final List<dynamic> enquiriesList = response as List<dynamic>;
      _enquiries.clear();
      
      final enquiries = enquiriesList.map((item) {
        final enquiry = _mapToEnquiry(item as Map<String, dynamic>);
        _enquiries.add(enquiry);
        return enquiry;
      }).toList();

      return enquiries;
    } catch (e) {
      print('Error fetching user enquiries: $e');
      // Return cached enquiries if available
      return _enquiries.where((e) => e.userId == userId).toList();
    }
  }

  // Get enquiry by ID
  Future<Enquiry?> getEnquiryById(String id) async {
    try {
      final response = await _httpClient.get(
        '${ApiConstants.getEnquiryByIdEndpoint}/$id',
        includeAuth: true,
      );

      final enquiry = _mapToEnquiry(response as Map<String, dynamic>);
      return enquiry;
    } catch (e) {
      print('Error fetching enquiry: $e');
      try {
        return _enquiries.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Admin: Get all enquiries
  Future<List<Enquiry>> getAllEnquiries() async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getAllEnquiriesAdminEndpoint,
        includeAuth: true,
      );

      final List<dynamic> enquiriesList = response as List<dynamic>;
      final allEnquiries = enquiriesList.map((item) {
        return _mapToEnquiry(item as Map<String, dynamic>);
      }).toList();

      return allEnquiries;
    } catch (e) {
      print('Error fetching all enquiries: $e');
      return [];
    }
  }

  // Admin: Respond to enquiry
  Future<bool> respondToEnquiry({
    required String enquiryId,
    required String response,
    required double quotedPrice,
  }) async {
    try {
      await _httpClient.post(
        '${ApiConstants.respondToEnquiryEndpoint}/$enquiryId/respond',
        {
          'adminResponse': response,
          'quotedPrice': quotedPrice,
        },
        includeAuth: true,
      );

      // Update local cache
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
        }
      } catch (e) {
        print('Error updating local cache: $e');
      }

      return true;
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
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
