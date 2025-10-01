# GameEngine 🎮

A SwiftUI-native 2D game engine for building simple games. Built for clarity and ease of use.

## ✨ Quick Start

### 1. Add to your project
```swift
// In Package.swift
dependencies: [
    .package(url: "path/to/GameEngine", branch: "main")
]
```

### 2. Create your first game
```swift
import SwiftUI
import GameEngine

class SimpleScene: GameScene {
    override func setup() {
        let ball = Ball(at: CGPoint(x: 100, y: 100))
            .bouncy()
            .color(.red)
        ball.setScreenSize(screenSize)
        addGameObject(ball)
    }
}

struct ContentView: View {
    var body: some View {
        GameView(scene: SimpleScene())
    }
}
```

## 🎯 Core Concepts

### GameScene
Create a custom scene by subclassing `GameScene`:

```swift
class MyGameScene: GameScene {
    override func setup() {
        // Create your game objects here
        let player = Ball(at: CGPoint(x: 100, y: 100))
        addGameObject(player)
    }
    
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
        // Custom game logic here
    }
    
    override func handleInput(at location: CGPoint) {
        // Handle taps/clicks
    }
}
```

### GameObjects
GameObjects represent things in your game:

```swift
Ball(at: CGPoint(x: 100, y: 100))
    .size(width: 20, height: 20)
    .color(.blue)
    .bouncy()
```

### Built-in GameObjects
- **Ball** - Circles with physics
- **Box** - Rectangles for platforms, obstacles
- **GameText** - Display text

### Custom GameObjects
```swift
class Bullet: GameObject {
    override func update(deltaTime: Double) {
        position.y -= 300 * deltaTime
        if position.y < 0 {
            isActive = false
        }
    }
    
    override func render(context: GraphicsContext) {
        let rect = CGRect(origin: position, size: size)
        context.fill(Path(rect), with: .color(.yellow))
    }
}
```

## 🎮 Camera & Scrolling

```swift
override func update(deltaTime: Double) {
    super.update(deltaTime: deltaTime)
    
    // Follow player
    camera.follow(player, smoothing: 0.1)
    
    // Constrain to bounds
    camera.constrainTo(bounds: levelBounds)
    
    // Zoom (clamped between 0.1 and 10.0)
    camera.zoom = 2.0
    
    // Shake effect
    camera.shake(intensity: 10, duration: 0.5)
}
```

## 💥 Collision Detection

### Basic collision check:
```swift
for other in scene.gameObjects {
    if self.intersects(with: other) {
        // Handle collision
    }
}
```

### Optimized nearby search:
```swift
// Only check objects within radius (much faster!)
for nearby in scene.findNearby(self, radius: 100) {
    if self.intersects(with: nearby) {
        // Handle collision
    }
}
```

### Find specific types:
```swift
for enemy in scene.findGameObjects(ofType: Enemy.self) {
    if player.intersects(with: enemy) {
        // Handle collision
    }
}
```

## 🏗️ Layer System

Control render order with layers (lower = behind, higher = in front):

```swift
background.layer = -2
ground.layer = -1
player.layer = 0
bullets.layer = 1
ui.layer = 10
```

## 📱 Platform Support

- ✅ iOS 16+
- ✅ macOS 13+
- ✅ 60fps game loop
- ✅ Touch event input

## 🤝 Philosophy

Simple, clear, easy to understand. No magic, no complexity.

---

**Made for SwiftUI developers who want to make simple 2D games.**
