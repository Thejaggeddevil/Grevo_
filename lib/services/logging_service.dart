// Conditional export: IO implementation on mobile/desktop, web stub on web
export 'logging_service_io.dart' if (dart.library.html) 'logging_service_web.dart';
