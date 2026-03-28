# 🔍 Google Places Autocomplete Integration Guide

## Overview
This guide shows how to add **real-time Google Places autocomplete** to your app with:
- ✅ Live location suggestions as user types
- ✅ Full address predictions
- ✅ Place details (coordinates, address)
- ✅ Works online with Google's database

---

## Step 1: Install Required Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  google_places_flutter: ^2.0.0
  google_maps_flutter: ^2.2.0
  uuid: ^3.0.0
```

Run: `flutter pub get`

---

## Step 2: Create Google Places Service

Create file: `lib/services/google_places_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class GooglePlacesService {
  final String apiKey = 'YOUR_API_KEY_HERE'; // Replace with your key
  final String sessionToken = const Uuid().v4();

  // Get autocomplete predictions
  Future<List<PlacePrediction>> getAutocompletePredictions(
      String input, String sessionId) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$input'
          '&key=$apiKey'
          '&sessiontoken=$sessionId'
          '&components=country:us'; // Optional: restrict to country

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final predictions = (json['predictions'] as List)
            .map((p) => PlacePrediction.fromJson(p))
            .toList();
        return predictions;
      } else {
        throw Exception('Failed to fetch predictions');
      }
    } catch (e) {
      print('Autocomplete error: $e');
      return [];
    }
  }

  // Get place details from place ID
  Future<PlaceDetails?> getPlaceDetails(
      String placeId, String sessionId) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=formatted_address,geometry,name'
          '&key=$apiKey'
          '&sessiontoken=$sessionId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PlaceDetails.fromJson(json['result']);
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      print('Place details error: $e');
      return null;
    }
  }
}

// Models
class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'],
      mainText: json['structured_formatting']['main_text'] ?? '',
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
      fullText: json['description'] ?? '',
    );
  }
}

class PlaceDetails {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      latitude: json['geometry']['location']['lat'],
      longitude: json['geometry']['location']['lng'],
    );
  }
}
```

---

## Step 3: Update Location Selection Screen

Create enhanced version with real autocomplete:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_places_service.dart';

class LocationSelectionWithAutocomplete extends StatefulWidget {
  // Implementation below
}

class _LocationSelectionWithAutocompleteState
    extends State<LocationSelectionWithAutocomplete> {
  
  final GooglePlacesService _placesService = GooglePlacesService();
  final TextEditingController _searchController = TextEditingController();
  List<PlacePrediction> _predictions = [];
  bool _showPredictions = false;
  String _sessionToken = '';

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
    } else {
      final predictions =
          await _placesService.getAutocompletePredictions(value, _sessionToken);
      setState(() {
        _predictions = predictions;
        _showPredictions = true;
      });
    }
  }

  void _selectPrediction(PlacePrediction prediction) async {
    // Get full details
    final details =
        await _placesService.getPlaceDetails(prediction.placeId, _sessionToken);

    if (details != null) {
      // Use the details to set location
      setState(() {
        _searchController.text = details.address;
        _showPredictions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Predictions List
          if (_showPredictions && _predictions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(prediction.mainText),
                    subtitle: Text(prediction.secondaryText),
                    onTap: () => _selectPrediction(prediction),
                  );
                },
              ),
            ),

          // Map View (if no search)
          if (!_showPredictions)
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(40.7128, -74.0060), // Default: NYC
                  zoom: 12,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

---

## Step 4: Add Your API Key

### Option A: Web (Recommended for now)
Update `web/index.html`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyD...&libraries=places"></script>
```

### Option B: Android
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyD..."/>
```

### Option C: iOS
Update `ios/Runner/Info.plist`:
```xml
<key>GOOGLE_API_KEY</key>
<string>AIzaSyD...</string>
```

---

## Step 5: Test Autocomplete

Try searching for:
- "New York" → Should show: New York, NY, USA
- "Times" → Should show: Times Square, Park Ave, etc.
- "San Francis" → Should show: San Francisco suggestions

---

## 💡 Pro Tips

### 1. Restrict to Countries
```dart
'&components=country:us,country:ca' // US and Canada only
```

### 2. Restrict to Cities
```dart
'&types=cities' // Cities only
'&types=regions' // States/provinces
```

### 3. Use Session Tokens (Save $$)
Session tokens group related searches for billing:
- Multiple searches = 1 request charge
- Final selection = 1 place details charge
Total: ~2x cheaper!

### 4. Handle Errors Gracefully
```dart
catch (e) {
  print('Search error: $e');
  // Fallback to predefined locations
  setState(() {
    _predictions = _fallbackLocations;
  });
}
```

---

## 🎯 Expected Output

### User types "New":
```
📍 New York, New York, USA
   40.7128° N, 74.0060° W

📍 New Jersey, United States
   40.2989° N, 74.5210° W

📍 Newark, New Jersey, USA
   40.7357° N, 74.1724° W
```

### User selects "New York":
```
Location selected!
Address: New York, NY 10007, USA
Coords: 40.7128, -74.0060
```

---

## 📊 Pricing

Google Places API Pricing:
- Autocomplete Request: $0.017 per request
- Place Details: $0.017 per request
- Session Token: Groups searches together

**Example:**
- 100 autocomplete searches + 1 selection
- With session token: 2 billable requests = $0.034
- Without session token: 101 requests = $1.71

---

## ✅ Checklist

- [ ] Google Cloud API key created
- [ ] Places API enabled
- [ ] Geocoding API enabled
- [ ] API key added to `web/index.html`
- [ ] Android API key configured
- [ ] iOS API key configured
- [ ] Billing account linked
- [ ] Testing autocomplete working

---

## 🚀 Result

Your app will now have:
- ✅ Real-time autocomplete suggestions
- ✅ Interactive map to select locations
- ✅ Full address details with coordinates
- ✅ Search by city, street, or place name
- ✅ Worldwide location database

**You're ready to deploy!**
