class AppNotification {
  final String id;
  final String userId;
  final String enquiryId;
  final String title;
  final String message;
  final String type; // enquiry_created, admin_response, booking_confirmed
  final bool isRead;
  final DateTime createdAt;
  final String? adminName;

  AppNotification({
    required this.id,
    required this.userId,
    required this.enquiryId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.adminName,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      enquiryId: json['enquiryId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'enquiry_created',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      adminName: json['adminName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'enquiryId': enquiryId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'adminName': adminName,
    };
  }
}
