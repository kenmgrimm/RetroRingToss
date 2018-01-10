//  UNUSED until can figure out UIButtons / SKSpriteNode interaction


import UIKit
import SpriteKit

class OverlayScene: SKScene {
  
  var pauseNode: SKSpriteNode!
  var scoreNode: SKLabelNode!
  
  var score = 0 {
    didSet {
      scoreNode.text = "Score: \(score)"
    }
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    
    backgroundColor = UIColor.clear
    
    let spriteSize = size.width/12
    pauseNode = SKSpriteNode.init(color: UIColor.red, size: CGSize(width: 10, height: 10))
    pauseNode.size = CGSize(width: spriteSize, height: spriteSize)
    pauseNode.position = CGPoint(x: spriteSize + 8, y: spriteSize + 8)
    
    scoreNode = SKLabelNode(text: "Score: 0")
    scoreNode.fontName = "DINAlternate-Bold"
    scoreNode.fontColor = UIColor.black
    scoreNode.fontSize = 24
    scoreNode.position = CGPoint(x: size.width/2, y: pauseNode.position.y - 9)
    
//    pauseNode.addChild(pauseButton)
    
//    addChild(pauseNode)
//    addChild(scoreNode)
    
    
    
    
    // DO NOT Consume all touches, let them fall through
    isUserInteractionEnabled = false
    
    pauseNode.isUserInteractionEnabled = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("heyo")
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

