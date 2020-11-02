import 'dart:io';

class CustomHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..userAgent = "Corona-Diary/1.0";
  }
}

void initHttpClient() {
  HttpOverrides.global = CustomHttpOverride();
}