# 🗺️ Google Places API Setup Guide

## Step 1: Generate API Key (5 minutes)

### 1.1 Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Sign in with your account

### 1.2 Create or Select a Project
```
Click "Select a Project" (top-left) → "NEW PROJECT"
Project name: "Car Rental App"
Click "CREATE"
```

### 1.3 Enable Required APIs
```
In console, search for:
1. "Places API" → Enable
2. "Maps JavaScript API" → Enable
3. "Geocoding API" → Enable
```

### 1.4 Create API Key
```
Dashboard → "Create Credentials"
→ "API Key"
→ Copy the generated key

Example key format:
AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 1.5 Restrict API Key (Optional but Recommended)
```
In API Key settings:
- Application restrictions: "HTTP referrers (web sites)"
- Add domain: localhost
- API restrictions: Select only Places, Maps, Geocoding
```

---

## Step 2: Add to Flutter App

### 2.1 Update `pubspec.yaml`
```yaml
dependencies:
  google_maps_flutter: ^2.2.0
  google_maps_flutter_web: ^0.3.0
  google_places_flutter: ^2.0.0  # For autocomplete
  google_places: ^2.0.8
```

Run: `flutter pub get`

### 2.2 Add Web API Key - Update `web/index.html`
```html
<script>
  window.flutterWebRenderer = "canvaskit";
</script>

<!-- Add this: -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>

<script src="main.dart.js" type="application/javascript"></script>
```

Replace `YOUR_API_KEY` with your actual key!

### 2.3 Update Android - `android/app/src/main/AndroidManifest.xml`
```xml
<manifest ...>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_API_KEY"/>
  </application>
</manifest>
```

### 2.4 Update iOS - `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show nearby car rentals</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to show nearby car rentals</string>
```

---

## Step 3: Enable Billing (Required for Places API)

```
Google Cloud Console → Billing
→ Link a billing account
→ Enable for your project

Note: Free tier gives $200/month credit
- Most requests: $0.00 after free tier
- Autocomplete: ~$0.017 per request
```

---

## ✅ You're Ready!
Once these steps are done, the autocomplete and map features will work perfectly!
