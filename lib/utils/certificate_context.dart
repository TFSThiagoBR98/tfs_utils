import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_io/io.dart';

Future<void> loadCertificateInContext({String? cert}) async {
  SecurityContext context = SecurityContext.defaultContext;

  try {
    if (cert != null) {
      Uint8List bytes = utf8.encode(cert);
      context.setTrustedCertificatesBytes(bytes);
    }
  } on TlsException catch (e) {
    if (!(e.osError?.message != null && e.osError!.message.contains('CERT_ALREADY_IN_HASH_TABLE'))) {
      rethrow;
    }
  }
}
