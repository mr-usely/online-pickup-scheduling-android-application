class Servers {
  static final port = 8012;
  static final serverURL = 'http://www.universalleaf.com.ph:$port';
  static final r2IP = 'http://122.2.12.50:$port';
  static final liveServer = '$r2IP/VISA_app/index.php';
  static final testingServer = '$r2IP/VISA_app_testing/index.php';

  Servers._();
  static final Servers svr = Servers._();

  static Servers get ins => svr;

  srvLink(bool test) {
    return test ? testingServer : liveServer;
  }
}
