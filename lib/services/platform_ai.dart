import 'ai_assist_provider.dart';
import 'desktop_ai_stub.dart' if (dart.library.ffi) 'desktop_model.dart' as desktop;

/// This platform's on-device model: the OS's own where it has one (Apple,
/// Android), the downloaded open model on Windows and Linux.
AiAssistProvider platformAiAssist() => desktop.desktopAiAssist() ?? const PlatformAiAssistProvider();

/// Whether the model here is the one Qima downloads, so nothing should ask
/// about it (which starts the download) until the person turns it on.
bool get usesDownloadedModel => desktop.desktopModelSupported;
