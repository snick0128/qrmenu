# Quick Testing Guide

## Pre-requisites

Before testing, ensure your Firebase Firestore has the following structure:

### 1. Create a Restaurant Document
Collection: `restaurants`
Document ID: `demo_restaurant`

```json
{
  "name": "Demo Restaurant",
  "address": "123 Main Street",
  "phone": "+1234567890",
  "logoUrl": "https://example.com/logo.png",
  "isActive": true,
  "settings": {}
}
```

### 2. Create Access Code Documents
Collection: `accessCodes`

#### Document ID: `TBL_1`
```json
{
  "type": "dine_in",
  "tableNumber": "Table 1",
  "isActive": true,
  "restaurantId": "demo_restaurant"
}
```

#### Document ID: `TBL_2`
```json
{
  "type": "dine_in",
  "tableNumber": "Table 2",
  "isActive": false,
  "restaurantId": "demo_restaurant"
}
```

#### Document ID: `PARCEL_01`
```json
{
  "type": "parcel",
  "tableNumber": null,
  "isActive": true,
  "restaurantId": "demo_restaurant"
}
```

## Test Scenarios

### ✅ Test 1: Valid Restaurant + Valid Active Table
**URL:** `http://localhost:PORT/demo_restaurant/TBL_1`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Validates restaurant exists
- ✓ Validates table code exists and is active
- ✓ Redirects to Menu Screen
- ✓ Menu displays "Demo Restaurant" in header
- ✓ Menu displays "TBL_1" as table number
- ✓ Session type is "dine_in"

---

### ✅ Test 2: Valid Restaurant + Inactive Table
**URL:** `http://localhost:PORT/demo_restaurant/TBL_2`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Validates restaurant exists
- ✓ Detects table code is inactive
- ✓ Shows Manual Table Entry Screen
- ✓ Displays "Demo Restaurant" with restaurant icon
- ✓ Restaurant ID field is pre-filled and disabled
- ✓ User can enter a valid table code

---

### ✅ Test 3: Valid Restaurant + Non-existent Table
**URL:** `http://localhost:PORT/demo_restaurant/FAKE_TABLE`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Validates restaurant exists
- ✓ Table code not found in Firebase
- ✓ Shows Manual Table Entry Screen
- ✓ Displays "Demo Restaurant" with restaurant icon
- ✓ Shows message "Please enter your table code"
- ✓ User can manually enter correct code

---

### ❌ Test 4: Invalid Restaurant + Any Table
**URL:** `http://localhost:PORT/fake_restaurant/TBL_1`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Restaurant not found
- ✓ Shows Error Screen
- ✓ Displays error icon (red)
- ✓ Shows title "Oops!"
- ✓ Shows message "Invalid Restaurant ID. Please check your QR code and try again."
- ✓ "Go to Home" button navigates to root URL

---

### ✅ Test 5: Valid Restaurant Only (No Table Code)
**URL:** `http://localhost:PORT/demo_restaurant`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Validates restaurant exists
- ✓ Shows Manual Table Entry Screen
- ✓ Displays "Demo Restaurant" with restaurant icon
- ✓ Restaurant ID field is pre-filled
- ✓ User enters table code and proceeds

---

### ✅ Test 6: Root URL (No Parameters)
**URL:** `http://localhost:PORT/`

**Expected Result:**
- ✓ Shows Manual Table Entry Screen immediately
- ✓ Both Restaurant ID and Table Code fields are empty
- ✓ User can enter both values
- ✓ No pre-filled information

---

### ✅ Test 7: Parcel Order Type
**URL:** `http://localhost:PORT/demo_restaurant/PARCEL_01`

**Expected Result:**
- ✓ Shows loading indicator briefly
- ✓ Validates restaurant exists
- ✓ Validates access code exists and is active
- ✓ Redirects to Menu Screen
- ✓ Session type is "parcel" (not "dine_in")
- ✓ Different UI behavior for parcel orders

---

## Manual Testing Checklist

### Before Starting
- [ ] Firebase project is configured
- [ ] `demo_restaurant` document exists in `restaurants` collection
- [ ] Multiple access codes exist in `accessCodes` collection
- [ ] Flutter app is running (`flutter run -d web` or on device)

### Test Valid Flows
- [ ] Test 1: Valid restaurant + valid table
- [ ] Test 5: Valid restaurant only
- [ ] Test 6: Root URL
- [ ] Test 7: Parcel order type

### Test Error Handling
- [ ] Test 2: Inactive table code
- [ ] Test 3: Non-existent table
- [ ] Test 4: Invalid restaurant

### Test Navigation
- [ ] Error screen "Go to Home" button works
- [ ] Manual entry screen navigation works
- [ ] Back button behavior is correct
- [ ] Deep links work on mobile devices

### Test UI/UX
- [ ] Loading indicators show during Firebase queries
- [ ] Restaurant name displays correctly
- [ ] Table code displays correctly
- [ ] Error messages are user-friendly
- [ ] Icons and styling are consistent

## Testing with Flutter DevTools

### 1. Start Your App
```bash
flutter run -d chrome --web-port=8080
```

### 2. Open DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 3. Monitor Network Requests
- Open DevTools Network tab
- Watch Firebase Firestore queries
- Verify correct documents are queried

### 4. Check Console Logs
Look for these debug prints:
- "Firebase Core initialized successfully"
- "FirebaseService initialized successfully"
- Restaurant document data
- Table code validation results

## Firebase Console Verification

### Check Restaurant Document
1. Open Firebase Console
2. Navigate to Firestore Database
3. Open `restaurants` collection
4. Verify `demo_restaurant` document exists
5. Check `name` field has correct value

### Check Access Codes
1. Open `accessCodes` collection
2. Verify documents: TBL_1, TBL_2, PARCEL_01
3. Check `isActive` field values
4. Verify `type` field is correct

## Troubleshooting

### Issue: "Invalid Restaurant ID" for valid restaurant
**Solution:**
- Check Firebase project configuration
- Verify `google-services.json` / `GoogleService-Info.plist` are correct
- Check Firestore rules allow read access
- Verify restaurant document ID matches URL exactly (case-sensitive)

### Issue: Loading indicator never stops
**Solution:**
- Check network connection
- Verify Firebase is initialized
- Check browser console for errors
- Verify Firestore security rules

### Issue: Manual entry doesn't work
**Solution:**
- Check `go_router` version compatibility
- Verify navigation context is correct
- Check for route conflicts

### Issue: Menu screen doesn't load
**Solution:**
- Verify MenuScreen parameters are correct
- Check MenuProvider initialization
- Verify menu items exist in Firebase

## Expected Firebase Queries

### For URL: `/demo_restaurant/TBL_1`
1. Query: `restaurants.doc('demo_restaurant').get()`
2. Query: `accessCodes.doc('TBL_1').get()`
3. Total: 2 document reads

### For URL: `/fake_restaurant/TBL_1`
1. Query: `restaurants.doc('fake_restaurant').get()`
2. Total: 1 document read (stops at error)

### For URL: `/demo_restaurant`
1. Query: `restaurants.doc('demo_restaurant').get()`
2. Total: 1 document read

## Performance Expectations

- Initial load: < 1 second (with good connection)
- Restaurant validation: < 300ms
- Table code validation: < 300ms
- Total validation time: < 600ms
- Error display: Immediate after validation

## Next Steps After Testing

1. ✅ All tests pass → Deploy to production
2. ❌ Some tests fail → Review error logs and fix issues
3. 🔄 Inconsistent behavior → Check Firebase rules and data structure
4. 📊 Monitor performance → Use Firebase Performance Monitoring

## Production Checklist

Before going live:
- [ ] Test all URL patterns
- [ ] Verify error handling
- [ ] Check mobile responsiveness
- [ ] Test deep linking
- [ ] Verify SEO meta tags
- [ ] Test QR code scanning
- [ ] Load test with multiple concurrent users
- [ ] Set up Firebase security rules
- [ ] Enable Firebase Analytics
- [ ] Configure custom domain
