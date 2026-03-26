import AppKit

class EditViewController: NSViewController, NSTextViewDelegate {

    // MARK: - Subviews
    private var textScrollView: NSScrollView!
    private var textView: NSTextView!
    private var placeholderLabel: NSTextField!
    private var colorControl: NSSegmentedControl!
    private var speedSlider: NSSlider!
    private var speedLabel: NSTextField!
    private var fontSlider: NSSlider!
    private var fontLabel: NSTextField!
    private var startButton: NSButton!

    // MARK: - State
    private var selectedColor: NSColor = .white
    private var currentSpeed: Double = 25
    private var currentFontSize: CGFloat = 34

    // MARK: - Lifecycle

    override func loadView() {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1).cgColor
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    // MARK: - UI Construction

    private func buildUI() {
        // ── App icon + title ──────────────────────────────────────────
        let iconLabel = NSTextField(labelWithString: "🎬")
        iconLabel.font = NSFont.systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)

        let titleLabel = NSTextField(labelWithString: "Teleprompter")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 26)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subtitleLabel = NSTextField(labelWithString: "Type or paste your script — text scrolls below the camera.")
        subtitleLabel.font = NSFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = NSColor(white: 0.45, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        let bylineLabel = NSTextField(labelWithString: "A tool by Nikoloz Sharvashidze")
        bylineLabel.font = NSFont.systemFont(ofSize: 11)
        bylineLabel.textColor = NSColor(white: 0.30, alpha: 1)
        bylineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bylineLabel)

        // ── Text area ─────────────────────────────────────────────────
        textScrollView = NSScrollView()
        textScrollView.hasVerticalScroller = true
        textScrollView.autohidesScrollers = true
        textScrollView.wantsLayer = true
        textScrollView.layer?.cornerRadius = 10
        textScrollView.layer?.borderWidth = 1
        textScrollView.layer?.borderColor = NSColor(white: 0.22, alpha: 1).cgColor
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textScrollView)

        textView = NSTextView()
        textView.delegate = self
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.textColor = NSColor(white: 0.88, alpha: 1)
        textView.backgroundColor = NSColor(red: 0.10, green: 0.10, blue: 0.14, alpha: 1)
        textView.insertionPointColor = NSColor(red: 0.40, green: 0.80, blue: 1.0, alpha: 1)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textScrollView.documentView = textView

        // Placeholder label overlaid on top of the text view
        placeholderLabel = NSTextField(labelWithString: "Paste or type your script here…")
        placeholderLabel.font = NSFont.systemFont(ofSize: 14)
        placeholderLabel.textColor = NSColor(white: 0.35, alpha: 1)
        placeholderLabel.isEditable = false
        placeholderLabel.isBezeled = false
        placeholderLabel.drawsBackground = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.addSubview(placeholderLabel)

        // ── Controls panel ────────────────────────────────────────────
        let panel = NSView()
        panel.wantsLayer = true
        panel.layer?.backgroundColor = NSColor(red: 0.10, green: 0.10, blue: 0.14, alpha: 1).cgColor
        panel.layer?.cornerRadius = 10
        panel.layer?.borderWidth = 1
        panel.layer?.borderColor = NSColor(white: 0.20, alpha: 1).cgColor
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)

        // Color
        let colorTitle = makeLabel("Text Color")
        panel.addSubview(colorTitle)

        colorControl = NSSegmentedControl(labels: ["White", "Yellow", "Green"], trackingMode: .selectOne, target: self, action: #selector(colorChanged))
        colorControl.selectedSegment = 0
        colorControl.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(colorControl)

        // Speed
        speedLabel = makeLabel("Speed: 25")
        panel.addSubview(speedLabel)

        speedSlider = NSSlider(value: 25, minValue: 1, maxValue: 100, target: self, action: #selector(speedChanged))
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(speedSlider)

        // Font size
        fontLabel = makeLabel("Font: 34px")
        panel.addSubview(fontLabel)

        fontSlider = NSSlider(value: 34, minValue: 16, maxValue: 80, target: self, action: #selector(fontChanged))
        fontSlider.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(fontSlider)

        // ── Start button ──────────────────────────────────────────────
        startButton = NSButton(title: "  ▶  Start  ", target: self, action: #selector(startTapped))
        startButton.bezelStyle = .rounded
        startButton.wantsLayer = true
        startButton.layer?.backgroundColor = NSColor(red: 0.15, green: 0.65, blue: 0.35, alpha: 1).cgColor
        startButton.layer?.cornerRadius = 8
        startButton.contentTintColor = .white
        startButton.font = NSFont.boldSystemFont(ofSize: 14)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)

        // ── Constraints ───────────────────────────────────────────────
        NSLayoutConstraint.activate([
            bylineLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            bylineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            iconLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            titleLabel.centerYAnchor.constraint(equalTo: iconLabel.centerYAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 10),

            subtitleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            textScrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            textScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textScrollView.bottomAnchor.constraint(equalTo: panel.topAnchor, constant: -14),

            placeholderLabel.topAnchor.constraint(equalTo: textScrollView.topAnchor, constant: 14),
            placeholderLabel.leadingAnchor.constraint(equalTo: textScrollView.leadingAnchor, constant: 16),

            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            panel.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -14),
            panel.heightAnchor.constraint(equalToConstant: 70),

            colorTitle.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            colorTitle.centerYAnchor.constraint(equalTo: panel.centerYAnchor, constant: -14),

            colorControl.leadingAnchor.constraint(equalTo: colorTitle.trailingAnchor, constant: 8),
            colorControl.centerYAnchor.constraint(equalTo: colorTitle.centerYAnchor),

            speedLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            speedLabel.centerYAnchor.constraint(equalTo: panel.centerYAnchor, constant: 14),

            speedSlider.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: 8),
            speedSlider.centerYAnchor.constraint(equalTo: speedLabel.centerYAnchor),
            speedSlider.widthAnchor.constraint(equalToConstant: 110),

            fontLabel.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: 24),
            fontLabel.centerYAnchor.constraint(equalTo: speedLabel.centerYAnchor),

            fontSlider.leadingAnchor.constraint(equalTo: fontLabel.trailingAnchor, constant: 8),
            fontSlider.centerYAnchor.constraint(equalTo: fontLabel.centerYAnchor),
            fontSlider.widthAnchor.constraint(equalToConstant: 110),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            startButton.widthAnchor.constraint(equalToConstant: 140),
            startButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func makeLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text)
        lbl.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = NSColor(white: 0.55, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    // MARK: - Actions

    @objc private func colorChanged() {
        switch colorControl.selectedSegment {
        case 1:  selectedColor = NSColor(red: 1.0, green: 0.90, blue: 0.15, alpha: 1)
        case 2:  selectedColor = NSColor(red: 0.20, green: 0.90, blue: 0.35, alpha: 1)
        default: selectedColor = .white
        }
    }

    @objc private func speedChanged() {
        currentSpeed = speedSlider.doubleValue
        speedLabel.stringValue = "Speed: \(Int(currentSpeed))"
    }

    @objc private func fontChanged() {
        currentFontSize = CGFloat(fontSlider.doubleValue)
        fontLabel.stringValue = "Font: \(Int(currentFontSize))px"
    }

    @objc private func startTapped() {
        let text = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            shake(textScrollView)
            return
        }
        let promptVC = PromptViewController(
            script: text,
            color: selectedColor,
            speed: currentSpeed,
            fontSize: currentFontSize
        )
        view.window?.contentViewController = promptVC
    }

    private func shake(_ v: NSView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values = [0, -8, 8, -8, 8, -4, 4, 0]
        anim.duration = 0.35
        v.layer?.add(anim, forKey: "shake")
    }

    // MARK: - NSTextViewDelegate

    func textDidChange(_ notification: Notification) {
        placeholderLabel.isHidden = !textView.string.isEmpty
    }
}
