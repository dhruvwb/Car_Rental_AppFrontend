import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../providers/index.dart';
import '../services/enquiry_service.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({Key? key}) : super(key: key);

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EnquiryService _enquiryService;
  List<Enquiry> _enquiries = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _enquiryService = EnquiryService();
    _loadData();
  }

  void _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 'unknown';

    final enquiries = await _enquiryService.getUserEnquiries(userId);
    final notifications = await _enquiryService.getUserNotifications(userId);

    if (mounted) {
      setState(() {
        _enquiries = enquiries;
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return '#FFA500';
      case 'Responded':
        return '#0F67B1';
      case 'Confirmed':
        return '#10B981';
      case 'Completed':
        return '#6B7280';
      case 'Cancelled':
        return '#EF4444';
      default:
        return '#6B7280';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Enquiries',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0F67B1),
          unselectedLabelColor: Color(0xFF9CA3AF),
          indicatorColor: Color(0xFF0F67B1),
          tabs: [
            Tab(text: 'Enquiries'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Enquiries Tab
                _buildEnquiriesTab(),
                // Notifications Tab
                _buildNotificationsTab(),
              ],
            ),
    );
  }

  Widget _buildEnquiriesTab() {
    if (_enquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'No Enquiries Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send an enquiry for your transport needs',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _enquiries.length,
      itemBuilder: (context, index) {
        final enquiry = _enquiries[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enquiry ID: ${enquiry.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          _getStatusColor(enquiry.status).replaceFirst('#', '0xff'),
                        ),
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      enquiry.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(
                          int.parse(
                            _getStatusColor(enquiry.status)
                                .replaceFirst('#', '0xff'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Locations
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${enquiry.pickupLocation} → ${enquiry.dropLocation}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Date Time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${enquiry.pickupDateTime.day}/${enquiry.pickupDateTime.month}/${enquiry.pickupDateTime.year} ${enquiry.pickupDateTime.hour}:${enquiry.pickupDateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),

              // Contact Info
              Text(
                enquiry.contactName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${enquiry.contactPhone} • ${enquiry.contactEmail}',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),

              // Admin Response if available
              if (enquiry.adminResponse != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Response',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        enquiry.adminResponse!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[900],
                        ),
                      ),
                      if (enquiry.quotedPrice != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Quoted Price: ₹${enquiry.quotedPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return GestureDetector(
          onTap: () async {
            await _enquiryService.markNotificationAsRead(notification.id);
            _loadData();
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.grey[50]
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? Color(0xFFE5E7EB)
                    : Color(0xFF0F67B1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF0F67B1),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
