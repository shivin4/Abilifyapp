import 'package:go_router/go_router.dart';
import '../features/auth/splash_page.dart';
import '../features/auth/phone_login_page.dart';
import '../features/auth/otp_page.dart';
import '../features/role_gate.dart';
import '../features/therapist/dashboard_page.dart';
import '../features/therapist/schedule_calendar_page.dart';
import '../features/therapist/appointment_details_page.dart';
import '../features/therapist/post_session_notes_page.dart';
import '../features/parent/parent_dashboard_page.dart';
import '../features/parent/parent_profile_page.dart';
import '../features/therapist/video_session_page.dart';
import '../features/chat/chat_page.dart';

final router = GoRouter(
  initialLocation: '/t/dashboard',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const SplashPage()),
    GoRoute(path: '/login', builder: (c, s) => const PhoneLoginPage()),
    GoRoute(path: '/otp', builder: (c, s) {
      final map = s.extra as Map<String, dynamic>? ?? {};
      return OTPPage(
        phone: map['phone'] as String? ?? '',
        verificationId: map['verificationId'] as String? ?? '',
      );
    }),
    GoRoute(path: '/home', builder: (c, s) => const RoleGatePage()),

    // Therapist
    GoRoute(path: '/t/dashboard', builder: (c, s) => const TherapistDashboardPage()),
    GoRoute(path: '/t/schedule', builder: (c, s) => const ScheduleCalendarPage()),
    GoRoute(path: '/t/appointment', builder: (c, s) => const AppointmentDetailsPage()),
    GoRoute(path: '/t/notes', builder: (c, s) => const PostSessionNotesPage()),
    GoRoute(path: '/t/session', builder: (c, s) {
      final sessionMap = s.extra as Map<String, dynamic>? ?? {};
      return VideoSessionPage(channelName: sessionMap['channelId'] as String? ?? 'test_channel');
    }),
    GoRoute(path: '/chat', builder: (c, s) {
      final map = s.extra as Map<String, dynamic>? ?? {};
      return ChatPage(
        chatId: map['chatId'] as String? ?? '',
        otherUserName: map['otherUserName'] as String? ?? 'User',
      );
    }),

    // Parent
    GoRoute(path: '/p/dashboard', builder: (c, s) => const ParentDashboardPage()),
    GoRoute(path: '/p/profile', builder: (c, s) => const ParentProfilePage()),
  ],
);
