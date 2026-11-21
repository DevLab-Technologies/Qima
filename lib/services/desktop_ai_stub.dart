import 'ai_assist_provider.dart';

/// Web: no desktop model.
AiAssistProvider? desktopAiAssist() => null;

bool get desktopModelSupported => false;
