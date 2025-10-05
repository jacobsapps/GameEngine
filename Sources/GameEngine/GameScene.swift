import SwiftUI
#if os(iOS)
import CoreMotion
#endif

@MainActor
open class GameScene {
    public var gameObjects: [GameObject] = []
    public var isActive: Bool = true
    public var camera: Camera = Camera()
    public var screenSize: CGSize = .zero
    public var accelerometerData: (x: Double, y: Double, z: Double) = (0, 0, 0)
    
    internal var objectsToAdd: [GameObject] = []
    internal var objectsToRemove: [GameObject] = []
    #if os(iOS)
    private var motionManager: CMMotionManager?
    private var accelerometerEnabled = false
    #endif
    
    public init() {}
    
    open func setup() {
        // Override in subclasses
    }
    
    open func update(deltaTime: Double) {
        camera.updateShake(deltaTime: deltaTime)
        
        processQueuedChanges()
        
        for gameObject in gameObjects where gameObject.isActive {
            gameObject.update(deltaTime: deltaTime)
        }
        
        removeInactiveObjects()
    }
    
    open func render(context: GraphicsContext, size: CGSize) {
        screenSize = size
        camera.screenSize = size
        
        var ctx = context
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: -camera.position.x, y: -camera.position.y)
        transform = transform.scaledBy(x: camera.zoom, y: camera.zoom)
        ctx.transform = transform
        
        let sortedObjects = gameObjects
            .filter { $0.isActive && camera.isVisible($0) }
            .sorted { $0.layer < $1.layer }
        
        for gameObject in sortedObjects {
            gameObject.render(context: ctx)
        }
    }
    
    open func handleInput(at location: CGPoint) {
        // Override in subclasses
    }
    
    open func handleKeyPress(_ key: KeyEquivalent) {
        // Override in subclasses
    }
    
    open func handleKeyRelease(_ key: KeyEquivalent) {
        // Override in subclasses
    }
    
    public func enableAccelerometer() {
        #if os(iOS)
        guard !accelerometerEnabled else { return }
        accelerometerEnabled = true
        motionManager = CMMotionManager()
        guard let mm = motionManager, mm.isAccelerometerAvailable else { return }
        mm.accelerometerUpdateInterval = 1.0 / 60.0
        mm.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            self?.accelerometerData = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
        }
        #endif
    }
    
    public func disableAccelerometer() {
        #if os(iOS)
        accelerometerEnabled = false
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
        accelerometerData = (0, 0, 0)
        #endif
    }
    
    public func addGameObject(_ gameObject: GameObject) {
        objectsToAdd.append(gameObject)
    }
    
    public func removeGameObject(_ gameObject: GameObject) {
        objectsToRemove.append(gameObject)
    }
    
    public func removeInactiveObjects() {
        gameObjects.removeAll { !$0.isActive }
    }
    
    public func findGameObjects<T: GameObject>(ofType type: T.Type) -> [T] {
        return gameObjects.compactMap { $0 as? T }
    }
    
    public func findNearby(_ object: GameObject, radius: Double) -> [PhysicsObject] {
        let radiusSquared = radius * radius
        return gameObjects.compactMap { other in
            guard let physics = other as? PhysicsObject, other !== object, other.isActive else { return nil }
            let dx = other.position.x - object.position.x
            let dy = other.position.y - object.position.y
            return (dx * dx + dy * dy) <= radiusSquared ? physics : nil
        }
    }
    
    private func processQueuedChanges() {
        for object in objectsToAdd {
            object.scene = self
            gameObjects.append(object)
        }
        objectsToAdd.removeAll()
        
        for object in objectsToRemove {
            gameObjects.removeAll { $0 === object }
        }
        objectsToRemove.removeAll()
    }
}
