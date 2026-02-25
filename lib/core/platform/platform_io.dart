export 'platform_io_stub.dart'
    if (dart.library.io) 'platform_io_native.dart'
    if (dart.library.js_interop) 'platform_io_web.dart';
