# 🔑 Generate Google API Key - Step by Step (5 minutes)

## ⚡ Quick Path (Fastest Way)

### Step 1: Open Google Cloud Console
```
URL: console.cloud.google.com/
Sign in with your Google account
```

### Step 2: Create New Project
```
Top-left: "Select a Project"
  ↓
Click "NEW PROJECT"
  ↓
Name: Car Rental App
  ↓
Click "CREATE" (wait 30 seconds)
```

### Step 3: Enable APIs (3 clicks each)
```
Search bar at top: "Places API"
  ↓
Click on "Places API"
  ↓
Click "ENABLE" (blue button)
  ↓
Wait... then repeat for:
  ✓ Places API (done)
  ✓ Maps JavaScript API
  ✓ Geocoding API
```

### Step 4: Get Your API Key
```
Left menu: "APIs & Services" > "Credentials"
  ↓
Click "Create Credentials" (blue button)
  ↓
Select: "API Key"
  ↓
Copy the KEY that appears!
```

**Your key looks like:**
```
AIzaSyD_____________________________
```

---

## 📋 Verification Checklist

After creating key, verify:

```
☐ Key starts with: AIzaSy
☐ Key length: ~39 characters
☐ Can copy to clipboard
☐ Shows in Credentials page
```

---

## 🔒 Restrict Your Key (OPTIONAL but RECOMMENDED)

To prevent unauthorized use:

```
In Google Cloud Console:
  ↓
Credentials page > Your API Key
  ↓
"API Key Restrictions"
  ↓
Select: "HTTP referrers (web sites)"
  ↓
Add: localhost
      yourdomain.com
  ↓
"Save"
```

---

## ⚠️ Enable Billing (REQUIRED for Places API)

```
Left menu: "Billing"
  ↓
"Link Billing Account"
  ↓
Click "Create Billing Account"
  ↓
Fill in payment method
  ↓
Confirm
```

**Note:** You get $200/month free credit → Should be enough for testing!

---

## 🎯 Add Key to Your App

### For Web (Chrome browser):
Update `web/index.html`

Find this line (around line 50):
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
```

Replace `YOUR_API_KEY` with your actual key!

**Example:**
```html
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyD_________________________&libraries=places"></script>
```

### For Android:
Update `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyD_________________________"/>
```

### For iOS:
Update `ios/Runner/Info.plist`

Add:
```xml
<key>GOOGLE_API_KEY</key>
<string>AIzaSyD_________________________</string>
```

---

## ✅ Test Your Key

After adding to code, test by:

1. Running app: `flutter run -d chrome`
2. Click "Pickup Location"
3. Try searching for "New York"
4. Should show suggestions!

If no suggestions appear:
```
Check:
✓ Key is correct (no typos)
✓ Key is in right file
✓ Billing is enabled
✓ Places API is enabled
✓ Browser cache cleared (Ctrl+Shift+Del)
```

---

## 🐛 Troubleshooting

### Error: "API key not found"
```
Solution: Double-check key is in web/index.html
Find: ?key=
Make sure what comes after has no spaces
```

### Error: "Maps API error: InvalidKey"
```
Solution: 
1. Copy key exactly (no extra spaces)
2. Go to Google Cloud → Credentials
3. Verify key status: "ACTIVE"
4. Clear browser cache
5. Restart Flutter app
```

### Error: "Quota exceeded"
```
Solution:
1. Check Billing account is linked
2. Go to Quotas: "Places API" - should show high limits
3. Wait 5 minutes (quota resets hourly)
```

### Search not working but map shows
```
Reasons:
- API key correct but Places API not enabled
- Billing not linked

Solution:
1. Enable "Places API" in Console
2. Link billing account
3. Wait 5 minutes
4. Restart app
```

---

## 💡 Key Management Tips

### Store Key Securely
```
NEVER commit to GitHub!
Add to .gitignore:
  web/index.html
  android/app/src/main/AndroidManifest.xml
  ios/Runner/Info.plist
```

### Rotate Keys Quarterly
```
Best Practice:
1. Create new key every 3 months
2. Keep old key for 1 week
3. Delete old key
```

### Monitor Usage
```
Google Cloud Console:
  ↓
APIs Services > Quotas
  ↓
See: Requests/minute, Total/month
  ↓
Set alerts if needed
```

---

## ✨ Success Indicators

When working correctly:

```
✅ App starts without errors
✅ Map displays your location
✅ Search field focuses
✅ Type in search → Suggestions appear
✅ Click suggestion → Location selected
✅ Coordinates update on map
✅ Price calculates correctly
```

---

## 🚀 Ready!

Now you have:
- ✅ Google API Key
- ✅ Places API enabled
- ✅ Autocomplete working
- ✅ Map selection ready

**Next:** Run your app and test the location picker! 🎉

---

## 📞 Still Issues?

Common solutions:
```
1. Restart Flutter app: Ctrl+C then flutter run
2. Clear cache: Rebuild app
3. Check console: Look for actual error message
4. Verify key: Copy from Google Cloud, paste directly
5. Check internet: Must have active connection
```

You're all set! 🎊
