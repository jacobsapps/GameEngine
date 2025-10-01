import SwiftUI

public struct GameView: View {
    @StateObject private var engine = GameEngine()
    private let scene: GameScene
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0/60.0)) { context in
            Canvas { graphicsContext, size in
                engine.update(currentTime: context.date)
                engine.render(context: graphicsContext, size: size)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        engine.handleInput(at: value.location)
                    }
            )
        }
        .onAppear {
            engine.setScene(scene)
            engine.start()
        }
        .onDisappear {
            engine.stop()
        }
    }
}
