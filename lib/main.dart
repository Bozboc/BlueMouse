import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/remote_control/presentation/providers/bluetooth_hid_provider.dart';
import 'features/remote_control/presentation/pages/permission_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const PCRemoteControllerApp());
}

class PCRemoteControllerApp extends StatelessWidget {
  const PCRemoteControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BluetoothHidProvider(di.sl(), di.sl()),
        ),
      ],
      child: MaterialApp(
        title: 'PC Remote',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0f172a),
        ),
        home: const PermissionScreen(),
      ),
    );
  }
}