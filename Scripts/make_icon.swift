#!/usr/bin/env swift
import AppKit

// Draws the Teleprompter app icon: dark bg, film-strip side bars, play triangle, text lines
func makeIcon(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let r = size * 0.13   // corner radius

    // Background: deep navy
    ctx.setFillColor(NSColor(red: 0.06, green: 0.07, blue: 0.13, alpha: 1).cgColor)
    let bgPath = CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(bgPath)
    ctx.fillPath()

    let pad = size * 0.07

    // Film-strip left bar
    ctx.setFillColor(NSColor(red: 0.14, green: 0.14, blue: 0.22, alpha: 1).cgColor)
    ctx.fill(CGRect(x: pad, y: pad, width: size * 0.12, height: size - pad * 2))

    // Film-strip right bar
    ctx.fill(CGRect(x: size - pad - size * 0.12, y: pad, width: size * 0.12, height: size - pad * 2))

    // Perforations (left)
    ctx.setFillColor(NSColor(red: 0.06, green: 0.07, blue: 0.13, alpha: 1).cgColor)
    let perfH = size * 0.07
    let perfW = size * 0.07
    let perfX = pad + size * 0.025
    let perfCount = 5
    let spacing = (size - pad * 2 - perfH) / CGFloat(perfCount - 1)
    for i in 0..<perfCount {
        let y = pad + CGFloat(i) * spacing
        let pRect = CGRect(x: perfX, y: y, width: perfW, height: perfH)
        ctx.fill(CGRect(
            x: pRect.minX - 1, y: pRect.minY - 1,
            width: pRect.width + 2, height: pRect.height + 2
        ))
        let prRect = CGRect(x: pRect.minX + 1, y: pRect.minY + 1, width: pRect.width - 2, height: pRect.height - 2)
        ctx.fill(prRect)
    }
    // Perforations (right)
    let perfXR = size - pad - size * 0.12 + size * 0.025
    for i in 0..<perfCount {
        let y = pad + CGFloat(i) * spacing
        let prRect = CGRect(x: perfXR + 1, y: y + 1, width: perfW - 2, height: perfH - 2)
        ctx.fill(prRect)
    }

    // Inner screen area
    ctx.setFillColor(NSColor(red: 0.09, green: 0.09, blue: 0.15, alpha: 1).cgColor)
    let innerX = pad + size * 0.12 + size * 0.03
    let innerW = size - 2 * (pad + size * 0.12 + size * 0.03)
    let innerY = pad + size * 0.06
    let innerH = size - 2 * (pad + size * 0.06)
    ctx.fill(CGRect(x: innerX, y: innerY, width: innerW, height: innerH))

    // Play triangle (centered, slightly above middle)
    let triCenter = CGPoint(x: size * 0.5, y: size * 0.52)
    let triR = size * 0.14
    ctx.setFillColor(NSColor(red: 0.15, green: 0.72, blue: 0.38, alpha: 1).cgColor)
    let triPath = CGMutablePath()
    triPath.move(to: CGPoint(x: triCenter.x - triR, y: triCenter.y - triR))
    triPath.addLine(to: CGPoint(x: triCenter.x + triR * 1.1, y: triCenter.y))
    triPath.addLine(to: CGPoint(x: triCenter.x - triR, y: triCenter.y + triR))
    triPath.closeSubpath()
    ctx.addPath(triPath)
    ctx.fillPath()

    // Text lines below triangle (like script lines)
    ctx.setFillColor(NSColor(white: 1, alpha: 0.18).cgColor)
    let lineY1 = triCenter.y - triR * 2.8
    let lineH  = size * 0.03
    let lineX  = innerX + size * 0.04
    ctx.fill(CGRect(x: lineX, y: lineY1, width: innerW * 0.80, height: lineH))
    ctx.fill(CGRect(x: lineX, y: lineY1 - lineH * 2.2, width: innerW * 0.60, height: lineH))

    ctx.setFillColor(NSColor(white: 1, alpha: 0.10).cgColor)
    let lineY2 = triCenter.y - triR * 1.7
    ctx.fill(CGRect(x: lineX, y: lineY2 - lineH * 2.2, width: innerW * 0.72, height: lineH))

    // Small text lines below triangle
    ctx.setFillColor(NSColor(white: 1, alpha: 0.14).cgColor)
    let lineYB = triCenter.y - triR * 0.9
    ctx.fill(CGRect(x: lineX, y: lineYB, width: innerW * 0.68, height: lineH))
    ctx.fill(CGRect(x: lineX, y: lineYB - lineH * 2.2, width: innerW * 0.50, height: lineH))

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
