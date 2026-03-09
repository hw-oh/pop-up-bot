#!/usr/bin/env swift
import AppKit

let sizes: [(CGFloat, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let inset = size * 0.05
    let cornerRadius = size * 0.2

    let path = NSBezierPath(roundedRect: rect.insetBy(dx: inset, dy: inset),
                            xRadius: cornerRadius, yRadius: cornerRadius)
    let gradient = NSGradient(starting: NSColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0),
                              ending: NSColor(red: 0.06, green: 0.35, blue: 0.78, alpha: 1.0))!
    gradient.draw(in: path, angle: -45)

    let bubbleW = size * 0.5
    let bubbleH = size * 0.35
    let bubbleX = (size - bubbleW) / 2
    let bubbleY = size * 0.34
    let bubbleRect = NSRect(x: bubbleX, y: bubbleY, width: bubbleW, height: bubbleH)
    let bubble = NSBezierPath(roundedRect: bubbleRect, xRadius: bubbleH * 0.3, yRadius: bubbleH * 0.3)
    NSColor.white.setFill()
    bubble.fill()

    let tail = NSBezierPath()
    let tx = bubbleRect.minX + bubbleW * 0.18
    tail.move(to: NSPoint(x: tx, y: bubbleRect.minY))
    tail.line(to: NSPoint(x: tx - size * 0.06, y: bubbleRect.minY - size * 0.08))
    tail.line(to: NSPoint(x: tx + size * 0.1, y: bubbleRect.minY))
    tail.close()
    tail.fill()

    let dotR = size * 0.03
    let dotY = bubbleRect.midY
    let spacing = bubbleW * 0.2
    NSColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0).setFill()
    for i in -1...1 {
        let cx = bubbleRect.midX + CGFloat(i) * spacing
        NSBezierPath(ovalIn: NSRect(x: cx - dotR, y: dotY - dotR, width: dotR * 2, height: dotR * 2)).fill()
    }

    image.unlockFocus()
    return image
}

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0])
let projectDir = scriptURL.deletingLastPathComponent().deletingLastPathComponent()
let iconsetPath = projectDir.appendingPathComponent("Resources/AppIcon.iconset")
let fm = FileManager.default
try? fm.removeItem(at: iconsetPath)
try fm.createDirectory(at: iconsetPath, withIntermediateDirectories: true)

for (size, name) in sizes {
    let img = drawIcon(size: size)
    guard let tiff = img.tiffRepresentation,
          let bmp = NSBitmapImageRep(data: tiff),
          let png = bmp.representation(using: .png, properties: [:]) else { continue }
    try png.write(to: iconsetPath.appendingPathComponent("\(name).png"))
}

let icnsPath = projectDir.appendingPathComponent("Resources/AppIcon.icns")
let proc = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
proc.arguments = ["-c", "icns", iconsetPath.path, "-o", icnsPath.path]
try proc.run()
proc.waitUntilExit()
try? fm.removeItem(at: iconsetPath)
print(proc.terminationStatus == 0 ? "Icon created: \(icnsPath.path)" : "iconutil failed")
