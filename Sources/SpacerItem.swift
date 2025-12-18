import Foundation
import CoreGraphics

/// Represents a spacer item that will be rendered into the menu bar.
public struct SpacerItem: Codable, Identifiable, Equatable {
    public let id: UUID
    public var width: CGFloat
    public var order: Int

    public init(id: UUID = UUID(), width: CGFloat, order: Int) {
        self.id = id
        self.width = width
        self.order = order
    }
}
