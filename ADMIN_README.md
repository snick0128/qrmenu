# QR Menu Admin Dashboard

A comprehensive admin dashboard for the QR Menu restaurant management system built with Flutter and Firebase.

## 🚀 Features

### 1. 🏠 Dashboard Screen
- **Live Sales Summary**: Real-time analytics with animated cards
- **Key Metrics**: Total Orders, Total Sales (₹), Ongoing Orders, Completed Orders
- **Date Filters**: Today, Week, Month view options
- **Quick Actions**: Direct navigation to Tables, Orders, and Menu management
- **Recent Activity Feed**: Live updates of restaurant operations

### 2. 🍽️ Tables Overview
- **Grid Layout**: Visual representation of all restaurant tables
- **Real-time Status Updates**: Vacant 🟢, Reserved 🟡, Occupied 🔴, Cleaning 🔵
- **Table Management**: Easy status updates with long-press actions
- **Session Tracking**: Current session ID and running totals
- **Capacity Display**: Number of seats per table

### 3. 📋 Table Detail Page
- **Session Information**: Table name, session ID, customer type, start time
- **Real-time Item Tracking**: Live sync of ordered items with status
- **Item Status Management**: Mark items as Pending → Preparing → Served
- **Admin Item Addition**: Counter staff can add items with "Added by Counter" labels
- **Bill Summary**: Subtotal, tax calculation (18% GST), and total amount
- **Action Buttons**: Generate Bill, Mark as Preparing/Served, End Session

### 4. 💰 Billing & Payment System
- **Professional Invoice Generation**: Restaurant header, item details, tax breakdown
- **Payment Methods**: Cash at Counter / Online Payment options
- **Tax Calculation**: Automatic CGST (9%) and SGST (9%) computation
- **Payment Processing**: Animated confirmation with success feedback
- **Session Closure**: Automatic table release after payment

### 5. 📦 Orders Section
- **Filter Tabs**: All, Ongoing, Completed, Cancelled with live counts
- **Order Types**: Both Parcel and Dine-in orders in unified view
- **Real-time Updates**: Live status changes and notifications
- **Order Management**: Update item status from pending → preparing → served
- **Quick Actions**: Start all pending items, view detailed order information
- **Order Details Modal**: Full order breakdown with item-by-item status

### 6. ⚙️ Menu Management
- **Category Management**: Appetizers, Main Course, Desserts, Beverages
- **CRUD Operations**: Add, edit, hide/show, and delete menu items
- **Item Properties**: Name, description, price, veg/non-veg, spicy indicators
- **Availability Toggle**: Quickly hide/show items without deletion
- **Visual Interface**: Card-based layout with item images and details

### 7. 🔔 Real-time Features
- **Firestore Listeners**: Live updates across all dashboard sections
- **Status Notifications**: Toast messages for successful operations
- **Animated UI**: Smooth transitions and loading states
- **Error Handling**: Comprehensive error messages and retry options

## 🎨 Design & UI
- **Material 3 Design**: Modern, consistent interface
- **Dark Theme**: Premium restaurant aesthetic with gold accents
- **Responsive Layout**: Works on tablets and phones
- **Animations**: Smooth transitions, shimmer loading, pulse effects for active tables
- **Color-coded Status**: Intuitive visual indicators throughout

## 🏗️ Architecture

### Models
- `TableModel`: Table information and status
- `SalesAnalytics`: Dashboard metrics and KPIs
- `MenuItemModel`: Restaurant menu items (existing)
- `OrderModel`: Order and session data (existing)

### Services
- `AdminService`: All admin operations and Firebase interactions
- `FirebaseService`: Enhanced with admin-specific methods

### Providers (State Management)
- `AdminDashboardProvider`: Dashboard analytics and filters
- `AdminTablesProvider`: Table status and management
- `AdminOrdersProvider`: Order filtering and updates
- `BillingProvider`: Invoice generation and payment processing

### Screens
- `AdminMainScreen`: Navigation hub with bottom tabs
- `AdminDashboardScreen`: Analytics and overview
- `AdminTablesScreen`: Table grid and status management
- `TableDetailScreen`: Individual table session details
- `AdminOrdersScreen`: Order management and filtering
- `AdminMenuScreen`: Menu item CRUD operations
- `BillingScreen`: Invoice generation and payment

## 🔧 Technical Features
- **Real-time Sync**: Firestore listeners for live updates
- **State Management**: Provider pattern for reactive UI
- **Animations**: Custom animations for enhanced UX
- **Error Handling**: Comprehensive try-catch with user feedback
- **Navigation**: Bottom navigation with smooth page transitions
- **Modular Architecture**: Clean separation of concerns

## 🚀 Getting Started

### Run Admin Dashboard
```bash
# Run the admin app
flutter run lib/admin_main.dart
```

### Dependencies Added
- `provider: ^6.1.1` - State management
- All other dependencies are already in the existing pubspec.yaml

## 📱 Usage

1. **Launch Admin App**: Run `flutter run lib/admin_main.dart`
2. **Navigate Sections**: Use bottom navigation tabs
3. **Monitor Live Data**: All screens show real-time updates
4. **Manage Tables**: Tap tables to view details or change status
5. **Process Orders**: Track and update order status in real-time
6. **Generate Bills**: Create professional invoices and process payments
7. **Manage Menu**: Add, edit, and control item availability

## 🎯 Key Benefits

- **Real-time Operations**: Live sync with customer orders
- **Professional Interface**: Modern admin dashboard design
- **Complete Workflow**: From order to payment in one system
- **Staff Efficiency**: Quick actions and status updates
- **Business Intelligence**: Analytics and sales tracking
- **Error Prevention**: Comprehensive validation and error handling

The admin dashboard provides a complete solution for restaurant management with real-time capabilities, professional UI, and comprehensive features for daily operations.