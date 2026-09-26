; Inno Setup script for the Windows installer. release.yml compiles it after
; `flutter build windows --release`:
;
;   iscc /DAppVersion=2.0.0 windows\installer\qima.iss
;
; Relative paths resolve against this file's folder, so the defaults below
; point at the Flutter release build and the repo's dist\ folder.
;
; Installs per user (no admin prompt) into %LOCALAPPDATA%\Programs\Qima.
; AppId must never change: Windows uses it to recognise upgrades.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

[Setup]
AppId={{7F9A33F5-9543-4CED-9750-5B6F205F9E7D}
AppName=Qima
AppVersion={#AppVersion}
AppVerName=Qima {#AppVersion}
AppPublisher=DevLab Technologies
DefaultDirName={autopf}\Qima
DefaultGroupName=Qima
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=qima-{#AppVersion}-windows-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\qima.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Qima"; Filename: "{app}\qima.exe"
Name: "{autodesktop}\Qima"; Filename: "{app}\qima.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\qima.exe"; Description: "{cm:LaunchProgram,Qima}"; Flags: nowait postinstall skipifsilent
