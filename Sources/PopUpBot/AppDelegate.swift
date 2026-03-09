import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var popUpPanel: PopUpPanel!
    private var hotKeyManager: HotKeyManager!
    private var settingsWindow: SettingsWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupEditMenu()
        setupNotifications()

        popUpPanel = PopUpPanel()
        statusBarController = StatusBarController(
            toggleAction: { [weak self] in self?.togglePanel() },
            panel: popUpPanel
        )
        popUpPanel.onBadgeCountChanged = { [weak self] count in
            self?.statusBarController.updateBadge(count)
        }
        hotKeyManager = HotKeyManager { [weak self] in
            self?.togglePanel()
        }

        let username = UserDefaults.standard.string(forKey: "botUsername") ?? ""
        if username.isEmpty {
            openSettings()
        }
    }

    private func setupNotifications() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                DispatchQueue.main.async {
                    NSApp.activate(ignoringOtherApps: true)
                }
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            }
        }
    }

    private func setupEditMenu() {
        let mainMenu = NSMenu()

        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    func togglePanel() {
        if popUpPanel.isVisible {
            popUpPanel.hidePanel()
        } else {
            popUpPanel.showPanel()
        }
    }

    func showShortcutRecorder() {
        let recorder = ShortcutRecorderWindow()
        recorder.onShortcutRecorded = { [weak self] keyCode, modifiers in
            self?.hotKeyManager.updateHotKey(keyCode: keyCode, modifiers: modifiers)
        }
        recorder.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func openSettings() {
        NSApp.activate(ignoringOtherApps: true)

        if settingsWindow == nil {
            settingsWindow = SettingsWindow()
        }
        settingsWindow?.onSaved = { [weak self] in
            self?.popUpPanel.reloadWeb()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
}
