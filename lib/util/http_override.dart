import 'dart:io';

bool _initiated = false;

class CustomHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..userAgent = "Corona-Diary/1.0";
  }
}

void initHttpClient() {
  if (_initiated) return;

  HttpOverrides.global = CustomHttpOverride();
  _initiated = true;
}
