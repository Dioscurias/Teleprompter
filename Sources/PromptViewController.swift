import AppKit

class PromptViewController: NSViewController {

    // MARK: - Config
    private let script: String
    private var textColor: NSColor
    private var speed: Double
    private var fontSize: CGFloat

    // MARK: - Subviews
    private var scrollView: NSScrollView!
    private var textView: NSTextView!
    private var controlBar: NSView!
    private var playPauseButton: NSButton!

    // MARK: - State
    private var isPlaying = false
    private var scrollTimer: Timer?

    // MARK: - Init

    init(script: String, color: NSColor, speed: Double, fontSize: CGFloat) {
        self.script = script
        self.textColor = color
        self.speed = speed
        self.fontSize = fontSize
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(script:color:speed:fontSize:)")
    }

    // MARK: - Lifecycle

    override func loadView() {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.black.cgColor
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildScrollView()
        buildControlBar()
        buildFades()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Ensure text container is sized to the scroll view width
        let w = scrollView.frame.width
        textView.textContainer?.containerSize = NSSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        // Scroll to top
        scrollView.contentView.scroll(to: .zero)
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        stopScrolling()
    }

    // MARK: - Build UI

    private func buildScrollView() {
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.backgroundColor = .black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .black
        textView.textColor = textColor
        textView.font = NSFont.boldSystemFont(ofSize: fontSize)
        textView.string = script
        textView.textContainerInset = NSSize(width: 48, height: 48)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 700, height: CGFloat.greatestFiniteMagnitude)

        scrollView.documentView = textView

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func buildControlBar() {
        controlBar = NSView()
        controlBar.wantsLayer = true
        controlBar.layer?.backgroundColor = NSColor(white: 0.08, alpha: 0.95).cgColor
        controlBar.layer?.cornerRadius = 14
        controlBar.layer?.borderWidth = 1
        controlBar.layer?.borderColor = NSColor(white: 0.22, alpha: 1).cgColor
        controlBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlBar)

        let back    = barButton("← Back",    action: #selector(goBack))
        let restart = barButton("↺",          action: #selector(restart))
        let slower  = barButton("−  Slower",  action: #selector(slower))
        playPauseButton = barButton("▶  Play", action: #selector(togglePlay))
        let faster  = barButton("Faster  +",  action: #selector(faster))
        let fontSm  = barButton("A−",         action: #selector(fontSmaller))
        let fontBg  = barButton("A+",         action: #selector(fontBigger))

        let sep1 = separator()
        let sep2 = separator()

        let stack = NSStackView(views: [back, restart, sep1, slower, playPauseButton, faster, sep2, fontSm, fontBg])
        stack.orientation = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        controlBar.addSubview(stack)

        NSLayoutConstraint.activate([
            controlBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            controlBar.heightAnchor.constraint(equalToConstant: 46),

            stack.centerXAnchor.constraint(equalTo: controlBar.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: controlBar.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: controlBar.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: controlBar.trailingAnchor, constant: -14),
        ])
    }

    private func buildFades() {
        // Top fade: black → clear
        let topFade = gradientView(colors: [NSColor.black, .clear])
        view.addSubview(topFade)

        // Bottom fade: clear → black (leaves room for the control bar)
        let bottomFade = gradientView(colors: [.clear, NSColor.black])
        view.addSubview(bottomFade)

        NSLayoutConstraint.activate([
            topFade.topAnchor.constraint(equalTo: view.topAnchor),
            topFade.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFade.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFade.heightAnchor.constraint(equalToConstant: 70),

            bottomFade.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomFade.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFade.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFade.heightAnchor.constraint(equalToConstant: 110),
        ])
    }

    // MARK: - Helpers

    private func barButton(_ title: String, action: Selector) -> NSButton {
        let btn = NSButton(title: title, target: self, action: action)
        btn.isBordered = false
        btn.wantsLayer = true
        btn.layer?.backgroundColor = NSColor(white: 0.18, alpha: 1).cgColor
        btn.layer?.cornerRadius = 7
        btn.contentTintColor = NSColor(white: 0.85, alpha: 1)
        btn.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        return btn
    }

    private func separator() -> NSView {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor(white: 0.25, alpha: 1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 1),
            v.heightAnchor.constraint(equalToConstant: 22),
        ])
        return v
    }

    private func gradientView(colors: [NSColor]) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.frame = CGRect(x: 0, y: 0, width: 2000, height: 110)
        container.layer?.addSublayer(gradient)
        return container
    }

    // MARK: - Scrolling

    private var pixelsPerTick: CGFloat {
        CGFloat(speed) * 0.018
    }

    private func startScrolling() {
        guard !isPlaying else { return }
        isPlaying = true
        playPauseButton.title = "⏸  Pause"
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(scrollTimer!, forMode: .common)
    }

    private func stopScrolling() {
        guard isPlaying else { return }
        isPlaying = false
        playPauseButton.title = "▶  Play"
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    private func tick() {
        guard let docView = scrollView.documentView else { return }
        let clip = scrollView.contentView
        let currentY = clip.bounds.origin.y
        let maxY = max(0, docView.frame.height - scrollView.frame.height)
        if currentY >= maxY {
            stopScrolling()
            return
        }
        let newY = min(currentY + pixelsPerTick, maxY)
        clip.scroll(to: NSPoint(x: 0, y: newY))
        scrollView.reflectScrolledClipView(clip)
    }

    // MARK: - Actions

    @objc private func togglePlay() {
        if isPlaying { stopScrolling() } else { startScrolling() }
    }

    @objc private func restart() {
        stopScrolling()
        scrollView.contentView.scroll(to: .zero)
        scrollView.reflectScrolledClipView(scrollView.contentView)
        startScrolling()
    }

    @objc private func faster() {
        speed = min(speed + 5, 100)
    }

    @objc private func slower() {
        speed = max(speed - 5, 1)
    }

    @objc private func fontBigger() {
        fontSize = min(fontSize + 4, 120)
        applyFont()
    }

    @objc private func fontSmaller() {
        fontSize = max(fontSize - 4, 14)
        applyFont()
    }

    private func applyFont() {
        textView.font = NSFont.boldSystemFont(ofSize: fontSize)
        if let tc = textView.textContainer {
            textView.layoutManager?.ensureLayout(for: tc)
        }
    }

    @objc private func goBack() {
        stopScrolling()
        view.window?.contentViewController = EditViewController()
    }
}
