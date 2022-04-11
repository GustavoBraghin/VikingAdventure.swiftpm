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
    
    var rotationRec = UIRotationGestureRecognizer()
    var sceneBuilder: SceneBuilder?
    var previewPositionAxeTop: CGPoint?
    var previewPositionAxeBottom: CGPoint?
    
    var currentSound = ""
    var currentDuration = Double(0)
    
    var replayButtonPosition = CGPoint()
    var itemBottomPosition = CGPoint()
    var itemTopPosition = CGPoint()
    var itemShapePosition = CGPoint()
    var labelButtonPosition = CGPoint()
    var vikingPosition = CGPoint()
    
    
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
        replayButtonPosition = CGPoint(x: frame.width * 0.08, y: frame.height * 0.07)
        itemBottomPosition = CGPoint(x: frame.width * 0.2, y: frame.height * 0.22)
        itemTopPosition = CGPoint(x: frame.width * 0.8, y: frame.height * 0.2)
        itemShapePosition = CGPoint(x: frame.midX, y: frame.height * 0.4)
        labelButtonPosition = CGPoint(x: frame.width * 0.81, y: frame.height * 0.62)
        vikingPosition = CGPoint(x: frame.width * 0.69, y: frame.height * 0.20)
        
        //to all phases
        background = sceneBuilder!.createBackground()
        replayButton = sceneBuilder!.createItem(imageName: "replayButton", position: replayButtonPosition)
        textField = sceneBuilder!.createTextField()
        label = sceneBuilder!.createLabel(textField: textField)
        label.text = TextPhase.intro.rawValue
        labelButton = sceneBuilder!.createItem(imageName: "labelButton", position: labelButtonPosition)
        itemTop = sceneBuilder!.createItem(imageName: "Viking", position: vikingPosition)
        
        //to axePhase
        item = sceneBuilder!.createItem(imageName: "axeShape", position: itemShapePosition)
        itemBottom = sceneBuilder!.createItem(imageName: "axeBottom", position: itemBottomPosition)
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
        backgroundMusic?.volume = 0.05
        backgroundMusic?.play()
        playSound(fileName: UlfVoice.intro.rawValue, duration: VoiceDuration.intro.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // there was a touch
        let touch = touches.first
        
        guard let touchLocation = touch?.location(in: self) else { return }
        
        guard let node = self.nodes(at: touchLocation).first else { return }
        
        switch node.name {
            
        case "labelButton":
            if sceneInd == 0 {
                itemTop.removeFromParent()
                label.text = TextPhase.axeLevel.rawValue
                label.fontSize = 42
                labelButton.removeFromParent()
                itemTop = sceneBuilder!.createItem(imageName: "axeTop", position: itemTopPosition)
                addChild(item)
                addChild(itemTop)
                addChild(itemBottom)
                
                playSound(fileName: UlfVoice.axeLevel.rawValue, duration: VoiceDuration.axeLevel.rawValue)
                sceneInd += 1
            } else if sceneInd == 2 {
                item.removeFromParent()
                labelButton.removeFromParent()
                item = self.sceneBuilder!.createItem(imageName: "elmoShape", position: itemShapePosition)
                itemTop = self.sceneBuilder!.createItem(imageName: "elmoR", position: itemTopPosition)
                itemBottom = self.sceneBuilder!.createItem(imageName: "elmoL", position: itemBottomPosition)
                
                addChild(item)
                addChild(itemTop)
                addChild(itemBottom)
                
                sceneInd += 1
            } else if sceneInd == 4 {
                item.removeFromParent()
                labelButton.removeFromParent()
                
                let ships = self.sceneBuilder!.createItem(imageName: "ships", position: CGPoint(x: frame.midX, y: frame.midY))
                
                
                itemBottom = self.sceneBuilder!.createItem(imageName: "horn", position: itemBottomPosition)
                itemTop = self.sceneBuilder!.createItem(imageName: "Viking", position: vikingPosition)
                itemTop.zPosition = 3
                label.text = TextPhase.hornLevel.rawValue
                label.fontSize = 34
                
                addChild(itemBottom)
                addChild(itemTop)
                addChild(ships)
                
                playSound(fileName: UlfVoice.hornLevel.rawValue, duration: VoiceDuration.hornLevel.rawValue)
                sceneInd += 1
            }else if sceneInd == 5 {
                label.text = TextPhase.end.rawValue
                label.fontSize = 36
                labelButton.removeFromParent()
                
                playSound(fileName: UlfVoice.end.rawValue, duration: VoiceDuration.end.rawValue)
            }
            
        break
        
        case "axeTop", "axeBottom", "elmoR", "elmoL", "horn":
            draggableNode = node
        break
            
        case "replayButton":
            playSound(fileName: currentSound, duration: currentDuration)
        break
            
        default:
            
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = draggableNode {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (draggableNode != nil) {
            if (verifyPosition() && verifyRotation()) {
                if(draggableNode?.name == "horn") {
                    itemBottom.removeFromParent()
                    self.playSound(fileName: UlfVoice.hornSound.rawValue, duration: VoiceDuration.hornSound.rawValue)
                    self.addChild(labelButton)
                }
            }else{
                draggableNodeToDefaultPosition()
                
            }
            draggableNode = nil
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
                    }else if(draggableNode?.name == "horn") {
                        self.playSound(fileName: UlfVoice.hornSound.rawValue, duration: VoiceDuration.hornSound.rawValue)
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
        }else if(draggableNode?.name == "horn"){
            return true
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
        }else if (draggableNode?.name == "horn"){
            if (draggableNode!.position.x >= frame.width * 0.52 && draggableNode!.position.x <= frame.width * 0.99) && (draggableNode!.position.y >= frame.height * 0.01 && draggableNode!.position.y <= frame.height * 0.5){
                return true
            }else {
                return false
            }
        }
        return false
    }
    
    func playSound(fileName: String, duration: Double) {
        self.currentSound = fileName
        self.currentDuration = duration
        
        let sound = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        let runSound = SKAction.run({
            if(fileName == UlfVoice.hornLevel.rawValue){
                self.itemBottom.isUserInteractionEnabled = true
            }
            self.labelButton.isUserInteractionEnabled = true
            self.replayButton.isUserInteractionEnabled = true
            self.run(sound)
        })
        let wait = SKAction.wait(forDuration: duration)
        let interactive = SKAction.run({
            self.itemBottom.isUserInteractionEnabled = false
            self.labelButton.isUserInteractionEnabled = false
            self.replayButton.isUserInteractionEnabled = false
        })
        
        let group = SKAction.group([runSound,wait])
        let seq = SKAction.sequence([group,interactive])
        self.run(seq)
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

