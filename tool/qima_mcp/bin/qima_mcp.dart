import 'dart:convert';
import 'dart:io';

// The helper shares Qima's models by path so it needs neither Flutter nor
// the app's plugins: everything under lib/mcp and lib/models it reaches is
// pure Dart.
// ignore: avoid_relative_lib_imports
import '../../../lib/mcp/mcp_server.dart';
// ignore: avoid_relative_lib_imports
import '../../../lib/mcp/snapshot_location.dart';

/// `qima-mcp`: Qima's read-only MCP server for AI apps on the desktop
/// (Claude Desktop, VS Code, Cursor and others), over stdio.
///
///     qima-mcp [--snapshot <path>]
///
/// It reads only the copy Qima writes when "Let AI apps read Qima" is on.
/// Built with `dart compile exe` and shipped inside the desktop app.
const String _version = String.fromEnvironment('QIMA_VERSION', defaultValue: 'dev');

Future<void> main(List<String> args) async {
  String? path;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--snapshot' when i + 1 < args.length:
        path = args[++i];
      case '--version':
        stdout.writeln('qima-mcp $_version');
        return;
      case '--help' || '-h':
        stdout.writeln('Usage: qima-mcp [--snapshot <path>]\nQima\'s read-only MCP server, over stdio.');
        return;
      default:
        stderr.writeln('qima-mcp: unknown argument ${args[i]}');
        exitCode = 64;
        return;
    }
  }
  path ??= SnapshotLocation.defaultPath();
  if (path == null) {
    stderr.writeln('qima-mcp: no default snapshot path on this system; pass --snapshot <path>.');
    exitCode = 64;
    return;
  }
  final snapshot = path;
  final server = McpServer(loadSnapshot: () => SnapshotLocation.read(snapshot), version: _version);

  // stdout carries protocol messages only; anything else goes to stderr.
  await for (final line in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final reply = server.handleLine(line);
    if (reply != null) stdout.writeln(reply);
  }
}
