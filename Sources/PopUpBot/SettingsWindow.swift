import AppKit

class SettingsWindow: NSWindow {
    private let usernameField = NSTextField()
    var onSaved: (() -> Void)?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 150),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        title = "PopUpBot 설정"
        center()
        isReleasedWhenClosed = false
        setupUI()
        loadValues()
    }

    private func setupUI() {
        let content = NSView(frame: contentView!.bounds)
        content.autoresizingMask = [.width, .height]

        let margin: CGFloat = 20
        let labelW: CGFloat = 110
        let fieldH: CGFloat = 24
        let y = content.bounds.height - 44

        let usernameLabel = makeLabel("봇 유저네임")
        usernameLabel.frame = NSRect(x: margin, y: y, width: labelW, height: fieldH)
        content.addSubview(usernameLabel)

        usernameField.frame = NSRect(x: margin + labelW + 8, y: y, width: content.bounds.width - margin * 2 - labelW - 8, height: fieldH)
        usernameField.placeholderString = "my_bot"
        usernameField.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        usernameField.autoresizingMask = [.width]
        content.addSubview(usernameField)

        let btnY = y - 50

        let saveBtn = NSButton(title: "저장", target: self, action: #selector(saveSettings))
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"
        saveBtn.frame = NSRect(x: content.bounds.width - margin - 80, y: btnY, width: 80, height: 32)
        saveBtn.autoresizingMask = [.minXMargin]
        content.addSubview(saveBtn)

        let cancelBtn = NSButton(title: "취소", target: self, action: #selector(cancelSettings))
        cancelBtn.bezelStyle = .rounded
        cancelBtn.keyEquivalent = "\u{1b}"
        cancelBtn.frame = NSRect(x: content.bounds.width - margin - 170, y: btnY, width: 80, height: 32)
        cancelBtn.autoresizingMask = [.minXMargin]
        content.addSubview(cancelBtn)

        contentView = content
    }

    private func makeLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.alignment = .right
        return label
    }

    private func loadValues() {
        usernameField.stringValue = UserDefaults.standard.string(forKey: "botUsername") ?? ""
    }

    @objc private func saveSettings() {
        let username = usernameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if !username.isEmpty {
            UserDefaults.standard.set(username, forKey: "botUsername")
        }

        onSaved?()
        close()
    }

    @objc private func cancelSettings() {
        close()
    }
}
