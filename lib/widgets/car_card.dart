import 'package:flutter/material.dart';
import '../models/index.dart';

class CarCard extends StatefulWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const CarCard({
    Key? key,
    required this.car,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(_isHovered ? 0.12 : 0.06),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Image & Favorite Button
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFFF3F4F6),
                            gradient: LinearGradient(
                              colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 100,
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: widget.onFavorite,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF000000).withOpacity(0.1),
                                    blurRadius: 8,
                              ),
                                ],
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: widget.isFavorite ? Color(0xFFEF4444) : Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.car.type,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF0F67B1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Car Name & Model
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.car.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.car.model,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${widget.car.dailyRate.toStringAsFixed(0)}/day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F67B1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFFCD34D), size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${widget.car.rating}',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827)),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${widget.car.reviews} reviews',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Features Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureRow(Icons.badge, '${widget.car.seats} seats'),
                        ),
                        Expanded(
                          child: _buildFeatureRow(Icons.luggage, '${widget.car.luggage}L'),
                        ),
                        Expanded(
                          child: _buildFeatureRow(
                            Icons.settings,
                            widget.car.transmission.split(' ')[0],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0F67B1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Color(0xFF9CA3AF)),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
