import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var popUpPanel: PopUpPanel!
    private var hotKeyManager: HotKeyManager!
    private var settingsWindow: SettingsWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        popUpPanel = PopUpPanel()
        statusBarController = StatusBarController(
            toggleAction: { [weak self] in self?.togglePanel() },
            panel: popUpPanel
        )
        hotKeyManager = HotKeyManager { [weak self] in
            self?.togglePanel()
        }

        let token = UserDefaults.standard.string(forKey: "botToken") ?? ""
        let username = UserDefaults.standard.string(forKey: "botUsername") ?? ""
        if token.isEmpty || username.isEmpty {
            openSettings()
        }
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
