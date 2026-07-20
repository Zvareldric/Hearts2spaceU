/// Named route constants. Reference these instead of raw strings so renames
/// are safe and typos are caught at compile time.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String memberList = '/members';
  static const String memberDetail = '/members/detail';
  static const String schedule = '/schedule';
  static const String eventDetail = '/schedule/detail';
}
