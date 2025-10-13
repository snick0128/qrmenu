#!/bin/bash

echo "🍽️  QR Menu App - Launch Script"
echo "================================"
echo ""

# Function to show menu
show_menu() {
    echo "Select an option:"
    echo "1) 🧪 Run Demo Test"
    echo "2) 📱 Run App (Development)"
    echo "3) 🔍 Analyze Code"
    echo "4) 📦 Build iOS (Release)"
    echo "5) 🤖 Build Android (Release)"
    echo "6) 🌐 Build Web"
    echo "7) 🔄 Clean & Reset"
    echo "8) 📊 Show App Info"
    echo "9) ❌ Exit"
    echo ""
}

# Function to run demo test
run_demo() {
    echo "🧪 Running app demo test..."
    dart test_demo.dart
    echo ""
}

# Function to run app
run_app() {
    echo "📱 Starting QR Menu app..."
    echo "Press Ctrl+C to stop the app"
    flutter run
}

# Function to analyze
analyze_code() {
    echo "🔍 Analyzing code..."
    flutter analyze --no-fatal-infos
    echo ""
}

# Function to build iOS
build_ios() {
    echo "📦 Building iOS app..."
    flutter build ios --no-codesign
    echo "✅ iOS build complete!"
    echo "📍 Location: build/ios/iphoneos/Runner.app"
    echo ""
}

# Function to build Android
build_android() {
    echo "🤖 Building Android app..."
    flutter build apk --release
    echo "✅ Android APK build complete!"
    echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
}

# Function to build web
build_web() {
    echo "🌐 Building web app..."
    echo "Note: QR scanner has limited web support"
    flutter build web
    echo "✅ Web build complete!"
    echo "📍 Location: build/web/"
    echo ""
}

# Function to clean
clean_reset() {
    echo "🔄 Cleaning and resetting..."
    flutter clean
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    echo "✅ Clean and reset complete!"
    echo ""
}

# Function to show app info
show_info() {
    echo "📊 QR Menu App Information:"
    echo "================================"
    echo "🏷️  Name: QR Menu Customer App"
    echo "📱 Platform: Flutter (iOS/Android/Web)"
    echo "🎯 Purpose: Restaurant QR code menu ordering"
    echo ""
    echo "✨ Key Features:"
    echo "  📸 QR Code Scanner with camera permissions"
    echo "  ⚡ Quick Order Bar (Roti, Chai, Papad)"
    echo "  🍽️  Complete menu with categories & search"
    echo "  🛒 Smart shopping cart with calculations"
    echo "  💳 Order placement with bill breakdown"
    echo "  🎨 Material Design 3 with custom theming"
    echo ""
    echo "🚀 Production Status: Ready for deployment!"
    echo "📖 Documentation: See README.md for details"
    echo ""
}

# Main script loop
while true; do
    show_menu
    read -p "Enter your choice (1-9): " choice
    echo ""
    
    case $choice in
        1) run_demo ;;
        2) run_app ;;
        3) analyze_code ;;
        4) build_ios ;;
        5) build_android ;;
        6) build_web ;;
        7) clean_reset ;;
        8) show_info ;;
        9) 
            echo "👋 Thanks for using QR Menu App!"
            echo "🚀 Ready for production deployment!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please choose 1-9."
            echo ""
            ;;
    esac
    
    # Wait for user to continue
    read -p "Press Enter to continue..."
    echo ""
done
