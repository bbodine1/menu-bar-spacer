#if canImport(AppKit)
import AppKit

final class SpacerStatusItemView: NSView {
    private var widthConstraint: NSLayoutConstraint?
    var onClick: (() -> Void)?

    init(width: CGFloat) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 24))
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        widthConstraint = widthAnchor.constraint(equalToConstant: width)
        widthConstraint?.isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateWidth(_ width: CGFloat) {
        widthConstraint?.constant = width
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onClick?()
    }
}
#endif
