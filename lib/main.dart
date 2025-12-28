import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuthStatus(),
      child: MaterialApp(
        title: 'NutriTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2ECC71),
            brightness: Brightness.dark,
          ),
          fontFamily: 'SF Pro Display',
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          // Public routes (no auth required)
          final publicRoutes = {
            '/login': () => const LoginScreen(),
            '/register': () => const RegisterScreen(),
          };

          // Protected routes (auth required)
          final protectedRoutes = {
            '/home': () => const HomeScreen(),
            '/profile': () => const ProfileScreen(),
          };

          // Check if it's a public route
          if (publicRoutes.containsKey(settings.name)) {
            return MaterialPageRoute(
              builder: (_) => publicRoutes[settings.name]!(),
              settings: settings,
            );
          }

          // Check if it's a protected route
          if (protectedRoutes.containsKey(settings.name)) {
            return MaterialPageRoute(
              builder: (_) => AuthGuard(
                child: protectedRoutes[settings.name]!(),
              ),
              settings: settings,
            );
          }

          // Default: go to auth wrapper
          return MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
            settings: settings,
          );
        },
      ),
    );
  }
}

/// Guard widget that protects routes requiring authentication
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Still loading auth status
        if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Not authenticated - redirect to login
        if (!auth.isAuthenticated) {
          // Use addPostFrameCallback to avoid build-time navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          });
          return const SplashScreen();
        }

        // Authenticated - show the protected content
        return child;
      },
    );
  }
}

/// Wrapper that listens to auth state and shows appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show loading screen while checking auth status
        if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
          return const SplashScreen();
        }
        
        // Show home if authenticated, login if not
        if (auth.isAuthenticated) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen shown while checking auth status
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A2F),
              Color(0xFF0D1F17),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFF2ECC71),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'NutriTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Color(0xFF2ECC71),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
