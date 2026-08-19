import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Formats the first 16 bytes of [bytes] as a UUID string, using the bytes
/// verbatim (no RFC 4122 version/variant bit twiddling) — matching Swift's
/// `UUID(uuid:)` initializer over a raw 16-byte tuple.
String uuidFromRawBytes(List<int> bytes) {
  assert(bytes.length >= 16);
  final b = bytes.sublist(0, 16);
  String hex(int start, int end) =>
      b.sublist(start, end).map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

/// Deterministic UUID derived from SHA-256(text), taking the first 16 bytes
/// of the digest as raw UUID bytes. Must match the Swift original bit-for-bit
/// so independently-seeded devices converge on identical ids.
String deterministicUuid(String text) {
  final digest = sha256.convert(utf8.encode(text));
  return uuidFromRawBytes(digest.bytes);
}
