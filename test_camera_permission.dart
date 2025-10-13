import 'package:permission_handler/permission_handler.dart';

void main() async {
  print('=== Camera Permission Test ===');
  
  // Check current permission status
  var status = await Permission.camera.status;
  print('Current camera permission status: $status');
  
  if (status.isDenied) {
    print('Requesting camera permission...');
    var result = await Permission.camera.request();
    print('Permission request result: $result');
  }
  
  // Final status check
  var finalStatus = await Permission.camera.status;
  print('Final camera permission status: $finalStatus');
  
  if (finalStatus.isGranted) {
    print('✅ Camera permission is granted!');
  } else if (finalStatus.isPermanentlyDenied) {
    print('❌ Camera permission is permanently denied. User needs to enable it in Settings.');
  } else {
    print('⚠️  Camera permission is not granted.');
  }
}
