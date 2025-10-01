import SwiftUI
import Combine

@MainActor
public class GameEngine: ObservableObject {
    @Published public var currentScene: GameScene?
    @Published public var isRunning: Bool = false
    
    private var lastUpdateTime: Date = Date()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        lastUpdateTime = Date()
        currentScene?.setup()
    }
    
    public func stop() {
        isRunning = false
    }
    
    public func setScene(_ scene: GameScene) {
        currentScene = scene
        if isRunning {
            scene.setup()
        }
    }
    
    public func update(currentTime: Date) {
        guard isRunning, let scene = currentScene else { return }
        
        let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = currentTime
        
        scene.update(deltaTime: deltaTime)
    }
    
    public func render(context: GraphicsContext, size: CGSize) {
        guard isRunning, let scene = currentScene else { return }
        
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(.black)
        )
        
        scene.render(context: context, size: size)
    }
    
    public func handleInput(at location: CGPoint) {
        guard isRunning, let scene = currentScene else { return }
        
        // Convert screen coordinates to world coordinates
        let worldLocation = scene.camera.screenToWorld(location)
        scene.handleInput(at: worldLocation)
    }
}
