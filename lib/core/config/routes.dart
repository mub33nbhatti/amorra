import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/signin_screen.dart';
import '../../presentation/screens/main/main_navigation_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/bindings/auth_binding.dart';
import '../../presentation/bindings/splash_binding.dart';
import '../../presentation/bindings/main_binding.dart';
import '../../presentation/bindings/onboarding_binding.dart';

/// App Routes
/// Centralized route definitions for GetX navigation
class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String mainNavigation = '/main';
  static const String ageVerification = '/age-verification';
  static const String onboarding = '/onboarding';
  static const String chat = '/chat';
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription-plans';
  static const String payment = '/payment';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String adminDashboard = '/admin-dashboard';

  /// Get all routes
  static List<GetPage> getRoutes() {
    return [
      GetPage(
        name: splash,
        page: () => const SplashScreen(),
        binding: SplashBinding(),
      ),
      GetPage(
        name: welcome,
        page: () => const SigninScreen(), // Default to signin for now
        binding: AuthBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: signup,
        page: () => const SignupScreen(),
        binding: AuthBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: signin,
        page: () => const SigninScreen(),
        binding: AuthBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: onboarding,
        page: () => const OnboardingScreen(),
        binding: OnboardingBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: mainNavigation,
        page: () => const MainNavigationScreen(),
        binding: MainBinding(),
        preventDuplicates: true,
      ),
    ];
  }
}
