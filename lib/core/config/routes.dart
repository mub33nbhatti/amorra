import 'package:amorra/presentation/bindings/profile_setup_binding.dart';
import 'package:get/get.dart';
import 'package:amorra/presentation/screens/auth/splash/splash_screen.dart';
import 'package:amorra/presentation/screens/auth/auth_main/signup_screen.dart';
import 'package:amorra/presentation/screens/auth/auth_main/signin_screen.dart';
import 'package:amorra/presentation/screens/auth/age_verification/age_verification_screen.dart';
import 'package:amorra/presentation/screens/main/main_navigation/main_navigation_screen.dart';
import 'package:amorra/presentation/screens/auth/profile_setup/profile_setup_screen.dart';
import 'package:amorra/presentation/screens/auth/onboarding/onboarding_screen.dart';
import 'package:amorra/presentation/screens/admin/admin_login_screen.dart';
import 'package:amorra/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:amorra/presentation/screens/auth/blocked/blocked_user_screen.dart';
import 'package:amorra/presentation/bindings/auth_binding.dart';
import 'package:amorra/presentation/bindings/splash_binding.dart';
import 'package:amorra/presentation/bindings/main_binding.dart';
import 'package:amorra/presentation/bindings/auth/onboarding_binding.dart';
import 'package:amorra/presentation/bindings/age_verification_binding.dart';
import 'package:amorra/presentation/bindings/admin_binding.dart';
import 'package:amorra/presentation/bindings/auth/blocked_user_binding.dart';

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
  static const String profileSetup = '/profile-setup';
  static const String onboarding = '/onboarding';
  static const String chat = '/chat';
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription-plans';
  static const String payment = '/payment';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String adminLogin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String blockedUser = '/blocked-user';

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
        name: ageVerification,
        page: () => const AgeVerificationScreen(),
        binding: AgeVerificationBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: profileSetup,
        page: () => const ProfileSetupScreen(),
        binding: ProfileSetupBinding(),
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
      GetPage(
        name: adminLogin,
        page: () => const AdminLoginScreen(),
        binding: AdminBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: adminDashboard,
        page: () => const AdminDashboardScreen(),
        binding: AdminBinding(),
        preventDuplicates: true,
      ),
      GetPage(
        name: blockedUser,
        page: () => const BlockedUserScreen(),
        binding: BlockedUserBinding(),
        preventDuplicates: true,
      ),
    ];
  }
}
