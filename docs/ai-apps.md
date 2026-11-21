# AI apps (MCP)

Qima's desktop apps (macOS, Windows, Linux) can let AI apps that support the
Model Context Protocol read the person's books: Claude Desktop, Claude Code,
VS Code, Cursor, LM Studio and others. It is off by default and read-only.

## How it works

1. Settings › AI apps › **Let AI apps read Qima** (desktop only, never synced).
2. While it is on, Qima writes `qima-ai-snapshot.json`, a copy of the books
   (`AiSnapshot`, `lib/models/ai_snapshot.dart`), a couple of seconds after
   anything changes. Turning it off deletes the file.
3. The AI app starts the `qima-mcp` helper (shipped inside Qima) with
   `--snapshot <path>`. The helper speaks MCP over stdio
   (`lib/mcp/mcp_server.dart`) and reads only that file, again on every call.
4. Settings shows the exact `mcpServers` entry to paste, with both paths.

The helper never opens Qima's own files, so it does not depend on their
format, and the sandboxed Mac App Store build stays sandboxed.

## What is shared

Accounts, entries, planned payments, budgets, exchange rates and holdings
values. Left out at write time: account, card and IBAN digits
(`statementRefs`), account notes, raw bank-message merchant text, imported
file hashes, learned category rules and message senders.

Whatever an AI app reads goes to that app's model provider; the settings text
says so.

## Tools (`lib/mcp/qima_tools.dart`)

| Tool | Answers |
|---|---|
| `get_net_worth` | Net worth by group, optionally on an earlier day |
| `list_accounts` | Balances; categories and archived accounts on request |
| `list_transactions` | Filter by dates, account or category, text, kind; newest first |
| `get_spending` | One month by category, with budget and left to spend |
| `list_planned_payments` | Bills and income with the next due date |
| `list_people` | Who owes whom |
| `list_holdings` | Holdings value and cost at the last prices |

Every figure comes from the app's own models (`Book`, `NetWorthSummary`,
`MonthAnalysis`, `Person`), so answers match the screens. No tool writes.
Each result carries `saved_by_qima_at`, because the copy only updates while
Qima is open.

## Where things live

| | Snapshot | Helper |
|---|---|---|
| macOS (App Store) | App Group container `ZS3A435WC2.com.devlabtechnologies.qima` | `Qima.app/Contents/Helpers/QimaMCP.app/Contents/MacOS/qima-mcp`, sandboxed, same group |
| macOS (other builds) | Qima's Application Support folder | Same path, not sandboxed (macOS asks once to read another app's data) |
| Windows | `%APPDATA%\DevLab Technologies\Qima` | `qima-mcp.exe` beside `qima.exe` |
| Linux | `~/.local/share/com.devlabtechnologies.qima` | `qima-mcp` in the bundle |

## Building

The helper is its own small Dart package, `tool/qima_mcp`, which reaches the
app's pure-Dart models by path, so it needs neither Flutter nor the app's
plugins (`dart compile exe` refuses packages with build hooks, which the
app's plugins have).

- macOS: the Runner build phase "Embed qima-mcp" runs
  `tool/qima_mcp/embed_macos.sh`. It wraps the helper in a small bundle,
  because a sandboxed process needs a bundle id, and signs it with
  `allow-unsigned-executable-memory`, which Dart's AOT runtime needs under the
  hardened runtime.
- Windows and Linux: `tool/qima_mcp/qima_mcp.cmake`, included from each
  `CMakeLists.txt`, builds it and installs it beside the app, so the
  installer, zip and tarball carry it.

Keep `lib/models` and `lib/mcp` free of Flutter imports; the helper build
fails otherwise.

Run it by hand:

    cd tool/qima_mcp && dart run bin/qima_mcp.dart --snapshot <path>
