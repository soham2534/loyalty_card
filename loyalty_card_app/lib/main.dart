import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_foundation/path_provider_foundation.dart';
import 'core/constants/app_theme.dart';
import 'core/services/local_database_service.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    try {
      // Initialize path_provider for web
      PathProviderPlatform.instance = PathProviderPlatform.instance;
    } catch (e) {
      print('Error initializing path_provider: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalDatabaseService>(
          create: (_) => LocalDatabaseService(),
        ),
      ],
      child: MaterialApp(
        title: 'Loyalty Cards',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
