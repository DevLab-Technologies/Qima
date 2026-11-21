import UIKit
import UniformTypeIdentifiers

/// Share › Qima. Copies what was shared into the app group's import inbox,
/// says how many files went, and closes. It never reads anything itself:
/// extensions get far less memory than reading a statement needs, so Qima
/// reads the inbox the next time it opens.
///
/// Each item is a folder in `ImportInbox/` holding the file and a
/// `meta.json` (`name`, `receivedAt`); the folder is written under a
/// temporary name and renamed when complete, so the app never sees half a
/// file.
final class ShareViewController: UIViewController {
  static let appGroup = "group.com.devlabtechnologies.qima"

  /// What Qima can read, most specific first. The first type an attachment
  /// offers decides how it is copied.
  private static let fileTypes: [UTType] = [
    .pdf,
    .commaSeparatedText,
    UTType("org.openxmlformats.spreadsheetml.sheet") ?? .spreadsheet,
    .image,
  ]

  private let titleLabel = UILabel()
  private let hintLabel = UILabel()
  private let icon = UIImageView()

  override func viewDidLoad() {
    super.viewDidLoad()
    buildCard()
    Task { await receive() }
  }

  private func buildCard() {
    view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
    let card = UIView()
    card.backgroundColor = .secondarySystemGroupedBackground
    card.layer.cornerRadius = 20
    card.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(card)

    icon.image = UIImage(systemName: "tray.and.arrow.down")
    icon.tintColor = UIColor(red: 0.80, green: 0.62, blue: 0.16, alpha: 1)
    icon.contentMode = .scaleAspectFit
    titleLabel.text = NSLocalizedString("sending", comment: "")
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    hintLabel.font = .preferredFont(forTextStyle: .subheadline)
    hintLabel.textColor = .secondaryLabel
    hintLabel.textAlignment = .center
    hintLabel.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [icon, titleLabel, hintLabel])
    stack.axis = .vertical
    stack.spacing = 10
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    card.addSubview(stack)
    NSLayoutConstraint.activate([
      card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
      card.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
      card.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64).withPriority(.defaultHigh),
      stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
      stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
      stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
      icon.heightAnchor.constraint(equalToConstant: 36),
      icon.widthAnchor.constraint(equalToConstant: 36),
    ])
  }

  private func receive() async {
    let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? []).flatMap { $0.attachments ?? [] }
    var sent = 0
    if let inbox = Self.inbox() {
      for provider in providers.prefix(20) where await copy(provider, into: inbox) {
        sent += 1
      }
    }
    await MainActor.run { show(sent: sent) }
    try? await Task.sleep(nanoseconds: sent > 0 ? 1_400_000_000 : 2_600_000_000)
    await MainActor.run { extensionContext?.completeRequest(returningItems: nil) }
  }

  private func show(sent: Int) {
    if sent == 0 {
      icon.image = UIImage(systemName: "exclamationmark.circle")
      titleLabel.text = NSLocalizedString("nothing", comment: "")
      hintLabel.text = NSLocalizedString("nothing.hint", comment: "")
    } else {
      icon.image = UIImage(systemName: "checkmark.circle")
      titleLabel.text = sent == 1 ? NSLocalizedString("sent.one", comment: "") : String(format: NSLocalizedString("sent.many", comment: ""), sent)
      hintLabel.text = NSLocalizedString("sent.hint", comment: "")
    }
  }

  static func inbox() -> URL? {
    guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return nil }
    let inbox = container.appendingPathComponent("ImportInbox", isDirectory: true)
    try? FileManager.default.createDirectory(at: inbox, withIntermediateDirectories: true)
    return inbox
  }

  /// Copies one attachment into its own folder. False when it isn't
  /// something Qima reads.
  private func copy(_ provider: NSItemProvider, into inbox: URL) async -> Bool {
    let id = UUID().uuidString
    let staging = inbox.appendingPathComponent(".\(id)", isDirectory: true)
    let final = inbox.appendingPathComponent(id, isDirectory: true)
    let fm = FileManager.default
    do {
      try fm.createDirectory(at: staging, withIntermediateDirectories: true)
    } catch {
      return false
    }
    var name: String?
    if let type = Self.fileTypes.first(where: { provider.hasItemConformingToTypeIdentifier($0.identifier) }) {
      name = await withCheckedContinuation { (done: CheckedContinuation<String?, Never>) in
        _ = provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, _ in
          guard let url else { return done.resume(returning: nil) }
          var fileName = provider.suggestedName.map { Self.safe($0) } ?? url.lastPathComponent
          if (fileName as NSString).pathExtension.isEmpty {
            fileName += "." + (url.pathExtension.isEmpty ? (type.preferredFilenameExtension ?? "dat") : url.pathExtension)
          }
          do {
            try fm.copyItem(at: url, to: staging.appendingPathComponent(fileName))
            done.resume(returning: fileName)
          } catch {
            done.resume(returning: nil)
          }
        }
      }
    } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
      let text = await withCheckedContinuation { (done: CheckedContinuation<String?, Never>) in
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
          switch item {
          case let s as String: done.resume(returning: s)
          case let d as Data: done.resume(returning: String(data: d, encoding: .utf8))
          case let u as URL: done.resume(returning: try? String(contentsOf: u, encoding: .utf8))
          default: done.resume(returning: nil)
          }
        }
      }
      if let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
         (try? text.write(to: staging.appendingPathComponent("message.txt"), atomically: true, encoding: .utf8)) != nil {
        name = "message.txt"
      }
    }
    guard let name else {
      try? fm.removeItem(at: staging)
      return false
    }
    let meta: [String: Any] = ["name": name, "receivedAt": ISO8601DateFormatter().string(from: Date())]
    guard let data = try? JSONSerialization.data(withJSONObject: meta),
          (try? data.write(to: staging.appendingPathComponent("meta.json"))) != nil,
          (try? fm.moveItem(at: staging, to: final)) != nil else {
      try? fm.removeItem(at: staging)
      return false
    }
    return true
  }

  private static func safe(_ name: String) -> String {
    let cleaned = name.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
    return cleaned.isEmpty ? "file" : String(cleaned.prefix(120))
  }
}

private extension NSLayoutConstraint {
  func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
    self.priority = priority
    return self
  }
}
