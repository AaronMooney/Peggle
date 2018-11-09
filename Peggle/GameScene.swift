//
//  GameScene.swift
//  Peggle
//
//  Created by 20072163 on 17/10/2018.
//  Copyright © 2018 20072163. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var playLabel: SKLabelNode!
    var play: Bool = false {
        didSet {
            if play {
                playLabel.text = ""
            } else {
                playLabel.text = "Play"
            }
        }
    }
    var ballsLabel: SKLabelNode!
    var balls = 5 {
        didSet {
            ballsLabel.text = "Balls: \(balls)"
        }
    }
    var lastHit: String = "none"
    var boxesHit: Int = 0
    
    //TODO add clear function on finish to remove boxes
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0),index: 1)
        makeBouncer(at: CGPoint(x: 256, y: 0),index: 2)
        makeBouncer(at: CGPoint(x: 512, y: 0),index: 3)
        makeBouncer(at: CGPoint(x: 768, y: 0),index: 4)
        makeBouncer(at: CGPoint(x: 1024, y: 0),index: 5)
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position = CGPoint(x: 980, y: 650)
        addChild(ballsLabel)
        
        playLabel = SKLabelNode(fontNamed: "Chalkduster")
        playLabel.text = "Play"
        playLabel.horizontalAlignmentMode = .right
        playLabel.position = CGPoint(x: 750, y: 700)
        addChild(playLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
                if editingMode {
                    play = false
                } else {
                    play = true
                }
            } else {
                if editingMode {
                    
                    // remove a box
                    for node in self.nodes(at: location) {
                        if node.name == "box" {
                            node.removeFromParent()
                            return
                        }
                    }
                    
                    // create a box
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    box.name = "box"
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                    
                } else {
                    // create a ball
                    if play && balls > 0 && balls <= 5 {
                        let ball: SKSpriteNode
                        let rand = arc4random_uniform(7) + 1;
                        switch (rand){
                        case 1:
                            ball = SKSpriteNode(imageNamed: "ballRed")
                            break
                        case 2:
                            ball = SKSpriteNode(imageNamed: "ballBlue")
                            break
                        case 3:
                            ball = SKSpriteNode(imageNamed: "ballCyan")
                            break
                        case 4:
                            ball = SKSpriteNode(imageNamed: "ballGreen")
                            break
                        case 5:
                            ball = SKSpriteNode(imageNamed: "ballGrey")
                            break
                        case 6:
                            ball = SKSpriteNode(imageNamed: "ballPurple")
                            break
                        case 7:
                            ball = SKSpriteNode(imageNamed: "ballYellow")
                            break
                        default:
                            ball = SKSpriteNode(imageNamed: "ballRed")
                            break
                        }
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        ball.position = location
                        ball.position.y = UIScreen.main.bounds.height
                        ball.name = "ball"
                        boxesHit = 0
                        lastHit = "none"
                        addChild(ball)
                        balls -= 1
                        if !objects.contains(where: {$0.name?.contains("ball") ?? false}) && balls <= 0 {
                            play = false
                        }
                    }
                }
                if objects.contains(playLabel){
                    play = !play
                    balls = 5
                    score = 0
                    
                    removeChildren(in: children.filter({$0.name == "box"}))
                    
                    for _ in 0...balls*3 {
                        let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                        let box = SKSpriteNode(color: RandomColor(), size: size)
                        box.zRotation = RandomCGFloat(min: 0, max: 3)
                        box.position.x = CGFloat(arc4random()).truncatingRemainder(dividingBy: CGFloat(UIScreen.main.bounds.width))
                        box.position.y = CGFloat(arc4random()).truncatingRemainder(dividingBy: (UIScreen.main.bounds.height - 200) - (CGFloat(UIScreen.main.bounds.height / 3) - 200))
                        box.name = "box"
                        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                        box.physicsBody?.isDynamic = false
                        addChild(box)
                    }
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint, index: Int) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        bouncer.name = String(index)
        addChild(bouncer)
    }

    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }

    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(node: ball)
            balls += 1
        } else if object.name == "bad" {
            destroy(node: ball)
            score -= 1
        }
        
        if object.name == "box" {
            boxesHit += 1
            if (boxesHit > 2){
                score += 1 * boxesHit
            } else {
                score += 1
            }
            destroy(node: object)
        }
        
        for i in 1...5 {
            if object.name == String(i) {
                if lastHit != "none" && object.name != lastHit {
                    print("hit another bouncer")
                    let physicsBody = ball.physicsBody
                    let vel = ball.physicsBody?.velocity
                    ball.physicsBody = nil
                    ball.position.y = UIScreen.main.bounds.height
                    ball.physicsBody = physicsBody
                    ball.physicsBody?.velocity = vel!
                }
                lastHit = object.name!
            }
        }
    }
    
    func destroy(node: SKNode) {
        
        if node.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = node.position
                addChild(fireParticles)
            }
            node.removeFromParent()
        } else if node.name == "box" {
            node.removeFromParent()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
