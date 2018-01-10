import CoreMotion
import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
  let structurePosition = SCNVector3(x: 0, y: 10, z: 0)
  let structureScale =  SCNVector3(x: 1, y: 1, z: 1)
  
  // UI
  let cameraPosition = SCNVector3(x: -0.5, y: 10, z: 10)
  let cameraRotation = SCNVector3(x: 0, y: 0, z: 0)
  let orthographicScale = 35.0

//  let cameraPosition = SCNVector3(x: -46, y: -10, z: -5)
//  let cameraRotation = SCNVector3(x: 0, y: -95.degreesToRadians, z: 0)
//  let cameraPosition = SCNVector3(x: -3, y: 12, z: 10)
//  let cameraRotation = SCNVector3(x: 0, y: -40.degreesToRadians, z: 0)
//  let cameraPosition = SCNVector3(x: -40, y: 20, z: 70)
//  let cameraRotation = SCNVector3(x: 0.degreesToRadians, y: -40.degreesToRadians, z: 0)
  
  
  private let motionManager = CMMotionManager()
  
  // Scene
  var overlayScene:SKScene!
  
  var gameView:SCNView!
  var gameScene:SCNScene!
  var cameraNode:SCNNode!
  
  // Static positions
  let staticNodes = SCNNode()
  
  let leftSquirterPosition = SCNVector3(-7.5, 0, -1)
  let rightSquirterPosition = SCNVector3(7.5, 0, -1)
  let leftSquirter = SCNNode()
  let rightSquirter = SCNNode()
  
  // Force Fields
  let leftSquirtFieldDirection = SCNVector3(x: -10, y: 20, z: 0)
  let rightSquirtFieldDirection = SCNVector3(x: 10, y: 20, z: 0)
  
  let leftSquirtFieldStrength:CGFloat = -800.0
  let rightSquirtFieldStrength:CGFloat = -800.0
  
  let fieldFalloffExponent:CGFloat = 0.8
  
  let leftSquirtField = SCNPhysicsField.radialGravity()
  let rightSquirtField = SCNPhysicsField.radialGravity()
//  let noiseField = SCNPhysicsField.noiseField(smoothness: 0.1, animationSpeed: 1)
  
  // Physics and Gravity
  let gravity:Float = -6
  
  // Field category masks
  let squirtFieldCategory = 1 << 0

  let leftSquirtButtonNodePosition = SCNVector3(x: -5, y: 2, z: 5)
  let rightSquirtButtonNodePosition = SCNVector3(x: 5, y: 2, z: 5)

  // Rings
  let ringNodes = SCNNode()
  let maxRings = 6
  let maxRingVelocity = SCNVector3(x: 10, y: 10, z: 10)
  private var ringCreationTime:TimeInterval = 0
  
  // Colors
  let colorPalette: [UIColor] = [
    UIColor(rgb: 0x42c31b),
    UIColor(rgb: 0xf6ca11),
    UIColor(rgb: 0xc53333),
    UIColor(rgb: 0x2414d4),
    UIColor(rgb: 0xffffff)
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerForMotionUpdates()
    
    initView()
    initScene()
    initCamera()
    
    setupSquirters()
    setupStructure()
    setupToyMesh()
    setupUI()
  }
  
  private func setupToyMesh() {
    let node = SCNNode()
    let meshNode = MeshUtils.loadModel(
      scene: SCNScene(named: "art.scnassets/toyMesh2.dae")!,
      names: ["gameToy5"],
      enablePhysics: false,
      type: .static,
      shapeType: SCNPhysicsShape.ShapeType.convexHull)
    
    node.addChildNode(meshNode)
    
    node.position = structurePosition
    node.scale = structureScale
    
    node.physicsBody = nil
    
    staticNodes.addChildNode(node)
  }
  
  private func registerForMotionUpdates() {
    motionManager.startDeviceMotionUpdates(
      to: OperationQueue.current!, withHandler: {
        (deviceMotion, error) -> Void in
        
        if(error == nil) {
          self.handleDeviceMotionUpdate(deviceMotion!)
        } else {
          debugPrint("Failure registering for motion updates: \(error.debugDescription)")
        }
    })
  }

  private func radiansToDegrees(_ radians: Double) -> Double {
    return 180 / .pi * radians
  }
  
  private func rollIsUpsideDown(_ roll: Double) -> Bool {
    return abs(roll) > 90
  }
  
  // Upside-down roll values are odd.  This function converts them into values matching right-side up rolls.
  // Pitch up = 90, down = -90  -  same when phone upside down
  // Roll (rightside-up):
  //   right = 90, mid = 0, left = -90
  // Roll (upside-down):
  //   right = -90, mid(right of 90 degrees) = -180, mid(left of 90 degrees) = 180, left = 90
  private func convertRoll(_ roll: Double) -> Double {
    if !rollIsUpsideDown(roll) {
      return -roll
    }
    
    // Bring into range of 180 -> 90
    var adjustedRoll = abs(roll) - 90
    // Swap min, max from 90 -> 0 to 0 -> 90
    adjustedRoll = 90 - adjustedRoll
    // Swap signs
    adjustedRoll *= -sign(Double(roll))
    
    return adjustedRoll
  }

  private func handleDeviceMotionUpdate(_ deviceMotion: CMDeviceMotion) {
    let attitude = deviceMotion.attitude
    let roll = radiansToDegrees(attitude.roll)

    let adjustedRoll = convertRoll(roll)
    
    var down = SCNVector3.Zero()
    down.y = Float(attitude.pitch.radiansToDegrees)
    down.x = Float(adjustedRoll)
    let downNormalized = down / 90
    
    gameScene.physicsWorld.gravity = downNormalized * gravity
//    print("gravity vector: x, y, z: \(gameScene.physicsWorld.gravity.x), \(gameScene.physicsWorld.gravity.y), \(gameScene.physicsWorld.gravity.z)")
  }

  private func setupSquirters() {
    setupSquirterNodes()
  }
  
  private func setupStructure() {
    let node = SCNNode()
    let meshNode = MeshUtils.loadModel(
      scene: SCNScene(named: "art.scnassets/toyMesh2.dae")!,
      names: ["topBar", "leftBar", "rightBar",
              "bottomLeftArch", "bottomRightArch", "bottomLeftBumper", "bottomRightBumper",
              "target1Pole", "target1Base", "target2Pole", "target1PoleTop", "target2PoleTop", "target2Base"],
      color: UIColor.red,
      enablePhysics: true,
      type: .static,
      shapeType: SCNPhysicsShape.ShapeType.convexHull)

    node.addChildNode(meshNode)

    node.position = structurePosition //+ SCNVector3(x: 28, y: 15, z: 4)
//    node.scale = structureScale

    node.physicsBody = nil

    staticNodes.addChildNode(node)
  }
  
  private func setupSquirterNodes() {
    let leftSquirterBox = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.5)
    leftSquirterBox.materials.first?.diffuse.contents = UIColor.yellow
    
    let rightSquirterBox = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.5)
    rightSquirterBox.materials.first?.diffuse.contents = UIColor.green
    
    leftSquirter.position = leftSquirterPosition
    rightSquirter.position = rightSquirterPosition
    
    staticNodes.addChildNode(leftSquirter)
    staticNodes.addChildNode(rightSquirter)
    
    setupForceFields(leftSquirterBox: leftSquirterBox, rightSquirterBox: rightSquirterBox)
  }
  
  private func setupForceFields(leftSquirterBox: SCNBox, rightSquirterBox: SCNBox) {
    let leftSquirtFieldNode = SCNNode(geometry: leftSquirterBox)
    leftSquirtFieldNode.position = leftSquirterPosition
    staticNodes.addChildNode(leftSquirtFieldNode)
    
    let rightSquirtFieldNode = SCNNode(geometry: rightSquirterBox)
    rightSquirtFieldNode.position = rightSquirterPosition
    staticNodes.addChildNode(rightSquirtFieldNode)
    
    leftSquirtField.strength = leftSquirtFieldStrength
    leftSquirtField.categoryBitMask = squirtFieldCategory
    leftSquirtField.falloffExponent = fieldFalloffExponent
    leftSquirtField.isActive = false
    
    rightSquirtField.strength = rightSquirtFieldStrength
    rightSquirtField.categoryBitMask = squirtFieldCategory
    rightSquirtField.falloffExponent = fieldFalloffExponent
    rightSquirtField.isActive = false
    
    leftSquirter.physicsField = leftSquirtField
    rightSquirter.physicsField = rightSquirtField
  }
  
  private func setupUI() {
    // Add UI Overlay
    //    self.overlayScene = OverlayScene(size: self.view.bounds.size)
    //    self.gameView.overlaySKScene = self.overlayScene
    
    let leftSquirtButton = SCNPlane(width: 3, height: 3)
    leftSquirtButton.materials.first?.diffuse.contents = UIColor.blue
    
    let leftSquirtButtonNode = SCNNode(geometry: leftSquirtButton)
    leftSquirtButtonNode.position = leftSquirtButtonNodePosition
    leftSquirtButtonNode.name = "leftSquirtButtonNode";
    leftSquirtButtonNode.physicsBody = nil
    staticNodes.addChildNode(leftSquirtButtonNode)
    
    let rightSquirtButton = SCNPlane(width: 3, height: 3)
    rightSquirtButton.materials.first?.diffuse.contents = UIColor.blue
    
    let rightSquirtButtonNode = SCNNode(geometry: rightSquirtButton)
    rightSquirtButtonNode.position = rightSquirtButtonNodePosition
    rightSquirtButtonNode.name = "rightSquirtButtonNode";
    rightSquirtButtonNode.physicsBody = nil
    staticNodes.addChildNode(rightSquirtButtonNode)
  }

  func initView() {
    gameView = self.view as! SCNView

    gameView.autoenablesDefaultLighting = true
    
    gameView.backgroundColor = UIColor(rgb: 0xF8F9F9)
    
    gameView.delegate = self
  }
  

  func initScene() {
    gameScene = SCNScene()
    gameView.scene = gameScene
    
    gameView.isPlaying = true
    
    gameScene.rootNode.addChildNode(ringNodes)
    gameScene.rootNode.addChildNode(staticNodes)
    
    gameView.debugOptions = .showPhysicsShapes
//    gameView.debugOptions = .showBoundingBoxes
//    gameView.debugOptions.showLightInfluences
//    gameView.debugOptions = .showPhysicsFields
//    gameView.debugOptions = .showWireframe
  }

  func initCamera() {
    cameraNode = SCNNode()
    let camera = SCNCamera()
    
    camera.usesOrthographicProjection = true
    camera.orthographicScale = orthographicScale
    cameraNode.position = cameraPosition
    cameraNode.eulerAngles = cameraRotation
    
    cameraNode.camera = camera
    staticNodes.addChildNode(cameraNode)
  }
  
  @objc
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    
  }
  
  func renderer(_ renderer: SCNSceneRenderer,
      didSimulatePhysicsAtTime time: TimeInterval) {
    
    for ringNode in ringNodes.childNodes {
//      print("ring.presentation.position: " + String(describing: ringNode.presentation.position))
      
      ringNode.transform = ringNode.presentation.transform

      ringNode.position.z = min(max(ringNode.position.z, 0.25), 0.25)
    
//      print("ring.position: " + String(describing: ringNode.position))
    }
    
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if time > ringCreationTime && numRings() < maxRings {
      let ring = Ring.createRingNode()
      ringNodes.addChildNode(ring)
      
      ringCreationTime = time + 2
    }

    
    // limit speed of objects to maxVelocity
    // Pseudocode from: https://stackoverflow.com/questions/24258928/set-a-physicsbody-to-a-constant-velocity
//    for var ring in rings.childNodes {
//      var scnVelocity = ring.physicsBody?.velocity
//      var velocity = Vector3(x: CGFloat(scnVelocity!.x), y: scnVelocity!.y, z: scnVelocity!.z)
//      let normalizedVelocity = velocity.normalized()
//
//
//      var newVelocity =
//
//      velocity = multiply(velocity, normalizedMaxVelocity);
//      somePhysicsBody.velocity = velocity;
//      if ring.physicsBody?.velocity > maxRingVelocity {
//        ring.physicsBody?.velocity = maxRingVelocity
//      }
//    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    
    let location = touch.location(in: gameView)
    
    let hitList = gameView.hitTest(location, options: nil)
    
    if let hitObject = hitList.first {
      let node = hitObject.node
      let name = node.name != nil ? node.name : "Background"

      if name == "leftSquirtButtonNode" {
        leftSquirtField.direction = leftSquirtFieldDirection
        leftSquirtField.isActive = true
      }
      else {
        rightSquirtField.direction = rightSquirtFieldDirection
        rightSquirtField.isActive = true
        
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    
    let location = touch.location(in: gameView)
    
    let hitList = gameView.hitTest(location, options: nil)
    
    if let hitObject = hitList.first {
      let node = hitObject.node
      let name = node.name != nil ? node.name : "Background"

      if name == "leftSquirtButtonNode" {
        leftSquirtField.isActive = false
      }
      else {
        rightSquirtField.isActive = false
      }
    }
  }

  private func numRings() -> Int {
    return ringNodes.childNodes.count
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
}

