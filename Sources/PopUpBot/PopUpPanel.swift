import AppKit
import WebKit
import UserNotifications

class PopUpPanel: NSPanel, NSWindowDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var clickMonitor: Any?
    private let minPanelSize = NSSize(width: 360, height: 420)
    private let maxPanelSize = NSSize(width: 980, height: 1100)

    var chatId: Int {
        get { UserDefaults.standard.integer(forKey: "chatId") }
        set { UserDefaults.standard.set(newValue, forKey: "chatId") }
    }

    init() {
        let defaultWidth = UserDefaults.standard.double(forKey: "panelWidth")
        let defaultHeight = UserDefaults.standard.double(forKey: "panelHeight")
        let initialWidth = defaultWidth > 0 ? defaultWidth : 420
        let initialHeight = defaultHeight > 0 ? defaultHeight : 640
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: initialWidth, height: initialHeight),
            styleMask: [.titled, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .floating
        isFloatingPanel = true
        hidesOnDeactivate = false
        delegate = self
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        minSize = minPanelSize
        maxSize = maxPanelSize

        title = ""
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.97)

        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true

        setupTitleBarBranding()
        setupContent()
        positionBottomLeft()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    private func setupTitleBarBranding() {
        guard let titlebarView = standardWindowButton(.closeButton)?.superview?.superview else { return }

        let titleLabel = NSTextField(labelWithString: "Telegram Bot")
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titlebarView.addSubview(titleLabel)

        let madeBy = NSTextField(labelWithString: "made by hw-oh")
        madeBy.font = .systemFont(ofSize: 11, weight: .regular)
        madeBy.textColor = .tertiaryLabelColor
        madeBy.translatesAutoresizingMaskIntoConstraints = false
        titlebarView.addSubview(madeBy)

        let sep = NSTextField(labelWithString: "|")
        sep.font = .systemFont(ofSize: 11, weight: .light)
        sep.textColor = .tertiaryLabelColor
        sep.translatesAutoresizingMaskIntoConstraints = false
        titlebarView.addSubview(sep)

        let ghButton = NSButton(title: "G", target: self, action: #selector(openGitHub))
        ghButton.isBordered = false
        ghButton.wantsLayer = true
        ghButton.layer?.cornerRadius = 9
        ghButton.layer?.backgroundColor = NSColor.tertiaryLabelColor.cgColor
        ghButton.font = .systemFont(ofSize: 10, weight: .bold)
        ghButton.contentTintColor = .white
        ghButton.translatesAutoresizingMaskIntoConstraints = false
        titlebarView.addSubview(ghButton)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titlebarView.leadingAnchor, constant: 14),

            ghButton.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
            ghButton.trailingAnchor.constraint(equalTo: titlebarView.trailingAnchor, constant: -14),
            ghButton.widthAnchor.constraint(equalToConstant: 18),
            ghButton.heightAnchor.constraint(equalToConstant: 18),

            sep.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
            sep.trailingAnchor.constraint(equalTo: ghButton.leadingAnchor, constant: -6),

            madeBy.centerYAnchor.constraint(equalTo: titlebarView.centerYAnchor),
            madeBy.trailingAnchor.constraint(equalTo: sep.leadingAnchor, constant: -6),
        ])
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/hw-oh") {
            NSWorkspace.shared.open(url)
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { hidePanel(); return }
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "w": hidePanel(); return
            case "+", "=": zoomIn(); return
            case "-": zoomOut(); return
            case "0": zoomReset(); return
            default: break
            }
        }
        if event.modifierFlags.contains([.command, .shift]) {
            switch event.charactersIgnoringModifiers {
            case "+", "=": increasePanelSize(); return
            case "-": decreasePanelSize(); return
            case "0": resetPanelSize(); return
            default: break
            }
        }
        super.keyDown(with: event)
    }

    private func setupContent() {
        requestNotificationPermission()

        let container = NSView(frame: contentView!.bounds)
        container.autoresizingMask = [.width, .height]
        container.wantsLayer = true
        container.layer?.masksToBounds = true

        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let notificationScript = WKUserScript(
            source: Self.notificationInterceptJS,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(notificationScript)
        config.userContentController.add(self, name: "nativeNotification")

        webView = WKWebView(frame: container.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.width, .height]
        webView.allowsMagnification = true
        container.addSubview(webView)

        contentView?.addSubview(container)
        loadTelegramWeb()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private static let notificationInterceptJS = """
    (function() {
        var OriginalNotification = window.Notification;
        var _permission = "granted";

        function FakeNotification(title, options) {
            options = options || {};
            this.title = title;
            this.body = options.body || "";
            this.icon = options.icon || "";
            this.tag = options.tag || "";
            this.onclick = null;
            this.onclose = null;

            window.webkit.messageHandlers.nativeNotification.postMessage({
                title: title,
                body: options.body || "",
                tag: options.tag || ""
            });
        }

        FakeNotification.permission = _permission;
        FakeNotification.requestPermission = function(cb) {
            if (cb) cb(_permission);
            return Promise.resolve(_permission);
        };
        FakeNotification.prototype.close = function() {};

        Object.defineProperty(FakeNotification, 'permission', {
            get: function() { return _permission; }
        });

        window.Notification = FakeNotification;
    })();
    """

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "nativeNotification",
              let body = message.body as? [String: String] else { return }

        if isVisible && isKeyWindow { return }

        let title = body["title"] ?? "Telegram"
        let text = body["body"] ?? ""

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = .default

        let id = body["tag"] ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func loadTelegramWeb() {
        let botUsername = UserDefaults.standard.string(forKey: "botUsername") ?? ""
        let urlStr = botUsername.isEmpty ? "https://web.telegram.org/k/" : "https://web.telegram.org/k/#@\(botUsername)"
        guard let url = URL(string: urlStr) else { return }
        webView.load(URLRequest(url: url))
    }

    private func focusBotChatOnly() {
        let botUsername = UserDefaults.standard.string(forKey: "botUsername") ?? ""
        guard !botUsername.isEmpty else { return }
        let js = """
        (function() {
            var target = "@\(botUsername)";
            if (!location.pathname.includes("/k/")) {
                location.href = "https://web.telegram.org/k/#" + target;
                return;
            }
            if (!location.hash.includes(target)) {
                location.hash = target;
            }
            var normalized = target.toLowerCase().replace("@", "");
            var candidates = Array.from(document.querySelectorAll("a, div[role='button'], li, .chatlist a, .chatlist div"));
            var row = candidates.find(function(el) {
                var t = (el.innerText || el.textContent || "").toLowerCase();
                return t.includes("@" + normalized) || t.includes(normalized);
            });
            if (row) {
                row.click();
            }
        })();
        """
        webView.evaluateJavaScript(js)
    }

    private func positionBottomLeft() {
        guard let screen = NSScreen.main else { return }
        let sf = screen.visibleFrame
        var x = sf.minX + 20
        var y = sf.minY + 20
        x = min(max(x, sf.minX), sf.maxX - frame.width)
        y = min(max(y, sf.minY), sf.maxY - frame.height)
        setFrameOrigin(NSPoint(x: x, y: y))
    }

    func showPanel() {
        positionBottomLeft()
        alphaValue = 0

        let target = frame
        var start = target
        start.origin.y -= 8
        setFrame(start, display: false)

        orderFrontRegardless()
        makeKey()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.22
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1
            self.animator().setFrame(target, display: true)
        }

        focusBotChatOnly()
        startClickMonitor()
    }

    func hidePanel() {
        stopClickMonitor()
        savePanelSize()
        var end = frame
        end.origin.y -= 8

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
            self.animator().setFrame(end, display: true)
        }, completionHandler: { self.orderOut(nil) })
    }

    private func savePanelSize() {
        UserDefaults.standard.set(frame.width, forKey: "panelWidth")
        UserDefaults.standard.set(frame.height, forKey: "panelHeight")
    }

    private func startClickMonitor() {
        stopClickMonitor()
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, self.isVisible else { return }
            let mouseLocation = NSEvent.mouseLocation
            if !self.frame.contains(mouseLocation) { self.hidePanel() }
        }
    }

    private func stopClickMonitor() {
        if let m = clickMonitor { NSEvent.removeMonitor(m); clickMonitor = nil }
    }

    func windowWillClose(_ n: Notification) { stopClickMonitor() }

    func windowDidResize(_ notification: Notification) {
        savePanelSize()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        applyZoom()
        focusBotChatOnly()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.focusBotChatOnly()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            self?.focusBotChatOnly()
        }
    }

    func reloadWeb() {
        loadTelegramWeb()
    }

    private func applyZoom() {
        let saved = UserDefaults.standard.double(forKey: "webViewZoom")
        webView.magnification = saved > 0 ? saved : 1.0
    }

    private func saveZoom() {
        UserDefaults.standard.set(webView.magnification, forKey: "webViewZoom")
    }

    func zoomIn() { webView.magnification = min(webView.magnification + 0.1, 2.0); saveZoom() }
    func zoomOut() { webView.magnification = max(webView.magnification - 0.1, 0.5); saveZoom() }
    func zoomReset() { webView.magnification = 1.0; saveZoom() }
    func increasePanelSize() { resizePanel(widthDelta: 40, heightDelta: 60) }
    func decreasePanelSize() { resizePanel(widthDelta: -40, heightDelta: -60) }
    func resetPanelSize() {
        let target = NSSize(width: 420, height: 640)
        resizePanel(to: target)
    }

    private func resizePanel(widthDelta: CGFloat, heightDelta: CGFloat) {
        let target = NSSize(
            width: frame.size.width + widthDelta,
            height: frame.size.height + heightDelta
        )
        resizePanel(to: target)
    }

    private func resizePanel(to size: NSSize) {
        let clamped = NSSize(
            width: min(max(size.width, minPanelSize.width), maxPanelSize.width),
            height: min(max(size.height, minPanelSize.height), maxPanelSize.height)
        )

        var newFrame = frame
        let heightDiff = clamped.height - frame.height
        newFrame.size = clamped
        newFrame.origin.y -= heightDiff

        if let screen = NSScreen.main {
            let sf = screen.visibleFrame
            newFrame.origin.x = min(max(newFrame.origin.x, sf.minX), sf.maxX - newFrame.width)
            newFrame.origin.y = min(max(newFrame.origin.y, sf.minY), sf.maxY - newFrame.height)
        }

        setFrame(newFrame, display: true, animate: true)
        savePanelSize()
    }
}
