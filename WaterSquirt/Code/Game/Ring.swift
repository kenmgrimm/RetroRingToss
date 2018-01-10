import CoreMotion
import Foundation
import SceneKit

class Ring {
  private let RING_START_POSITION = SCNVector3(x: 0, y: 12, z: 0)
  private let RING_BOUNCE: CGFloat = 0.8
  private let DAMPING:CGFloat = 0.15
  private let MASS:CGFloat = 0.5
  private let RING_COLLIDER_PIVOT_OFFSET: Float = 0

  private let DIST_TO_EDGE:Float = 0.1
  private let DIST_TO_CORNER:Float = 0.2
  private let CAPSULE_RADIUS:Float = 0.1
  private let CAPSULE_HEIGHT:Float = 0.3

  // Field category masks
  let squirtFieldCategory = 1 << 0
  
  // Colors
  let colorPalette: [UIColor] = [
    UIColor(rgb: 0x42c31b),
    UIColor(rgb: 0xf6ca11),
    UIColor(rgb: 0xc53333),
    UIColor(rgb: 0x2414d4),
    UIColor(rgb: 0xffffff)
  ]

  
  static func createRingNode() -> SCNNode {
    let ring = Ring()
    return ring.load()
  }
  
  private func load() -> SCNNode {
    let node = SCNNode()
    
    node.position = RING_START_POSITION
    node.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    
    let ringMesh = MeshUtils.loadModel(scene: SCNScene(named: "art.scnassets/toyMesh2.dae")!,
                                       names: ["gameRing"],
                                       color: randomColor(),
                                       enablePhysics: false)
    
    let colliderNodes = createRingColliders()
    
    let shape = SCNPhysicsShape(node: colliderNodes,
                                options: [SCNPhysicsShape.Option.keepAsCompound: true])
    node.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: shape)
    
    node.addChildNode(ringMesh)
    node.addChildNode(colliderNodes)
    
    let force = SCNVector3(x: 2.2, y: 1, z: 0.5)
    node.physicsBody?.applyForce(force, at: SCNVector3(x: 1, y: 0.25, z: 0.1), asImpulse: true)
    
    node.physicsBody?.damping = DAMPING
    node.physicsBody?.mass = MASS
    node.physicsBody?.restitution = RING_BOUNCE
    node.categoryBitMask = squirtFieldCategory
    node.physicsBody?.categoryBitMask = squirtFieldCategory

    
    return node
  }
  
  private func randomColor() -> UIColor{
    let colorIndex = Int(arc4random_uniform(UInt32(colorPalette.count)))
    
    return colorPalette[colorIndex]
  }
  
  private func createRingCollider(position: SCNVector3,
                                  rotationEuler: SCNVector3
    ) -> SCNNode {
    let collider = SCNCapsule(capRadius: CGFloat(CAPSULE_RADIUS), height: CGFloat(CAPSULE_HEIGHT))
    let colliderNode = SCNNode(geometry: collider)
    
    colliderNode.eulerAngles = rotationEuler
    colliderNode.position =  position
    
    collider.materials.first?.diffuse.contents = UIColor.clear
    
    return colliderNode
  }

  private func createRingColliders() -> SCNNode {
    let colliderNodes = SCNNode()
    
    colliderNodes.position.y += RING_COLLIDER_PIVOT_OFFSET
    
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: DIST_TO_CORNER, y: 0, z: 0),
      rotationEuler:  SCNVector3(x: 90.degreesToRadians, y: 0, z: 0))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: -DIST_TO_CORNER, y: 0, z: 0),
      rotationEuler:  SCNVector3(x: 90.degreesToRadians, y: 0, z: 0))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: 0, y: 0, z: DIST_TO_CORNER),
      rotationEuler:  SCNVector3(x: 0, y: 0, z: 90.degreesToRadians))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: 0, y: 0, z: -DIST_TO_CORNER),
      rotationEuler: SCNVector3(x: 0, y: 0, z: 90.degreesToRadians))
    )
    
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: DIST_TO_EDGE, y: 0, z: DIST_TO_EDGE),
      rotationEuler:  SCNVector3(x: 45.degreesToRadians, y: 0, z: 90.degreesToRadians))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: -DIST_TO_EDGE, y: 0, z: -DIST_TO_EDGE),
      rotationEuler:  SCNVector3(x: 45.degreesToRadians, y: 0, z: 90.degreesToRadians))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: DIST_TO_EDGE, y: 0, z: -DIST_TO_EDGE),
      rotationEuler:  SCNVector3(x: -45.degreesToRadians, y: 0, z: 90.degreesToRadians))
    )
    colliderNodes.addChildNode(createRingCollider(
      position: SCNVector3(x: -DIST_TO_EDGE, y: 0, z: DIST_TO_EDGE),
      rotationEuler: SCNVector3(x: -45.degreesToRadians, y: 0, z: 90.degreesToRadians))
    )
    
    return colliderNodes
  }
}
