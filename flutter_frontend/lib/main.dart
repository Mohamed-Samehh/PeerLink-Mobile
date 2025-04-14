import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => PeerLinkApp()));
}

class PeerLinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'PeerLink',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.user != null ? HomeScreen() : LoginScreen();
          },
        ),
      ),
    );
  }
}
