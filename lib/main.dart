// main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/configuration_screen.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/device_registration_screen.dart';
import 'screens/device_management_screen.dart';
import 'screens/direct_cognito_test_page.dart';
import 'screens/login_debug_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/confirm_account_screen.dart';
import 'screens/device_map_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'services/auth_service.dart';
import 'services/auth_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create the auth service
  final authService = AuthService();
  
  // Configure Amplify
  try {
    // Add the Cognito Auth plugin before configuring
    await Amplify.addPlugin(AmplifyAuthCognito());
    
    // Now configure Amplify
    await authService.configureAmplify();
    
    debugPrint('Amplify configured successfully');
    
    // Validate Cognito configuration
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      debugPrint('Auth session validation: ${session.isSignedIn ? 'Signed in' : 'Not signed in'}');
    } catch (validationError) {
      debugPrint('Auth configuration validation error: $validationError');
      // This is non-fatal, just for debugging
    }
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: authService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Check authentication using both methods
      // First try Amplify SDK
      final authService = Provider.of<AuthService>(context, listen: false);
      bool loggedInAmplify = false;
      try {
        loggedInAmplify = await authService.isLoggedIn();
        debugPrint('Amplify login check: $loggedInAmplify');
      } catch (e) {
        debugPrint('Error checking Amplify login: $e');
      }
      
      // Then also check with our AuthHelper (direct API tokens)
      final authHelper = AuthHelper();
      bool loggedInDirect = false;
      try {
        loggedInDirect = await authHelper.isAuthenticated();
        debugPrint('Direct API login check: $loggedInDirect');
      } catch (e) {
        debugPrint('Error checking Direct API login: $e');
      }
      
      // User is logged in if either method works
      setState(() {
        _isLoggedIn = loggedInAmplify || loggedInDirect;
        _isLoading = false;
      });
      
      debugPrint('Final login status: ${_isLoggedIn ? 'Logged in' : 'Not logged in'}');
    } catch (e) {
      debugPrint('Error in _checkLoginStatus: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'AquaForge Dashboard',
      theme: themeProvider.themeData,
      home: _isLoading 
          ? const SplashScreen() 
          : _isLoggedIn 
              ? const DashboardScreen() 
              : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/configuration': (context) => const ConfigurationScreen(),
        '/ai-analysis': (context) => const AIAnalysisScreen(),
        '/register-device': (context) => const DeviceRegistrationScreen(),
        '/devices': (context) => const DeviceManagementScreen(),
        '/device-map': (context) => const DeviceMapScreen(),
        '/direct-cognito-test': (context) => const DirectCognitoTestPage(),
        '/login-debug': (context) => const LoginDebugScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/confirm-account': (context) => const ConfirmAccountScreen(),
      },
    );
  }
}
