import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var toggleAction: () -> Void
    private weak var panel: PopUpPanel?

    init(toggleAction: @escaping () -> Void, panel: PopUpPanel) {
        self.toggleAction = toggleAction
        self.panel = panel

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bubble.left.fill", accessibilityDescription: "Telegram Bot")
            button.imagePosition = .imageOnly
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "챗봇 열기/닫기", action: #selector(toggleClicked), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let zoomMenu = NSMenu()
        let zoomInItem = NSMenuItem(title: "글자 크게  ⌘+", action: #selector(zoomIn), keyEquivalent: "")
        zoomInItem.target = self
        zoomMenu.addItem(zoomInItem)
        let zoomOutItem = NSMenuItem(title: "글자 작게  ⌘-", action: #selector(zoomOut), keyEquivalent: "")
        zoomOutItem.target = self
        zoomMenu.addItem(zoomOutItem)
        let zoomResetItem = NSMenuItem(title: "기본 크기  ⌘0", action: #selector(zoomReset), keyEquivalent: "")
        zoomResetItem.target = self
        zoomMenu.addItem(zoomResetItem)

        let zoomParent = NSMenuItem(title: "글자 크기", action: nil, keyEquivalent: "")
        zoomParent.submenu = zoomMenu
        menu.addItem(zoomParent)

        let shortcutItem = NSMenuItem(title: "단축키 변경...", action: #selector(changeShortcut), keyEquivalent: "")
        shortcutItem.target = self
        menu.addItem(shortcutItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "설정...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "종료", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleClicked() { toggleAction() }

    @objc private func changeShortcut() {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.showShortcutRecorder()
    }

    @objc private func openSettings() {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { return }
        appDelegate.openSettings()
    }

    @objc private func zoomIn() { panel?.zoomIn() }
    @objc private func zoomOut() { panel?.zoomOut() }
    @objc private func zoomReset() { panel?.zoomReset() }

    @objc private func quitApp() { NSApp.terminate(nil) }
}
