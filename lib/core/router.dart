import 'package:go_router/go_router.dart';
import '../features/auth/splash_page.dart';
import '../features/auth/phone_login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/otp_page.dart';
import '../features/auth/role_select_page.dart';
import '../features/auth/pending_approval_page.dart';
import '../features/role_gate.dart';
import '../features/therapist/therapist_shell_page.dart';
import '../features/therapist/therapist_profile_setup_page.dart';
import '../features/therapist/schedule_calendar_page.dart';
import '../features/therapist/appointment_details_page.dart';
import '../features/therapist/post_session_notes_page.dart';
import '../features/parent/parent_shell_page.dart';
import '../features/parent/parent_profile_page.dart';
import '../features/parent/book_session_page.dart';
import '../features/therapist/video_session_page.dart';
import '../features/chat/chat_page.dart';
import '../models/therapist.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const SplashPage()),
    GoRoute(path: '/login', builder: (c, s) => const PhoneLoginPage()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupPage()),
    GoRoute(path: '/otp', builder: (c, s) {
      final map = s.extra as Map<String, dynamic>? ?? {};
      return OTPPage(
        phone: map['phone'] as String? ?? '',
        verificationId: map['verificationId'] as String? ?? '',
        isSignup: map['isSignup'] as bool? ?? false,
        name: map['name'] as String? ?? '',
      );
    }),
    GoRoute(path: '/role-select', builder: (c, s) {
      final map = s.extra as Map<String, dynamic>? ?? {};
      return RoleSelectPage(
        name: map['name'] as String? ?? 'User',
        phone: map['phone'] as String? ?? '',
      );
    }),
    GoRoute(path: '/pending', builder: (c, s) => const PendingApprovalPage()),
    GoRoute(path: '/home', builder: (c, s) => const RoleGatePage()),

    // Therapist shell + legacy redirects
    GoRoute(path: '/t/home', builder: (c, s) => const TherapistShellPage()),
    GoRoute(path: '/t/dashboard', redirect: (c, s) => '/t/home'),
    GoRoute(path: '/t/profile-setup', builder: (c, s) => const TherapistProfileSetupPage()),
    GoRoute(path: '/t/schedule', builder: (c, s) => const ScheduleCalendarPage()),
    GoRoute(path: '/t/appointment', builder: (c, s) {
      final map = s.extra as Map<String, dynamic>? ?? {};
      return AppointmentDetailsPage(sessionId: map['sessionId'] as String?);
    }),
    GoRoute(path: '/t/notes', builder: (c, s) => const PostSessionNotesPage()),
    GoRoute(path: '/t/session', builder: (c, s) {
      final sessionMap = s.extra as Map<String, dynamic>? ?? {};
      return VideoSessionPage(channelName: sessionMap['channelId'] as String? ?? 'test_channel');
    }),

    // Parent shell + legacy redirects
    GoRoute(path: '/p/home', builder: (c, s) => const ParentShellPage()),
    GoRoute(path: '/p/dashboard', redirect: (c, s) => '/p/home'),
    GoRoute(path: '/p/profile', builder: (c, s) => const ParentProfilePage()),
    GoRoute(path: '/p/book', builder: (c, s) {
      final therapist = s.extra as Therapist;
      return BookSessionPage(therapist: therapist);
    }),
    GoRoute(path: '/p/session', builder: (c, s) {
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
  ],
);
