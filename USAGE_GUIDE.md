# GameEngine Usage Guide

## Creating Custom GameObjects

### Basic Custom GameObject
```swift
import GameEngine

class Bullet: GameObject {
    init(at position: CGPoint, direction: CGPoint) {
        super.init(position: position, size: CGSize(width: 4, height: 10))
        self.velocity = direction
    }
    
    override func update(deltaTime: Double) {
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime
        
        if position.x < 0 { isActive = false }
    }
    
    override func render(context: GraphicsContext) {
        let rect = CGRect(origin: position, size: size)
        context.fill(Path(rect), with: .color(.yellow))
    }
}
```

### GameObject Properties
- **`scene`** - Reference to current scene
- **`position`**, **`size`** - Position and dimensions
- **`layer`** - Render order (higher = in front)
- **`isActive`** - Set to false to remove from game

### Scene Features
- **`scene.screenSize`** - Screen dimensions
- **`scene.camera`** - Camera for scrolling/following
- **`scene.gameObjects`** - All objects in scene
- **`scene.addGameObject()`** - Add new objects
- **`scene.findNearby(object, radius)`** - Find nearby physics objects (optimized)
- **`scene.findGameObjects(ofType:)`** - Find objects of specific type

## Camera & Scrolling

### Follow a Player:
```swift
override func update(deltaTime: Double) {
    super.update(deltaTime: deltaTime)
    
    camera.follow(player, smoothing: 0.1)
    camera.constrainTo(bounds: levelBounds)
}
```

### Camera Effects:
```swift
camera.shake(intensity: 10, duration: 0.5)
camera.zoom = 2.0  // Automatically clamped between 0.1 and 10.0
camera.position = CGPoint(x: 100, y: 200)
```

## Input Handling

### Handle Taps:
```swift
override func handleInput(at location: CGPoint) {
    let bullet = Bullet(at: player.position, direction: location)
    addGameObject(bullet)
}
```

## Layer System

Render layers (lower = behind, higher = in front):
```swift
background.layer = -2
ground.layer = -1
enemies.layer = 0
player.layer = 1
bullets.layer = 2
ui.layer = 10
```

## Complete Game Architecture

### Scene Class:
```swift
class MyGameScene: GameScene {
    private var player: Player!
    
    override func setup() {
        super.setup()
        setupPlayer()
        setupEnemies()
    }
    
    private func setupPlayer() {
        player = Player(at: CGPoint(x: 100, y: 400))
        addGameObject(player)
    }
    
    override func update(deltaTime: Double) {
        super.update(deltaTime: deltaTime)
        camera.follow(player)
        checkCollisions()
    }
    
    override func handleInput(at location: CGPoint) {
        player.shootAt(location)
    }
}
```

### SwiftUI View:
```swift
struct MyGame: View {
    var body: some View {
        GameView(scene: MyGameScene())
            .background(.black)
    }
}
```

## Collision Detection

### Basic (checks all objects):
```swift
for object in scene.gameObjects {
    if self.intersects(with: object) && object !== self {
        handleCollision(with: object)
    }
}
```

### Optimized (spatial search):
```swift
// Much faster for many objects!
for nearby in scene.findNearby(self, radius: 100) {
    if self.intersects(with: nearby) {
        handleCollision(with: nearby)
    }
}
```

### Type-specific:
```swift
for enemy in scene.findGameObjects(ofType: Enemy.self) {
    if player.intersects(with: enemy) {
        handleCollision(with: enemy)
    }
}
```

## Best Practices

### Performance:
- ✅ Use `findNearby()` for collision detection with many objects
- ✅ Set `isActive = false` to remove objects
- ✅ Engine automatically culls off-screen objects during render

### GameObject Creation:
- ✅ Create custom GameObjects in your app code
- ✅ Use `scene.addGameObject()` to add objects
- ✅ Use layers for proper rendering order

### State Management:
```swift
class GameManager: GameObject {
    private var score = 0
    private var lives = 3
    
    override func update(deltaTime: Double) {
        // Game state logic
    }
}
```

## Physics Objects

For objects that need collision detection, use `PhysicsObject`:

```swift
class Enemy: PhysicsObject {
    init(at position: CGPoint) {
        super.init(position: position, size: CGSize(width: 30, height: 30))
    }
    
    override func update(deltaTime: Double) {
        // Physics and collision logic
        for nearby in scene?.findNearby(self, radius: 50) ?? [] {
            if intersects(with: nearby) {
                // Handle collision
            }
        }
    }
}
```

This architecture keeps things simple and predictable!
