#!/usr/bin/env swift
import AppKit

// Draws a flat, industrial broadcast-prompter mark.
func makeIcon(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let r = size * 0.16
    let graphite = NSColor(red: 0.035, green: 0.043, blue: 0.047, alpha: 1).cgColor
    let steel = NSColor(red: 0.12, green: 0.14, blue: 0.15, alpha: 1).cgColor
    let bone = NSColor(red: 0.88, green: 0.89, blue: 0.87, alpha: 1).cgColor
    let muted = NSColor(red: 0.43, green: 0.46, blue: 0.46, alpha: 1).cgColor
    let tallyOrange = NSColor(red: 0.95, green: 0.29, blue: 0.09, alpha: 1).cgColor

    ctx.setFillColor(graphite)
    let bgPath = CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(bgPath)
    ctx.fillPath()

    // Thin equipment frame.
    let frame = CGRect(x: size * 0.09, y: size * 0.09, width: size * 0.82, height: size * 0.82)
    ctx.setStrokeColor(steel)
    ctx.setLineWidth(max(1, size * 0.012))
    ctx.addPath(CGPath(roundedRect: frame, cornerWidth: size * 0.07, cornerHeight: size * 0.07, transform: nil))
    ctx.strokePath()

    // Prompter screen: a clipped, forward-facing trapezoid.
    let prompterScreen = CGMutablePath()
    prompterScreen.move(to: CGPoint(x: size * 0.25, y: size * 0.69))
    prompterScreen.addLine(to: CGPoint(x: size * 0.75, y: size * 0.69))
    prompterScreen.addLine(to: CGPoint(x: size * 0.69, y: size * 0.37))
    prompterScreen.addLine(to: CGPoint(x: size * 0.31, y: size * 0.37))
    prompterScreen.closeSubpath()
    ctx.setFillColor(steel)
    ctx.addPath(prompterScreen)
    ctx.fillPath()
    ctx.setStrokeColor(bone)
    ctx.setLineJoin(.miter)
    ctx.setLineWidth(max(1.5, size * 0.027))
    ctx.addPath(prompterScreen)
    ctx.strokePath()

    // Three script lines remain readable even at 16px.
    ctx.setFillColor(bone)
    let lineHeight = max(1, size * 0.026)
    ctx.fill(CGRect(x: size * 0.36, y: size * 0.59, width: size * 0.28, height: lineHeight))
    ctx.fill(CGRect(x: size * 0.34, y: size * 0.52, width: size * 0.32, height: lineHeight))
    ctx.setFillColor(muted)
    ctx.fill(CGRect(x: size * 0.38, y: size * 0.45, width: size * 0.24, height: lineHeight))

    // Low-profile broadcast mount.
    ctx.setFillColor(bone)
    ctx.fill(CGRect(x: size * 0.475, y: size * 0.25, width: size * 0.05, height: size * 0.12))
    ctx.fill(CGRect(x: size * 0.35, y: size * 0.21, width: size * 0.30, height: size * 0.04))

    // Tally light: the single controlled accent.
    ctx.setFillColor(tallyOrange)
    ctx.fillEllipse(in: CGRect(x: size * 0.70, y: size * 0.73, width: size * 0.065, height: size * 0.065))

    img.unlockFocus()
    return img
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to save \(path)")
        return
    }
    try? data.write(to: URL(fileURLWithPath: path))
    print("Saved \(path)")
}

// Generate all required icon sizes
let sizes: [(String, CGFloat)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

for (name, size) in sizes {
    let icon = makeIcon(size: size)
    savePNG(icon, to: "\(outDir)/\(name).png")
}
