import AppKit
import Carbon.HIToolbox

class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var handler: (() -> Void)?
    private var eventHandlerRef: EventHandlerRef?

    private static let hotKeyID = EventHotKeyID(
        signature: OSType(0x504F5042), // "POPB"
        id: 1
    )

    // Default: Option + Space
    private static let defaultKeyCode: UInt32 = UInt32(kVK_Space)
    private static let defaultModifiers: UInt32 = UInt32(optionKey)

    private(set) var currentKeyCode: UInt32
    private(set) var currentModifiers: UInt32

    init(handler: @escaping () -> Void) {
        self.handler = handler

        if let savedKeyCode = UserDefaults.standard.object(forKey: "hotKeyCode") as? UInt32,
           let savedModifiers = UserDefaults.standard.object(forKey: "hotKeyModifiers") as? UInt32 {
            currentKeyCode = savedKeyCode
            currentModifiers = savedModifiers
        } else {
            currentKeyCode = HotKeyManager.defaultKeyCode
            currentModifiers = HotKeyManager.defaultModifiers
        }

        registerHotKey()
    }

    deinit {
        unregisterHotKey()
    }

    private func registerHotKey() {
        let eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()

                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                if hotKeyID.id == HotKeyManager.hotKeyID.id {
                    DispatchQueue.main.async {
                        manager.handler?()
                    }
                }
                return noErr
            },
            1,
            [eventSpec],
            selfPtr,
            &eventHandlerRef
        )

        let hotKeyIDVar = HotKeyManager.hotKeyID
        RegisterEventHotKey(
            currentKeyCode,
            currentModifiers,
            hotKeyIDVar,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregisterHotKey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    func updateHotKey(keyCode: UInt32, modifiers: UInt32) {
        unregisterHotKey()
        currentKeyCode = keyCode
        currentModifiers = modifiers
        UserDefaults.standard.set(keyCode, forKey: "hotKeyCode")
        UserDefaults.standard.set(modifiers, forKey: "hotKeyModifiers")
        registerHotKey()
    }

    func shortcutDisplayString() -> String {
        var parts: [String] = []
        if currentModifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if currentModifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if currentModifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if currentModifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }

        let keyName = keyCodeToString(currentKeyCode)
        parts.append(keyName)
        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            UInt32(kVK_Space): "Space",
            UInt32(kVK_Return): "↩",
            UInt32(kVK_Tab): "⇥",
            UInt32(kVK_Delete): "⌫",
            UInt32(kVK_Escape): "⎋",
            UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3",
            UInt32(kVK_F4): "F4", UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6",
            UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8", UInt32(kVK_F9): "F9",
            UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12",
            UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
            UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
            UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
            UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
            UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
            UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
            UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
            UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
            UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
            UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
            UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
            UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
            UInt32(kVK_ANSI_9): "9",
        ]
        return keyMap[keyCode] ?? "Key(\(keyCode))"
    }
}

// MARK: - Shortcut Recorder Window

class ShortcutRecorderWindow: NSWindow {
    var onShortcutRecorded: ((UInt32, UInt32) -> Void)?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 140),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        title = "단축키 변경"
        isReleasedWhenClosed = false
        center()

        let container = NSView(frame: contentView!.bounds)
        container.autoresizingMask = [.width, .height]

        let label = NSTextField(labelWithString: "새 단축키를 입력하세요")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.frame = NSRect(x: 20, y: 80, width: 280, height: 30)
        container.addSubview(label)

        let hint = NSTextField(labelWithString: "수정키(⌘⌥⇧⌃) + 키 조합을 누르세요")
        hint.font = .systemFont(ofSize: 12)
        hint.textColor = .secondaryLabelColor
        hint.frame = NSRect(x: 20, y: 50, width: 280, height: 20)
        container.addSubview(hint)

        let keyDisplay = NSTextField(labelWithString: "대기 중...")
        keyDisplay.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        keyDisplay.alignment = .center
        keyDisplay.frame = NSRect(x: 20, y: 10, width: 280, height: 30)
        keyDisplay.tag = 100
        container.addSubview(keyDisplay)

        contentView = container
    }

    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        guard !modifiers.isEmpty else { return }

        var carbonModifiers: UInt32 = 0
        if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }
        if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }

        let keyCode = UInt32(event.keyCode)

        onShortcutRecorded?(keyCode, carbonModifiers)
        close()
    }
}
