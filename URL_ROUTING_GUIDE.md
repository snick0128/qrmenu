# URL Parameter-Based Routing Implementation

## Overview
This implementation enables URL-based navigation with restaurant and table validation using Firebase Firestore.

## URL Structure

### Format
```
/<restaurant_id>/<table_code>
```

### Examples
- `https://yourapp.com/demo_restaurant/TBL_1`
- `https://yourapp.com/my_hotel/TABLE_5`

## Implementation Flow

### 1. Full URL with Restaurant and Table Code
**URL Pattern:** `/:restaurantId/:tableCode`

#### Step 1: Validate Restaurant ID
- Checks if the restaurant document exists in the `restaurants` collection
- Retrieves the restaurant name from the `name` field

**If Invalid:**
- Shows error screen with message: "Invalid Restaurant ID. Please check your QR code and try again."
- Displays a user-friendly error page with option to return home

**If Valid:**
- Proceeds to Step 2

#### Step 2: Validate Table Code
- Checks if the table code exists in the `accessCodes` collection
- Verifies that `isActive` field is `true`

**If Invalid or Inactive:**
- Navigates to Manual Table Entry screen
- Pre-fills the restaurant information
- Shows restaurant name and icon
- Prompts user to manually enter valid table code

**If Valid:**
- Retrieves the `type` field (session type: 'dine_in' or 'parcel')
- Proceeds to Menu Screen with:
  - Restaurant name
  - Table code
  - Session type

### 2. Partial URL with Restaurant ID Only
**URL Pattern:** `/:restaurantId`

#### Flow
- Validates restaurant ID against Firebase
- If invalid: Shows error screen
- If valid: Shows manual table entry screen with restaurant info pre-filled

### 3. Root URL
**URL Pattern:** `/`

- Shows manual table entry screen
- No pre-filled information
- User must enter both restaurant ID and table code

## Files Modified

### 1. `/lib/main.dart`
**Changes:**
- Updated route parameters from `hotelId` to `restaurantId` for clarity
- Updated `tableNumber` to `tableCode` for consistency
- Added validation for restaurant existence before showing manual entry
- Enhanced error handling with user-friendly messages
- Added `isActive` check for table codes
- Removed deprecated `useHashUrlStrategy()`

**Key Functions:**
```dart
GoRoute(
  path: '/:restaurantId/:tableCode',
  builder: (context, state) {
    // Validates restaurant → Validates table → Shows appropriate screen
  },
)
```

### 2. `/lib/screens/manual_table_entry_screen.dart`
**Changes:**
- Updated constructor parameters:
  - `hotelId` → `restaurantId`
  - Added `restaurantName` parameter
- Enhanced UI to display restaurant information when available
- Added restaurant icon and name display
- Improved user messaging

**New Features:**
- Shows restaurant name prominently when navigating from invalid table code
- Provides context to user about which restaurant they're trying to access
- Better UX with visual feedback

### 3. `/lib/screens/error_screen.dart`
**Changes:**
- Complete redesign with better UX
- Added visual error icon
- Clear error messaging
- "Go to Home" button for easy navigation
- Responsive layout with proper spacing

## Firebase Collections Structure

### `restaurants` Collection
```json
{
  "demo_restaurant": {
    "name": "Demo Restaurant",
    "address": "123 Main St",
    "phone": "+1234567890",
    "logoUrl": "https://...",
    "isActive": true
  }
}
```

### `accessCodes` Collection
```json
{
  "TBL_1": {
    "type": "dine_in",
    "tableNumber": "Table 1",
    "isActive": true,
    "restaurantId": "demo_restaurant"
  }
}
```

## User Experience Scenarios

### Scenario 1: Valid Restaurant + Valid Table Code
**URL:** `/demo_restaurant/TBL_1`

1. ✅ Restaurant validated
2. ✅ Table code validated
3. → User sees menu screen immediately

### Scenario 2: Valid Restaurant + Invalid Table Code
**URL:** `/demo_restaurant/INVALID_CODE`

1. ✅ Restaurant validated
2. ❌ Table code not found
3. → User sees manual entry screen with restaurant info
4. User can enter correct table code
5. → Proceeds to menu

### Scenario 3: Invalid Restaurant + Any Table Code
**URL:** `/invalid_restaurant/TBL_1`

1. ❌ Restaurant not found
2. → User sees error screen
3. User can click "Go to Home" button
4. → Returns to manual entry screen

### Scenario 4: Valid Restaurant Only
**URL:** `/demo_restaurant`

1. ✅ Restaurant validated
2. → User sees manual entry screen with restaurant info
3. User enters table code
4. → Proceeds to menu

## Testing the Implementation

### Test Case 1: Complete Valid URL
```
URL: /demo_restaurant/TBL_1
Expected: Direct access to menu screen
```

### Test Case 2: Invalid Restaurant
```
URL: /fake_restaurant/TBL_1
Expected: Error screen with clear message
```

### Test Case 3: Valid Restaurant, Invalid Table
```
URL: /demo_restaurant/FAKE_TABLE
Expected: Manual entry screen with restaurant name shown
```

### Test Case 4: Restaurant Only
```
URL: /demo_restaurant
Expected: Manual entry screen with restaurant info
```

### Test Case 5: Root URL
```
URL: /
Expected: Manual entry screen with no pre-filled info
```

## Error Handling

### Restaurant Validation Errors
- **Missing Document:** Shows error screen
- **Network Error:** Loading indicator until resolved
- **Permission Denied:** Shows error screen

### Table Code Validation Errors
- **Missing Document:** Manual entry screen
- **Inactive Code:** Manual entry screen
- **Network Error:** Loading indicator until resolved

## Benefits of This Implementation

1. **Better UX:** Clear error messages and guided flow
2. **Validation:** Ensures data integrity before proceeding
3. **Flexibility:** Supports partial URLs and manual entry
4. **Error Recovery:** Users can manually enter correct codes
5. **SEO Friendly:** Clean URL structure
6. **Secure:** Validates all inputs against Firebase

## Future Enhancements

1. Add QR code generation for restaurant/table combinations
2. Implement analytics tracking for invalid access attempts
3. Add restaurant-specific theming
4. Cache validated restaurants for faster loading
5. Add deep linking support for mobile apps
