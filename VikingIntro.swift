//
//  VikingIntro.swift
//  VikingScene
//
//  Created by Gustavo da Silva Braghin on 05/04/22.
//

import SpriteKit
import CoreGraphics
import AVKit

var draggableNode: SKNode?

class VikingIntro: SKScene {
    
    var background = SKSpriteNode()
    var replayButton = SKSpriteNode()
    var textField = SKShapeNode()
    var label = SKLabelNode()
    var labelButton = SKSpriteNode()
    var sceneInd = 0
    var didFix = false
    
    var item = SKSpriteNode()
    var itemTop = SKSpriteNode()
    var itemBottom = SKSpriteNode()
//    var elmoShape = SKSpriteNode()
//    var elmoTop = SKSpriteNode()
//    var elmoBottom = SKSpriteNode()
    //var horn = SKSpriteNode()
    var rotationRec = UIRotationGestureRecognizer()
    var sceneBuilder: SceneBuilder?
    var previewPositionAxeTop: CGPoint?
    var previewPositionAxeBottom: CGPoint?
    
    var sound: SKAction?
    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "backgroundSound", withExtension: "mp3") else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    override func didMove(to view: SKView) {
        sceneBuilder = SceneBuilder(frame: frame)
        
        //to all phases
        background = sceneBuilder!.createBackground()
        replayButton = sceneBuilder!.createReplayButton()
        textField = sceneBuilder!.createTextField()
        label = sceneBuilder!.createLabel(textField: textField)
        label.text = TextPhase.intro.rawValue
        labelButton = sceneBuilder!.createLabelButton()
        itemTop = sceneBuilder!.createViking(imageName: "Viking")
        
        //to axePhase
        item = sceneBuilder!.createAxeShape(imageName: "axeShape")
        itemBottom = sceneBuilder!.createAxeBottom(imageName: "axeBottom")
        previewPositionAxeTop = itemTop.position
        previewPositionAxeBottom = itemBottom.position
        
        //adding rotation recognizer gesture
        rotationRec.addTarget(self, action: #selector(self.rotateNode(_:)))
        self.view!.addGestureRecognizer(rotationRec)
        
        
        //add nodes of first scene
        addChild(background)
        addChild(replayButton)
        addChild(textField)
        addChild(label)
        addChild(labelButton)
        addChild(itemTop)
        backgroundMusic?.volume = 0.12
        backgroundMusic?.play()
        sound = SKAction.playSoundFileNamed("intro.mp3", waitForCompletion: false)
        self.run(sound!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // there was a touch
        let touch = touches.first
        
        guard let touchLocation = touch?.location(in: self) else { return }
        
        guard let node = self.nodes(at: touchLocation).first else { return }
        
        switch node.name {
            
        case "textFieldButton":
            if sceneInd == 0 {
                itemTop.removeFromParent()
                label.text = TextPhase.axeLevel.rawValue
                label.fontSize = 42
                labelButton.removeFromParent()
                itemTop = sceneBuilder!.createAxeTop(imageName: "axeTop")
                addChild(item)
                addChild(itemTop)
                addChild(itemBottom)
                
                self.sound = SKAction.playSoundFileNamed("dragndrop.mp3", waitForCompletion: false)
                self.run(sound!)
                sceneInd += 1
            } else if sceneInd == 2 {
                item.removeFromParent()
                labelButton.removeFromParent()
                item = self.sceneBuilder!.createAxeShape(imageName: "elmoShape")
                itemTop = self.sceneBuilder!.createAxeTop(imageName: "elmoR")
                itemBottom = self.sceneBuilder!.createAxeBottom(imageName: "elmoL")
                
                addChild(item)
                addChild(itemTop)
                addChild(itemBottom)
                
                sceneInd += 1
            } else if sceneInd == 4 {
                item.removeFromParent()
                labelButton.removeFromParent()
                
                itemBottom = self.sceneBuilder!.createAxeBottom(imageName: "horn")
                itemTop = self.sceneBuilder!.createViking(imageName: "Viking")
                label.text = TextPhase.hornLevel.rawValue
                label.fontSize = 34
                
                addChild(itemBottom)
                addChild(itemTop)
                
                self.sound = SKAction.playSoundFileNamed("hornphase.mp3", waitForCompletion: false)
                self.run(sound!)
                sceneInd += 1
            }else if sceneInd == 5 {
                label.text = TextPhase.end.rawValue
                label.fontSize = 36
                labelButton.removeFromParent()
                
                self.sound = SKAction.playSoundFileNamed("end.mp3", waitForCompletion: false)
                self.run(sound!)
            }
            
        break
        
        case "axeTop", "axeBottom", "elmoR", "elmoL", "horn":
            draggableNode = node
        break
            
        case "replayButton":
            print("Play narration again")
            self.run(sound!)
        break
            
        default:
            
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = draggableNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
            print(node.position)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (draggableNode != nil) {
            if (verifyPosition() && verifyRotation()) {
            }else{
                draggableNodeToDefaultPosition()
                draggableNode = nil
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    @objc func rotateNode(_ sender:UIRotationGestureRecognizer) {

        if sender.state == .began {
            print("began")
        }
        
        if sender.state == .changed {
            
            if sender.rotation >= 6.28 || sender.rotation <= -6.28 {
                sender.rotation = 0
                draggableNode?.zRotation = 0
            } else {
                draggableNode?.zRotation = -sender.rotation
            }
        }
        
        if sender.state == .ended {
            
            if (draggableNode != nil) {
                if (verifyPosition() && verifyRotation()) {
                    draggableNode?.removeFromParent()
                    
                    if(draggableNode?.name == "axeTop" && !didFix){
                        item.texture = SKTexture(imageNamed: "axeTopFixed.png")
                    }else if(draggableNode?.name == "axeBottom" && !didFix){
                        item.texture = SKTexture(imageNamed: "axeBottomFixed.png")
                    }else if (draggableNode?.name == "axeTop" && didFix || draggableNode?.name == "axeBottom" && didFix){
                        item.texture = SKTexture(imageNamed: "axeFixed.png")
                        sceneInd += 1
                        self.addChild(labelButton)
                    }else if(draggableNode?.name == "elmoR" && !didFix){
                        item.texture = SKTexture(imageNamed: "elmoRFixed.png")
                    }else if(draggableNode?.name == "elmoL" && !didFix){
                        item.texture = SKTexture(imageNamed: "elmoLFixed.png")
                    }else if (draggableNode?.name == "elmoR" && didFix || draggableNode?.name == "elmoL" && didFix){
                        item.texture = SKTexture(imageNamed: "elmo.png")
                        sceneInd += 1
                        self.addChild(labelButton)
                    }
                    didFix.toggle()
                }else{
                    draggableNodeToDefaultPosition()
                }
                draggableNode = nil
            }
        }
        
        if sender.state == .cancelled {
            draggableNodeToDefaultPosition()
        }
    }
    
    func draggableNodeToDefaultPosition() {
        if (draggableNode?.name == "axeTop" || draggableNode?.name == "elmoR") {
            draggableNode?.zRotation = 0
            draggableNode?.position = previewPositionAxeTop ?? (draggableNode?.position)!
        }else if (draggableNode?.name == "axeBottom" || draggableNode?.name == "elmoL") {
            draggableNode?.zRotation = 0
            draggableNode?.position = previewPositionAxeBottom ?? (draggableNode?.position)!
        }
    }
    
    func verifyRotation() -> Bool {
        if (draggableNode?.name == "axeTop"){
            if (draggableNode!.zRotation >= 1.20 && draggableNode!.zRotation <= 1.70) || (draggableNode!.zRotation >= -5.1 && draggableNode!.zRotation <= -4.60) {
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "axeBottom"){
            if (draggableNode!.zRotation >= 4.80 && draggableNode!.zRotation <= 5.20) || (draggableNode!.zRotation >= -1.40 && draggableNode!.zRotation <= -1.0){
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "elmoR"){
            if (draggableNode!.zRotation >= 1.80 && draggableNode!.zRotation <= 2.20) || (draggableNode!.zRotation >= -4.5 && draggableNode!.zRotation <= -4.10) {
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "elmoL"){
            if (draggableNode!.zRotation >= 2.20 && draggableNode!.zRotation <= 2.60) || (draggableNode!.zRotation >= -4.05 && draggableNode!.zRotation <= -3.65){
                return true
            }else {
                return false
            }
        }
        return false
    }
    
    func verifyPosition() -> Bool {
        if (draggableNode?.name == "axeTop"){
            if (draggableNode!.position.x >= frame.width * 0.521 && draggableNode!.position.x <= frame.width * 0.575) && (draggableNode!.position.y >= frame.height * 0.45 && draggableNode!.position.y <= frame.height * 0.52) {
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "axeBottom"){
            if (draggableNode!.position.x >= frame.width * 0.41 && draggableNode!.position.x <= frame.width * 0.48) && (draggableNode!.position.y >= frame.height * 0.32 && draggableNode!.position.y <= frame.height * 0.40){
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "elmoR"){
            if (draggableNode!.position.x >= frame.width * 0.54 && draggableNode!.position.x <= frame.width * 0.611) && (draggableNode!.position.y >= frame.height * 0.361 && draggableNode!.position.y <= frame.height * 0.42) {
                return true
            }else {
                return false
            }
        }else if (draggableNode?.name == "elmoL"){
            if (draggableNode!.position.x >= frame.width * 0.385 && draggableNode!.position.x <= frame.width * 0.456) && (draggableNode!.position.y >= frame.height * 0.361 && draggableNode!.position.y <= frame.height * 0.42){
                return true
            }else {
                return false
            }
        }
        return false
    }
    
}

//MARK: - CREATING VIEW AND SCENE

//let frame = CGRect(x: 0, y: 0, width: 768, height: 1024)
//
//let view = SKView(frame: frame)
//
//let scene = VikingIntro()
//
//scene.size = CGSize(width: frame.width, height: frame.height)
//
//scene.scaleMode = .aspectFill
//
//view.presentScene(scene)
//
//PlaygroundPage.current.needsIndefiniteExecution = true
//
//PlaygroundPage.current.liveView = view

//: [Next](@next)

