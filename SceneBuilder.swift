//
//  SceneBuilder.swift
//  VikingScene
//
//  Created by Gustavo da Silva Braghin on 05/04/22.
//


import SpriteKit

public class SceneBuilder {
    
    let frame: CGRect
    
    public init(frame: CGRect){
        self.frame = frame
    }
    
    public func createBackground() -> SKSpriteNode {
        let background = SKSpriteNode(imageNamed: "background.png")
        background.name = "background"
        background.zPosition = -1
        background.size = CGSize(width: frame.width, height: frame.height)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        return background
    }
    
    public func createReplayButton() -> SKSpriteNode {
        let replayButton = SKSpriteNode(imageNamed: "replayButton.png")
        replayButton.name = "replayButton"
        replayButton.zPosition = 1
        replayButton.position = CGPoint(x: frame.width * 0.08, y: frame.height * 0.07)
        return replayButton
    }
    
    public func createTextField() -> SKShapeNode {
        let textField = SKShapeNode(rect: CGRect(x: 0, y: 0, width: frame.width * 0.7, height: frame.height * 0.25), cornerRadius: 15)
        textField.name = "textField"
        textField.zPosition = 1
        textField.position = CGPoint(x: frame.width * 0.15, y: frame.height * 0.59)
        textField.strokeColor = .clear
        textField.fillColor = UIColor.otherGreen()
        return textField
    }
    
    public func createLabel(textField: SKShapeNode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "American Typewriter")
        label.text = "abcabcab cabcabcabc abcabcabcabcabcabcabcabcabcabc abcabcabcabc abcabcabcab"
        label.name = "textField"
        label.lineBreakMode = .byWordWrapping
        label.verticalAlignmentMode = .top
        label.numberOfLines = 10
        label.preferredMaxLayoutWidth = textField.frame.width * 0.95
        label.position = CGPoint(x: textField.frame.minX * 1.08, y: textField.frame.maxY * 0.99)
        label.zPosition = 2
        label.fontSize = 30
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        return label
    }
    
    public func createLabelButton() -> SKSpriteNode {
        let labelButton = SKSpriteNode(imageNamed: "labelButton.png")
        labelButton.name = "textFieldButton"
        labelButton.zPosition = 3
        labelButton.position = CGPoint(x: frame.width * 0.81, y: frame.height * 0.62)
        return labelButton
    }
    
    public func createAxeShape(imageName: String) -> SKSpriteNode {
        let axeShape = SKSpriteNode(imageNamed: imageName)
        axeShape.name = imageName
        axeShape.position = CGPoint(x: frame.midX, y: frame.height * 0.4)
        axeShape.zPosition = 3
        return axeShape
    }
    
    public func createAxeTop(imageName: String) -> SKSpriteNode {
        let axeTop = SKSpriteNode(imageNamed: imageName)
        axeTop.name = imageName
        axeTop.position = CGPoint(x: frame.width * 0.8, y: frame.height * 0.2)
        axeTop.zPosition = 4
        return axeTop
    }
    
    public func createAxeBottom(imageName: String) -> SKSpriteNode {
        let axeBottom = SKSpriteNode(imageNamed: imageName)
        axeBottom.name = imageName
        axeBottom.position = CGPoint(x: frame.width * 0.2, y: frame.height * 0.22)
        axeBottom.zPosition = 4
        return axeBottom
    }
    
    public func createViking(imageName: String) -> SKSpriteNode {
        let axeTop = SKSpriteNode(imageNamed: imageName)
        axeTop.name = imageName
        axeTop.position = CGPoint(x: frame.width * 0.69, y: frame.height * 0.20)
        axeTop.zPosition = 3
        return axeTop
    }
    
}

extension UIColor {
    public class func otherGreen() -> UIColor {
        return UIColor(red: 80/255, green: 165/255, blue: 134/255, alpha: 1)
    }
}

