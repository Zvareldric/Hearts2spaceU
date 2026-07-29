/// Named route constants. Reference these instead of raw strings so renames
/// are safe and typos are caught at compile time.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String memberList = '/members';
  static const String memberDetail = '/members/detail';
  static const String schedule = '/schedule';
  static const String eventDetail = '/schedule/detail';
  static const String latestUpdates = '/updates';
  static const String updateDetail = '/updates/detail';
  static const String streamingHub = '/channels';
  static const String awards = '/awards';
  static const String awardDetail = '/awards/detail';
  static const String gallery = '/gallery';
  static const String album = '/gallery/album';
  static const String photoViewer = '/gallery/photo';
  static const String collection = '/collection';
}
