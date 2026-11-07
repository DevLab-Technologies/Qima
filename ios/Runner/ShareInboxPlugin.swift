import Flutter
import UIKit
import UniformTypeIdentifiers

/// Where Share › Qima leaves files (`ImportInbox` in the app group), for
/// `ShareInbox` (Dart), which reads and clears it; and the system Paste
/// button that hands a copied file or screenshot to `PastedFiles` (Dart).
final class ShareInboxPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.devlabtechnologies.qima/share_inbox", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(ShareInboxPlugin(), channel: channel)
    let pastes = FlutterMethodChannel(name: "com.devlabtechnologies.qima/paste", binaryMessenger: registrar.messenger())
    registrar.register(PasteButtonFactory(channel: pastes), withId: "com.devlabtechnologies.qima/paste_button")
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "inboxPath": result(Self.inboxPath())
    // Asking what kinds the clipboard holds shows no prompt. Reading it from
    // code is refused, so the content comes through the system Paste button,
    // which needs iOS 16.
    case "hasPastedFile":
      if #available(iOS 16.0, *) {
        result(UIPasteboard.general.types.contains { type in Importable.accepts(UTType(type)) })
      } else {
        result(false)
      }
    // Where the "Add a bank message" automation is set up.
    case "openShortcuts":
      if let url = URL(string: "shortcuts://") { UIApplication.shared.open(url) }
      result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private static func inboxPath() -> String? {
    guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.devlabtechnologies.qima") else {
      return nil
    }
    let inbox = container.appendingPathComponent("ImportInbox", isDirectory: true)
    try? FileManager.default.createDirectory(at: inbox, withIntermediateDirectories: true)
    return inbox.path
  }
}

/// What the import reads: statements, tables, text and pictures.
private enum Importable {
  static let types: [UTType] = [.pdf, .commaSeparatedText, .tabSeparatedText, .plainText, .image] + [UTType("org.openxmlformats.spreadsheetml.sheet")].compactMap { $0 }

  static func accepts(_ type: UTType?) -> Bool {
    guard let type else { return false }
    return types.contains { type.conforms(to: $0) }
  }
}

/// The system Paste button (`UIPasteControl`) as a Flutter view. A tap on
/// it is the person's own paste, so the system asks nothing. Each item goes
/// to Dart ("pasted" on the paste channel) as its name if it has one, a file
/// extension and its bytes; pictures as PNG, so every kind of image reads.
private final class PasteButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let channel: FlutterMethodChannel

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    PasteButtonView(frame: frame, channel: channel, colors: args as? [String: Any] ?? [:])
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol { FlutterStandardMessageCodec.sharedInstance() }
}

private final class PasteButtonView: NSObject, FlutterPlatformView {
  private let target: UIView

  init(frame: CGRect, channel: FlutterMethodChannel, colors: [String: Any]) {
    if #available(iOS 16.0, *) {
      target = PasteTarget(frame: frame, channel: channel, background: Self.color(colors["background"]), foreground: Self.color(colors["foreground"]))
    } else {
      target = UIView(frame: frame)
    }
  }

  func view() -> UIView { target }

  /// A Flutter colour (ARGB in an int) as a UIColor.
  private static func color(_ value: Any?) -> UIColor? {
    guard let argb = (value as? NSNumber)?.uint32Value else { return nil }
    func part(_ shift: UInt32) -> CGFloat { CGFloat((argb >> shift) & 0xFF) / 255 }
    return UIColor(red: part(16), green: part(8), blue: part(0), alpha: part(24))
  }
}

@available(iOS 16.0, *)
private final class PasteTarget: UIView {
  private let channel: FlutterMethodChannel

  init(frame: CGRect, channel: FlutterMethodChannel, background: UIColor?, foreground: UIColor?) {
    self.channel = channel
    super.init(frame: frame)
    pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: Importable.types.map(\.identifier))
    let configuration = UIPasteControl.Configuration()
    configuration.displayMode = .iconAndLabel
    configuration.cornerStyle = .capsule
    configuration.baseBackgroundColor = background
    configuration.baseForegroundColor = foreground
    let control = UIPasteControl(configuration: configuration)
    control.target = self
    control.translatesAutoresizingMaskIntoConstraints = false
    addSubview(control)
    NSLayoutConstraint.activate([
      control.leadingAnchor.constraint(equalTo: leadingAnchor),
      control.trailingAnchor.constraint(equalTo: trailingAnchor),
      control.topAnchor.constraint(equalTo: topAnchor),
      control.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) { nil }

  override func paste(itemProviders: [NSItemProvider]) {
    let group = DispatchGroup()
    let lock = NSLock()
    var items = [(Int, [String: Any])]()
    for (index, provider) in itemProviders.enumerated() {
      guard let id = provider.registeredTypeIdentifiers.first(where: { Importable.accepts(UTType($0)) }), let type = UTType(id) else { continue }
      group.enter()
      provider.loadDataRepresentation(forTypeIdentifier: id) { data, _ in
        defer { group.leave() }
        guard var data else { return }
        var ext = type.preferredFilenameExtension ?? "txt"
        if type.conforms(to: .image) {
          guard let png = UIImage(data: data)?.pngData() else { return }
          data = png
          ext = "png"
        } else if type.conforms(to: .plainText) {
          ext = "txt"
        }
        var item: [String: Any] = ["ext": ext, "bytes": FlutterStandardTypedData(bytes: data)]
        if let name = provider.suggestedName, !name.isEmpty { item["name"] = name }
        lock.lock()
        items.append((index, item))
        lock.unlock()
      }
    }
    group.notify(queue: .main) { [channel] in
      guard !items.isEmpty else { return }
      channel.invokeMethod("pasted", arguments: items.sorted { $0.0 < $1.0 }.map(\.1))
    }
  }
}
