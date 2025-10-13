# QR Menu App - Customer Side

A production-ready Flutter application for customers to scan QR codes and order food from restaurants.

## ✨ Features

### 📱 Core Functionality
- **QR Code Scanner**: Scan table QR codes to access restaurant menus
- **Digital Menu**: Browse categorized menu items with search functionality
- **Quick Order Bar**: One-tap ordering for popular items (Roti, Chai, Papad, etc.)
- **Shopping Cart**: Add items, manage quantities, and special instructions
- **Order Summary**: Detailed bill breakdown with taxes and service charges
- **Order Placement**: Complete checkout process with order confirmation

### 🎨 UI/UX Features
- **Responsive Design**: Works on phones, tablets, and web
- **Material Design 3**: Modern, clean interface with proper theming
- **Dark/Light Mode**: System-adaptive theme support
- **Smooth Animations**: Engaging micro-interactions and transitions
- **Professional Typography**: Google Fonts integration
- **Visual Indicators**: Veg/Non-veg, spicy, popular, and quick order badges

### 🚀 Production Ready
- **State Management**: Provider pattern for scalable state handling
- **Error Handling**: Comprehensive error states and user feedback
- **Performance Optimized**: Efficient rendering and memory management
- **Accessibility**: Proper semantics and contrast ratios
- **Cross-Platform**: iOS, Android, and Web support

## 🏗️ Technical Architecture

```
lib/
├── models/           # Data models with JSON serialization
├── providers/        # State management (Provider pattern)
├── screens/          # Main app screens
├── widgets/          # Reusable UI components
├── services/         # API services and mock data
└── utils/           # Themes, constants, and utilities
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (>=3.8.0)
- iOS development: Xcode 14+ (for iOS builds)
- Android development: Android SDK (for Android builds)

### Installation

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Generate model files**:
```bash
dart run build_runner build
```

3. **Run the app**:
```bash
flutter run
```

### Build for Production

**iOS**:
```bash
flutter build ios --release
```

**Android**:
```bash
flutter build apk --release
```

## 📖 Usage Guide

### For Customers

1. **Scan QR Code**: Point camera at table QR code or use "Demo Menu" for testing
2. **Browse Menu**: Use categories, search, and view detailed item information
3. **Quick Order**: Use the quick order bar for popular items like roti and chai
4. **Shopping Cart**: Customize quantities and add special instructions
5. **Place Order**: Review and confirm your order with estimated preparation time

### Quick Order Items
- **Butter Roti** (₹25) - Most popular bread item
- **Plain Roti** (₹20) - Traditional flatbread
- **Masala Chai** (₹15) - Popular tea option
- **Papad** (₹30) - Quick starter option

## 🎯 Key Features

### QR Scanner
- Camera permission handling
- Multiple QR format support (JSON, URL, simple text)
- Error handling and retry functionality
- Demo mode for testing

### Menu Display
- Category-based filtering
- Real-time search
- Item ratings and reviews
- Allergen information
- Preparation time estimates

### Cart Management
- Real-time price calculations
- Tax and service charge breakdown
- Special instructions per item
- Quantity management
- Order confirmation flow

## 🔧 Customization

### Adding Menu Items
Edit `lib/services/mock_data.dart` to add new items:

```dart
const MenuItemModel(
  id: 'item_001',
  name: 'New Item',
  price: 50.0,
  category: 'Category',
  isQuickOrder: true, // Add to quick order bar
),
```

### Modifying Colors
Edit `lib/utils/app_theme.dart`:

```dart
static const Color primary = Color(0xFFYourColor);
```

## 📱 Production Status

✅ **iOS Build**: Successfully builds for iOS devices
✅ **Android Support**: Full Android compatibility
✅ **State Management**: Provider pattern implementation
✅ **UI Components**: Production-ready widgets
✅ **Error Handling**: Comprehensive error states
✅ **Performance**: Optimized for smooth user experience

---

**Ready for Production Deployment!** 🚀
