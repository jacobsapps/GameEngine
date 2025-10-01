import SwiftUI

// MARK: - Ball GameObject with SwiftUI-like modifiers
public class Ball: PhysicsObject {
    private var ballColor: Color = .blue
    private var gravity: Double = 0
    private var bounceAmount: Double = 0.8
    private var screenSize: CGSize = .zero
    
    public init(at position: CGPoint) {
        super.init(position: position, size: CGSize(width: 20, height: 20))
    }
    
    public override func update(deltaTime: Double) {
        // Apply gravity
        if gravity > 0 {
            velocity.y += gravity * deltaTime
        }
        
        // Store old position for collision response
        let oldPosition = position
        
        // Update position based on velocity
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
        
        // Check collisions with other objects
        checkObjectCollisions(oldPosition: oldPosition)
        
        // Bounce off screen boundaries if screenSize is set
        guard screenSize != .zero else { return }
        
        if position.x <= 0 || position.x >= Double(screenSize.width) - size.width {
            velocity.x *= -bounceAmount
            position.x = max(0, min(Double(screenSize.width) - size.width, position.x))
        }
        
        if position.y <= 0 || position.y >= Double(screenSize.height) - size.height {
            velocity.y *= -bounceAmount
            position.y = max(0, min(Double(screenSize.height) - size.height, position.y))
        }
    }
    
    private func checkObjectCollisions(oldPosition: CGPoint) {
        guard let scene = scene else { return }
        
        let searchRadius = max(size.width, size.height) * 3
        for object in scene.findNearby(self, radius: searchRadius) {
            if intersects(with: object) {
                handleCollision(with: object, oldPosition: oldPosition)
            }
        }
    }
    
    private func handleCollision(with other: GameObject, oldPosition: CGPoint) {
        // Simple collision response - separate objects and reverse velocity
        
        // Calculate separation direction
        let centerSelf = CGPoint(x: position.x + size.width/2, y: position.y + size.height/2)
        let centerOther = CGPoint(x: other.position.x + other.size.width/2, y: other.position.y + other.size.height/2)
        
        let deltaX = centerSelf.x - centerOther.x
        let deltaY = centerSelf.y - centerOther.y
        
        // Determine collision direction based on which axis has smaller overlap
        let overlapX = (size.width + other.size.width) / 2 - abs(deltaX)
        let overlapY = (size.height + other.size.height) / 2 - abs(deltaY)
        
        if overlapX < overlapY {
            // Horizontal collision
            if deltaX > 0 {
                // Ball is to the right, push right
                position.x = other.position.x + other.size.width + 1
            } else {
                // Ball is to the left, push left
                position.x = other.position.x - size.width - 1
            }
            velocity.x *= -bounceAmount
            
        } else {
            // Vertical collision
            if deltaY > 0 {
                // Ball is below, push down
                position.y = other.position.y + other.size.height + 1
            } else {
                // Ball is above, push up
                position.y = other.position.y - size.height - 1
            }
            velocity.y *= -bounceAmount
        }
    }
    
    public override func render(context: GraphicsContext) {
        let rect = CGRect(origin: position, size: size)
        context.fill(
            Path(ellipseIn: rect),
            with: .color(ballColor)
        )
    }
    
    // MARK: - SwiftUI-like Modifiers
    @discardableResult
    public func color(_ color: Color) -> Ball {
        self.ballColor = color
        return self
    }
    
    @discardableResult
    public func size(_ size: CGSize) -> Ball {
        self.size = size
        return self
    }
    
    @discardableResult
    public func size(width: Double, height: Double) -> Ball {
        self.size = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    public func bouncy(_ bounce: Double = 0.8) -> Ball {
        self.bounceAmount = bounce
        return self
    }
    
    @discardableResult
    public func gravity(_ gravity: Double) -> Ball {
        self.gravity = gravity
        return self
    }
    
    @discardableResult
    public func withVelocity(_ velocity: CGPoint) -> Ball {
        self.velocity = velocity
        return self
    }
    
    @discardableResult
    public func withVelocity(x: Double, y: Double) -> Ball {
        self.velocity = CGPoint(x: x, y: y)
        return self
    }
    
    // Public method to set screen bounds for bouncing
    public func setScreenSize(_ size: CGSize) {
        self.screenSize = size
    }
}

// MARK: - Box GameObject
public class Box: GameObject {
    private var boxColor: Color = .gray
    
    public init(at position: CGPoint, size: CGSize = CGSize(width: 40, height: 40)) {
        super.init(position: position, size: size)
    }
    
    public override func render(context: GraphicsContext) {
        let rect = CGRect(origin: position, size: size)
        context.fill(
            Path(rect),
            with: .color(boxColor)
        )
    }
    
    @discardableResult
    public func color(_ color: Color) -> Box {
        self.boxColor = color
        return self
    }
    
    @discardableResult
    public func size(_ size: CGSize) -> Box {
        self.size = size
        return self
    }
    
    @discardableResult
    public func size(width: Double, height: Double) -> Box {
        self.size = CGSize(width: width, height: height)
        return self
    }
}

// MARK: - Text GameObject
public class GameText: GameObject {
    private var text: String
    private var textColor: Color = .white
    private var fontSize: Double = 16
    
    public init(_ text: String, at position: CGPoint) {
        self.text = text
        super.init(position: position, size: CGSize(width: 100, height: 20))
    }
    
    public override func render(context: GraphicsContext) {
        context.draw(
            Text(text)
                .foregroundColor(textColor)
                .font(.system(size: fontSize)),
            at: CGPoint(x: position.x, y: position.y)
        )
    }
    
    @discardableResult
    public func color(_ color: Color) -> GameText {
        self.textColor = color
        return self
    }
    
    @discardableResult
    public func fontSize(_ size: Double) -> GameText {
        self.fontSize = size
        return self
    }
}

// MARK: - Convenience Extensions
public extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
