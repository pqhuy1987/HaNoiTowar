//
//  GameScene.swift
//  Hanoi
//
//  Created by Matthew Irvine on 9/15/15.
//  Copyright (c) 2015 Matthew Irvine. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    static let buttonTextColor = UIColor.white
    static let buttonPressedColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
    static let bgColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
    static let menuColor = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 0.4)
    static let menuTopFraction: CGFloat = 0.25
    static let baseXDistanceFraction: CGFloat = 1.0 / 5.0
    static let baseYDistanceFraction: CGFloat = 1.0 / 2.5
    static let baseHeightFraction: CGFloat = 1.0 / 50.0
    static let baseWidthFraction: CGFloat = 1.0 / 5.0
    static let baseFillColor = UIColor.brown
    static let baseStrokeColor = UIColor.black
    static let discCornerRadius: CGFloat = 5.0
    static let xPositionMultipliers: Array<CGFloat> = [1.0, 2.5, 4.0]
    static let discWidthFraction: CGFloat = 0.95
    static let discHeightFraction: CGFloat = baseHeightFraction * 2.6
    static let selectedStrokeColor = UIColor.red
    static let unselectedStrokeColor = UIColor.white
    
    var discs: Array<Disc>!
    var bases: Array<Base>!
    var currentTouchedStack: Int?
    var newGameLabel: SKLabelNode?
    var startOverLabel: SKLabelNode?
    var messageLabel: SKLabelNode?
    var viewController: GameViewController?
    var pressedNode: SKLabelNode?
    var gameOver = false
    
    class Disc: NSObject {
        var color: UIColor
        var size: Int
        var base: Int
        var node: SKShapeNode?
        
        init(color: UIColor, size: Int) {
            self.color = color
            self.size = size
            self.base = 0
            self.node = nil
        }
    }
    
    class Base: NSObject {
        var node: SKShapeNode?
        var discStack: [Disc]
        
        init(node: SKShapeNode) {
            self.node = node
            self.discStack = []
        }
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = GameScene.bgColor
        self.setupMenu()
        self.setupBases()
        self.setupDiscs()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        let maxX = self.frame.maxX
        let stackXPositions = GameScene.xPositionMultipliers.map({ $0 * GameScene.baseXDistanceFraction * maxX })
        
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if node == self.newGameLabel || node == self.startOverLabel {
                let labelNode = node as! SKLabelNode
                labelNode.fontColor = GameScene.buttonPressedColor
                self.pressedNode = labelNode
                continue
            }
            
            if (gameOver == true) {
                continue
            }

            /* Check which stack the touch is on */
            let touchX = location.x
            var closestStack = -1
            var minDistance: CGFloat = -1.0
            for (n, xPosition) in stackXPositions.enumerated() {
                let distance = abs(xPosition - touchX)
                if minDistance == -1 || distance < minDistance {
                    closestStack = n
                    minDistance = distance
                }
            }
            
            if let currentTouchedStack = self.currentTouchedStack {
                /* Case 1: A stack is currently selected */
                if currentTouchedStack == closestStack {
                    /* Unselect the current object */
                    unselectStack()
                }
                else {
                    moveDiscFromStack(currentTouchedStack, toStack: closestStack)
                }
            }
            else {
                /* Case 2: No other stack has been selected yet */
                selectStack(closestStack)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if node == self.newGameLabel && self.pressedNode == self.newGameLabel  {
                self.viewController!.performSegue(withIdentifier: GameViewController.menuSegueIdentifier, sender: self)
                continue
            }
            else if node == self.startOverLabel && self.pressedNode == self.startOverLabel {
                self.messageLabel!.text = ""
                for base in self.bases {
                    base.node?.removeFromParent()
                }
                for disc in self.discs {
                    disc.node?.removeFromParent()
                }
                initializeDiscsForCount(self.discs!.count)
                setupBases()
                setupDiscs()
                continue
            }
        }
        self.pressedNode = nil
        self.startOverLabel?.fontColor = GameScene.buttonTextColor
        self.newGameLabel?.fontColor = GameScene.buttonTextColor
    }
    
    func initializeDiscsForCount(_ discCount: Int) {
        let colors = [UIColor.black, UIColor.orange, UIColor.blue, UIColor.purple, UIColor.cyan, UIColor.green, UIColor.yellow, UIColor.lightGray]
        var discs = [Disc]()
        for (i, color) in colors.enumerated() {
            if i == discCount {
                break
            }
            discs.append(Disc(color: color, size: 8 - i))
        }
        self.discs = discs
    }
    
    fileprivate func setupMenu() {
        let maxY = self.frame.maxY
        let maxX = self.frame.maxX
        let menuTopPosition = GameScene.menuTopFraction * maxY
        let menuRect = CGRect(x: 0.0, y: 0.0, width: maxX, height: menuTopPosition)
        let menuNode = SKShapeNode(rect: menuRect)
        menuNode.fillColor = GameScene.menuColor
        let newGameNode = SKLabelNode(text: "New Game")
        newGameNode.fontName = newGameNode.fontName! + "-bold"
        newGameNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        newGameNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        newGameNode.fontColor = UIColor.white
        newGameNode.fontSize = 28.0
        newGameNode.position = CGPoint(x: maxX - newGameNode.frame.width / 1.5, y: menuTopPosition - newGameNode.frame.height * 2)
        let startOverNode = SKLabelNode(text: "Start Over")
        startOverNode.fontName = newGameNode.fontName! + "-bold"
        startOverNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        startOverNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        startOverNode.fontColor = UIColor.white
        startOverNode.fontSize = 28.0
        startOverNode.position = CGPoint(x: newGameNode.frame.width / 1.5, y: menuTopPosition - newGameNode.frame.height * 2)
        let messageNode = SKLabelNode(text: "")
        messageNode.fontName = newGameNode.fontName! + "-bold"
        messageNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        messageNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        messageNode.fontColor = UIColor.white
        messageNode.fontSize = 36.0
        messageNode.position = CGPoint(x: maxX / 2.0, y: menuTopPosition - newGameNode.frame.height * 2)
        self.addChild(menuNode)
        self.addChild(newGameNode)
        self.addChild(startOverNode)
        self.addChild(messageNode)
        self.newGameLabel = newGameNode
        self.startOverLabel = startOverNode
        self.messageLabel = messageNode
    }
    
    fileprivate func setupBases() {
        let maxX = self.frame.maxX
        let maxY = self.frame.maxY
        let xPositionMultipliers = GameScene.xPositionMultipliers
        let baseWidth = maxX * GameScene.baseWidthFraction
        let baseHeight = maxY * GameScene.baseHeightFraction
        let baseSize = CGSize(width: baseWidth, height: baseHeight)
        let baseWidthOffset = baseWidth / 2.0
        let baseYPosition = maxY * GameScene.baseYDistanceFraction
        let origins = xPositionMultipliers.map { CGPoint(x: $0 * maxX * GameScene.baseXDistanceFraction - baseWidthOffset, y: baseYPosition) }
        let baseNodes = origins.map { SKShapeNode(rect: CGRect(origin: $0, size: baseSize)) }
        baseNodes.forEach { (node) -> () in
            node.fillColor = GameScene.baseFillColor
            node.strokeColor = GameScene.baseStrokeColor
            self.addChild(node)
        }
        self.bases = baseNodes.map { Base(node: $0) }
    }
    
    fileprivate func setupDiscs() {
        let discs = self.discs.sorted { (disc1, disc2) -> Bool in
            disc1.size > disc2.size
        }
        for disc in discs {
            let node = makeNodeForDisc(disc)
            self.bases[disc.base].discStack.append(disc)
            self.addChild(node)
            disc.node = node
        }
    }
    
    fileprivate func makeNodeForDisc(_ disc: Disc) -> SKShapeNode {
        let maxX = self.frame.maxX
        let maxY = self.frame.maxY
        let baseWidth = maxX * GameScene.baseWidthFraction
        let baseHeight = maxY * GameScene.baseHeightFraction
        let xPositionMultipliers = GameScene.xPositionMultipliers
        let discHeight = GameScene.discHeightFraction * maxY
        let baseNum = disc.base
        let base = self.bases[baseNum]
        let discPositionInStack = base.discStack.count
        let discWidth = GameScene.discWidthFraction * baseWidth * CGFloat(disc.size) / 8.0
        let xPosition = xPositionMultipliers[baseNum] * maxX * GameScene.baseXDistanceFraction - (discWidth / 2.0)
        let baseYPosition = GameScene.baseYDistanceFraction * maxY + baseHeight
        let yOffsetForDiscs = (CGFloat(discPositionInStack) * discHeight) + 1.0 * (CGFloat)(discPositionInStack + 2)
        let yPosition = baseYPosition + yOffsetForDiscs
        let discRect = CGRect(x: xPosition, y: yPosition, width: discWidth, height: discHeight)
        let node = SKShapeNode(rect: discRect, cornerRadius: GameScene.discCornerRadius)
        node.fillColor = disc.color
        node.strokeColor = GameScene.unselectedStrokeColor
        return node
    }
    
    fileprivate func unselectStack() {
        let currentBase = self.bases[currentTouchedStack!]
        let lastDisc = currentBase.discStack.last!
        lastDisc.node!.strokeColor = GameScene.unselectedStrokeColor
        self.currentTouchedStack = nil
    }
    
    fileprivate func selectStack(_ stackNum: Int) {
        let currentBase = self.bases[stackNum]
        if currentBase.discStack.count > 0 {
            let lastDisc = currentBase.discStack.last!
            lastDisc.node!.strokeColor = GameScene.selectedStrokeColor
            self.currentTouchedStack = stackNum
        }
    }
    
    fileprivate func moveDiscFromStack(_ fromStack: Int, toStack: Int) {
        let originBase = self.bases[fromStack]
        let destBase = self.bases[toStack]
        let discToMove = originBase.discStack.last!
        var canMoveNode = true
        var destTopNode: Disc? = nil
        if destBase.discStack.count > 0 {
            destTopNode = destBase.discStack.last!
            if destTopNode!.size < discToMove.size {
                canMoveNode = false
            }
        }
        if canMoveNode == true {
            unselectStack()
            discToMove.base = toStack
            let newNode = makeNodeForDisc(discToMove)
            discToMove.node!.removeFromParent()
            self.addChild(newNode)
            discToMove.node = newNode
            destBase.discStack.append(discToMove)
            originBase.discStack.removeLast()
            if (self.bases[2].discStack.count == self.discs.count) {
                /* Then the game is over */
                self.messageLabel!.text = "You win!"
                self.gameOver = true
            }
        }
    }
}
