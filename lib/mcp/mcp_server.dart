import 'dart:convert';

import '../models/ai_snapshot.dart';
import 'qima_tools.dart';

/// Why the snapshot could not be read, in words the AI app can pass on to
/// the person (Qima not set up, the setting off, an old helper).
class SnapshotUnavailable implements Exception {
  final String message;
  const SnapshotUnavailable(this.message);

  @override
  String toString() => message;
}

/// A Model Context Protocol server over newline-delimited JSON-RPC 2.0, as
/// the stdio transport defines it. It offers only [QimaTools]: read-only
/// tools over the snapshot that [loadSnapshot] returns, read again on every
/// call so answers follow the app.
///
/// Pure Dart and transport-free so tests can drive it line by line;
/// `bin/qima_mcp.dart` wires it to stdin and stdout.
class McpServer {
  static const List<String> protocolVersions = ['2025-06-18', '2025-03-26', '2024-11-05'];

  final AiSnapshot Function() loadSnapshot;
  final String version;
  final DateTime Function() clock;

  McpServer({required this.loadSnapshot, required this.version, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  /// Answers one line from the client: the reply line, or null for a
  /// notification (which gets none).
  String? handleLine(String line) {
    if (line.trim().isEmpty) return null;
    Object? message;
    try {
      message = jsonDecode(line);
    } on FormatException {
      return _encode(_error(null, -32700, 'Parse error'));
    }
    if (message is List) {
      // Batches were dropped from the protocol in 2025-06-18; older clients
      // may still send one, so answer each request in it.
      final replies = [for (final m in message) ?_handle(m)];
      return replies.isEmpty ? null : _encode(replies);
    }
    final reply = _handle(message);
    return reply == null ? null : _encode(reply);
  }

  Map<String, dynamic>? _handle(Object? message) {
    if (message is! Map<String, dynamic> || message['jsonrpc'] != '2.0' || message['method'] is! String) {
      final id = message is Map ? message['id'] : null;
      return _error(id, -32600, 'Invalid request');
    }
    final id = message['id'];
    final isNotification = !message.containsKey('id');
    final method = message['method'] as String;
    final params = message['params'];
    if (params != null && params is! Map<String, dynamic>) {
      return isNotification ? null : _error(id, -32602, 'params must be an object');
    }
    final p = (params as Map<String, dynamic>?) ?? const {};

    if (isNotification) return null;
    switch (method) {
      case 'initialize':
        final asked = p['protocolVersion'];
        return _result(id, {
          'protocolVersion': protocolVersions.contains(asked) ? asked : protocolVersions.first,
          'capabilities': {
            'tools': {'listChanged': false},
          },
          'serverInfo': {'name': 'qima', 'title': 'Qima', 'version': version},
          'instructions': 'Read-only access to the person\'s Qima books: net worth, accounts, transactions, '
              'spending, planned payments, people and holdings. Amounts are in each currency\'s major unit. '
              'Qima saves this copy while it is open, so mention saved_by_qima_at when figures may be old. '
              'Report figures as they are; Qima is a tracking tool, not financial advice.',
        });
      case 'ping':
        return _result(id, {});
      case 'tools/list':
        return _result(id, {'tools': [for (final t in QimaTools.all) t.toJson()]});
      case 'tools/call':
        return _call(id, p);
      default:
        return _error(id, -32601, 'Method not found: $method');
    }
  }

  Map<String, dynamic> _call(Object? id, Map<String, dynamic> params) {
    final name = params['name'];
    final tool = name is String ? QimaTools.named(name) : null;
    if (tool == null) return _error(id, -32602, 'Unknown tool: $name');
    final args = params['arguments'] ?? const <String, dynamic>{};
    if (args is! Map<String, dynamic>) return _error(id, -32602, 'arguments must be an object');
    try {
      final result = tool.run(loadSnapshot(), args, clock());
      return _result(id, {
        'content': [
          {'type': 'text', 'text': const JsonEncoder.withIndent(' ').convert(result)},
        ],
        'structuredContent': result,
        'isError': false,
      });
    } on ToolInputError catch (e) {
      return _toolError(id, e.message);
    } on SnapshotUnavailable catch (e) {
      return _toolError(id, e.message);
    } on FormatException catch (e) {
      return _toolError(id, 'Qima\'s saved copy could not be read: ${e.message}');
    } on Object catch (e) {
      // Anything else (a copy edited by hand, a bug) answers this call
      // rather than ending the server the AI app is talking to.
      return _toolError(id, 'Qima could not answer this: $e');
    }
  }

  static Map<String, dynamic> _toolError(Object? id, String message) => _result(id, {
        'content': [
          {'type': 'text', 'text': message},
        ],
        'isError': true,
      });

  static Map<String, dynamic> _result(Object? id, Map<String, dynamic> result) =>
      {'jsonrpc': '2.0', 'id': id, 'result': result};

  static Map<String, dynamic> _error(Object? id, int code, String message) => {
        'jsonrpc': '2.0',
        'id': id,
        'error': {'code': code, 'message': message},
      };

  static String _encode(Object reply) => jsonEncode(reply);
}
