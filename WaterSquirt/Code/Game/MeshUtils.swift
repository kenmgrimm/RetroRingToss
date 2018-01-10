import SceneKit

class MeshUtils {

  public static func loadModel (
    scene: SCNScene,
    names: [String],
    color: UIColor = UIColor.white,
    enablePhysics: Bool = true,
    type: SCNPhysicsBodyType = SCNPhysicsBodyType.dynamic,
    shapeType: SCNPhysicsShape.ShapeType = SCNPhysicsShape.ShapeType.boundingBox,
    transparency: CGFloat = 1) -> SCNNode {
    
    let node = SCNNode()
    let rootOfScene = scene.rootNode
    
    for childNodeName in names {
      print("childNodeName: " + childNodeName)
      let childNode = rootOfScene.childNode(withName: childNodeName, recursively: true)!
      print("actual name: " + childNode.name!)
      
      node.addChildNode(childNode)
      
      let geometry = childNode.geometry
      if(geometry?.materials.count != nil && geometry!.materials.count > 0) {
        print("Importing mesh: " + childNode.name! + ", materials: " +
          String(describing: geometry?.materials.first?.name))

        print("children: " + String(childNode.childNodes.count))
        geometry?.materials.first?.diffuse.contents = color
        
        if(transparency < 1) {
          geometry?.materials.first?.transparencyMode = SCNTransparencyMode.aOne
          geometry?.materials.first?.transparency = transparency
        }

        let shape = SCNPhysicsShape(
          node: childNode,
          options: [SCNPhysicsShape.Option.type: shapeType])
        
        childNode.physicsBody = enablePhysics ? SCNPhysicsBody(type: type, shape: shape) : nil
      }
      
      for subChild in (childNode.childNodes) {
        node.addChildNode(subChild)
        
        let geometry = subChild.geometry
        if(geometry?.materials.count != nil && geometry!.materials.count > 0) {
          print("Importing mesh: " + subChild.name! + ", materials: " +
            String(describing: geometry?.materials.first?.name))

          print("children: " + String(subChild.childNodes.count))
          
          geometry?.materials.first?.diffuse.contents = color
          
          let shape = SCNPhysicsShape(
            node: subChild,
            options: [SCNPhysicsShape.Option.type: shapeType])
          
          subChild.physicsBody = enablePhysics ? SCNPhysicsBody(type: type, shape: shape) : nil
        }
      }
    }
    
    let shape = SCNPhysicsShape(node: node,
                                options: [SCNPhysicsShape.Option.keepAsCompound: true])
    
    node.physicsBody = enablePhysics ? SCNPhysicsBody(type: type, shape: shape) : nil
    
    return node
  }
}
