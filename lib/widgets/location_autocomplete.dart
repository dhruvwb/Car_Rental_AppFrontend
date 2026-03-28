import 'package:flutter/material.dart';

class LocationAutoComplete extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Function(String) onLocationSelected;
  final List<String> suggestions;

  const LocationAutoComplete({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onLocationSelected,
    this.suggestions = const [],
  }) : super(key: key);

  @override
  State<LocationAutoComplete> createState() => _LocationAutoCompleteState();
}

class _LocationAutoCompleteState extends State<LocationAutoComplete> {
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  // Sample location data
  static const List<String> allLocations = [
    'Delhi - 28.6139° N, 77.2090° E',
    'Mumbai - 19.0760° N, 72.8777° E',
    'Bangalore - 12.9716° N, 77.5946° E',
    'Hyderabad - 17.3850° N, 78.4867° E',
    'Chennai - 13.0827° N, 80.2707° E',
    'Pune - 18.5204° N, 73.8567° E',
    'Kolkata - 22.5726° N, 88.3639° E',
    'Ahmedabad - 23.0225° N, 72.5714° E',
    'Jaipur - 26.9124° N, 75.7873° E',
    'Lucknow - 26.8467° N, 80.9462° E',
    'New Delhi Airport - 28.5562° N, 77.1000° E',
    'Nariman Point Mumbai - 18.9606° N, 72.8211° E',
    'Indiranagar Bangalore - 12.9716° N, 77.6412° E',
    'Gachibowli Hyderabad - 17.4451° N, 78.3480° E',
    'Marina Beach Chennai - 13.0499° N, 80.2824° E',
  ];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = allLocations;
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = allLocations;
        _showSuggestions = false;
      } else {
        _filteredSuggestions = allLocations
            .where((location) =>
                location.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showSuggestions = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      _filterLocations('');
                    },
                    child: const Icon(Icons.clear),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F67B1), width: 2),
            ),
          ),
          onChanged: (value) {
            _filterLocations(value);
          },
          onTap: () {
            setState(() => _showSuggestions = true);
          },
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:
                  _filteredSuggestions.length > 5 ? 5 : _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return Material(
                  child: InkWell(
                    onTap: () {
                      widget.controller.text = suggestion;
                      widget.onLocationSelected(suggestion);
                      setState(() => _showSuggestions = false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Color(0xFF0F67B1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.split(' - ')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                if (suggestion.contains(' - '))
                                  Text(
                                    suggestion.split(' - ')[1],
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
