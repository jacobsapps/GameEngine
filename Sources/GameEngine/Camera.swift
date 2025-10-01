import SwiftUI

@MainActor
public class Camera {
    public var position: CGPoint = .zero
    public var zoom: Double = 1.0 {
        didSet {
            zoom = max(0.1, min(10.0, zoom))
        }
    }
    public var screenSize: CGSize = .zero
    
    public init() {}
    
    // Follow a target (like a player)
    public func follow(_ target: GameObject, smoothing: Double = 0.1) {
        // Visible world size depends on zoom
        let halfWidth = (screenSize.width / zoom) / 2
        let halfHeight = (screenSize.height / zoom) / 2
        
        let targetPosition = CGPoint(
            x: target.position.x - halfWidth,
            y: target.position.y - halfHeight
        )
        
        // Smooth following
        position.x += (targetPosition.x - position.x) * smoothing
        position.y += (targetPosition.y - position.y) * smoothing
    }
    
    // Set camera to follow target immediately (no smoothing)
    public func snapTo(_ target: GameObject) {
        let halfWidth = (screenSize.width / zoom) / 2
        let halfHeight = (screenSize.height / zoom) / 2
        position = CGPoint(
            x: target.position.x - halfWidth,
            y: target.position.y - halfHeight
        )
    }
    
    // Constrain camera to bounds (for level boundaries)
    public func constrainTo(bounds: CGRect) {
        let viewWidth = screenSize.width / zoom
        let viewHeight = screenSize.height / zoom
        position.x = max(bounds.minX, min(bounds.maxX - viewWidth, position.x))
        position.y = max(bounds.minY, min(bounds.maxY - viewHeight, position.y))
    }
    
    // Convert world position to screen position
    public func worldToScreen(_ worldPoint: CGPoint) -> CGPoint {
        return CGPoint(
            x: (worldPoint.x - position.x) * zoom,
            y: (worldPoint.y - position.y) * zoom
        )
    }
    
    // Convert screen position to world position
    public func screenToWorld(_ screenPoint: CGPoint) -> CGPoint {
        return CGPoint(
            x: (screenPoint.x / zoom) + position.x,
            y: (screenPoint.y / zoom) + position.y
        )
    }
    
    // Check if object is visible on screen (for culling)
    public func isVisible(_ object: GameObject) -> Bool {
        let viewWidth = screenSize.width / zoom
        let viewHeight = screenSize.height / zoom
        let margin = 50.0 / zoom
        let screenBounds = CGRect(
            x: position.x - margin,
            y: position.y - margin,
            width: viewWidth + margin * 2,
            height: viewHeight + margin * 2
        )
        return screenBounds.intersects(object.bounds)
    }
    
    // Camera shake effect
    private var shakeIntensity: Double = 0
    private var shakeDuration: Double = 0
    private var shakeTimer: Double = 0
    
    public func shake(intensity: Double, duration: Double) {
        shakeIntensity = intensity
        shakeDuration = duration
        shakeTimer = 0
    }
    
    public func updateShake(deltaTime: Double) {
        if shakeTimer < shakeDuration {
            shakeTimer += deltaTime
            
            // Random offset based on remaining shake intensity
            let progress = shakeTimer / shakeDuration
            let currentIntensity = shakeIntensity * (1.0 - progress)
            
            if currentIntensity > 0 {
                position.x += Double.random(in: -currentIntensity...currentIntensity)
                position.y += Double.random(in: -currentIntensity...currentIntensity)
            }
        }
    }
}
