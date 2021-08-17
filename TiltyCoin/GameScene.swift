//
//  GameScene.swift
//  TiltyCoin
//
//  Created by Min on 7/7/16.
//  Copyright (c) 2016 mihinduDeSilva. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    
    var player = SKSpriteNode()
    var coin = SKSpriteNode()
    var border = SKPhysicsBody()
    var screenHeight: CGFloat = 0.0
    var screenWidth: CGFloat = 0.0
    var score = 0
    var lblScore = SKLabelNode()
    var sizeIncrement = 0
    
    struct objectPhysics {
        static let Player : UInt32 = 0x1 << 1
        static let Coin: UInt32 = 0x1 << 2
        static let Score: UInt32 = 0x1 << 3
        static let Border: UInt32 = 0x1 << 4
        static let Bullet: UInt32 = 0x1 << 5
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        screenHeight = self.frame.height
        screenWidth = self.frame.width
        physicsWorld.contactDelegate = self
        
        backgroundColor = UIColor.init(red: 0.655, green: 0.859, blue: 0.847, alpha: 1)
        
        lblScore.text = ("\(score)")
        lblScore.fontName = (fontnamed: "Chalkduster")
        lblScore.fontColor = SKColor.blackColor()
        lblScore.fontSize = 40
        lblScore.position = CGPointMake(screenWidth/6, screenHeight/2)
        lblScore.zRotation = CGFloat(M_PI/2)
        
        player = SKSpriteNode(imageNamed: "playerIcon")
        player.setScale(0.08)
        //player.color = UIColor.blueColor()
        player.position = view.center //use for centering
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.height/2)
        player.physicsBody?.categoryBitMask = objectPhysics.Player
        player.physicsBody?.collisionBitMask = objectPhysics.Border
        player.physicsBody?.contactTestBitMask = objectPhysics.Coin
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.dynamic = true
        
        
        border = SKPhysicsBody(edgeLoopFromRect: self.frame)
        border.friction = 0
        border.categoryBitMask = objectPhysics.Border
        
        
        coin = SKSpriteNode(imageNamed: "coin")
        coin.position = CGPointMake(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        coin.setScale(0.1)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.frame.height/2)
        coin.physicsBody?.categoryBitMask = objectPhysics.Coin
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.contactTestBitMask = objectPhysics.Player
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.dynamic = false
        
        createBullets()
        
        physicsBody = border
        addChild(coin)
        addChild(player)
        addChild(lblScore)
        
        //createBullets()
        
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (data, error) in
            
            self.physicsWorld.gravity = CGVectorMake(CGFloat((data?.acceleration.x)!)*5, CGFloat((data?.acceleration.y)!)*5)
            //self.player.physicsBody?.velocity = CGVectorMake(CGFloat((data?.acceleration.x)!)*20+(self.player.physicsBody?.velocity.dx)!, CGFloat((data?.acceleration.y)!)*20+(self.player.physicsBody?.velocity.dy)!)
        }
    }
    
    /*
     ------------------------------------THINGS TO ADD------------------------------------
     
     While score increments (maybe: 2, 5, 10, 20, 30, 40, ...)
     
     Bullets come from top
     Bullets come from top + bottom
     Bullets come from sides
     Decrease coin size so it becomes harder to hit
     Add Sprite that if contact die/lose points
     
     When score == 50
     Scene disappears except player
     Exit appears (animation)
     Go through exit --> change entire objective of game
     
     -------------------------------------------------------------------------------------
     */
    
    
    func createBullets() {
        let bullet = SKSpriteNode()
        
        bullet.color = SKColor.redColor()
        bullet.size = CGSize(width: frame.width/7, height: frame.width/50)
        bullet.position = CGPoint(x: 0, y: Int(arc4random_uniform(UInt32(screenHeight))))
        
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody?.categoryBitMask = objectPhysics.Bullet
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.contactTestBitMask = objectPhysics.Player | objectPhysics.Border
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
        
        self.addChild(bullet)
    }
    
    func scored() {
        
        self.removeChildrenInArray([self.coin])
        coin.position = CGPointMake(CGFloat(arc4random_uniform(UInt32(screenWidth))), CGFloat(arc4random_uniform(UInt32(screenHeight))))
        self.addChild(coin)
        score += 1
        
        lblScore.text = ("\(score)")
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let objectA = contact.bodyA
        let objectB = contact.bodyB
      
        if objectA.categoryBitMask == objectPhysics.Player && objectB.categoryBitMask == objectPhysics.Coin || objectA.categoryBitMask == objectPhysics.Coin && objectB.categoryBitMask == objectPhysics.Player {
            scored()
        }
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
