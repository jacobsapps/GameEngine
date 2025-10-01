import SwiftUI

@MainActor
open class GameObject {
    public var position: CGPoint
    public var size: CGSize
    
    // Set this to false to remove the object in the next render pass
    public var isActive: Bool = true
    
    // Layer system for rendering order (higher = in front)
    public var layer: Int = 0
    
    public weak var scene: GameScene?
    
    public init(position: CGPoint, size: CGSize = CGSize(width: 32, height: 32)) {
        self.position = position
        self.size = size
    }
    
    open func update(deltaTime: Double) {
        // Override in subclasses
    }
    
    open func render(context: GraphicsContext) {
        // Default rendering - simple rectangle
        context.fill(
            Path(bounds),
            with: .color(.blue)
        )
    }
    
    public var bounds: CGRect {
        CGRect(origin: position, size: size)
    }
}

@MainActor
open class PhysicsObject: GameObject {
    public var velocity: CGPoint = .zero
    
    public func intersects(with other: PhysicsObject) -> Bool {
        return bounds.intersects(other.bounds)
    }
}
