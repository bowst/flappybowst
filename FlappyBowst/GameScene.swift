//
//  GameScene.swift
//  FlappyBowst
//
//  Created by Ben Lambert on 7/22/14.
//  Copyright (c) 2014 Bowst. All rights reserved.
//
//  Thank you to the folks over at FullStackIO
//  Much of the code herin was copied or inspired by the code in: 
//  https://github.com/fullstackio/FlappySwift
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Define our constants
    // No semi-colons...how European
    // let makes an immutable object.
    let heroCat:UInt32      = 1 << 0
    let pipeCat:UInt32      = 1 << 1
    let levelCat:UInt32     = 1 << 2
    let scoreCat:UInt32     = 1 << 3
    let skyColor            = SKColor(red: 0, green: 191, blue: 255, alpha: 1)
    let pipeGap             = 150
    let message             = "Click to start!"

    
    // Mutable instance variables.
    var hero:SKSpriteNode!
    
    var scrollNode      = SKNode()
    
    var groundNode      = SKNode()

    var pipeUpTex       = SKTexture(imageNamed: "PipeUp")
    
    var pipeDownTex     = SKTexture(imageNamed: "PipeDown")

    var pipesNode       = SKNode()
    
    var scoreLabel      = SKLabelNode(fontNamed: "Chalkduster")
    
    var startLabel      = SKLabelNode(fontNamed: "Chalkduster")
    
    var score           = 0
    
    var isGameOver      = false
    
    var isStarted       = false
    
    
    var movePipesAndRemove  :SKAction!
    var makeSkyRed          :SKAction!
    var makeSkyBlue         :SKAction!
    var makeGameEnd         :SKAction!
    
    

    
    // override init
    init() {
        super.init()
    }

    init(size: CGSize) {
        super.init(size: size)
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    
    override func didMoveToView(view: SKView) {
    
        view.paused = true
        
        // Add game physics and setup any world values.
        self.physicsWorld.gravity           = CGVectorMake( 0.0, -5.0 )
        self.physicsWorld.contactDelegate   = self
        self.backgroundColor                = self.skyColor
        self.pipeUpTex.filteringMode        = .Nearest
        self.pipeDownTex.filteringMode      = .Nearest
        
        
        self.setupStartLabel()
        
        self.hero = setupHero()
        
        self.setupGround()
        
        self.setupSkyLine()
        
        self.setupPipes()
        
        self.addChild(self.pipesNode)
        
        
        // Setup the actions...
        self.makeGameEnd = SKAction.runBlock({
            self.isGameOver = true;
            })
        
        self.makeSkyBlue = SKAction.runBlock({
            self.backgroundColor = self.skyColor;
            })
        
        self.makeSkyRed = SKAction.runBlock({
            self.backgroundColor = UIColor.redColor()
            })
        
        
        // setup the score
        scoreLabel.position     = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 2) )
        scoreLabel.fontColor    = UIColor.blackColor()
        scoreLabel.text         = String(score)
        self.addChild(scoreLabel)
        
        
        
    }

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if !self.isStarted && self.scene.view.paused {
            self.isStarted = true
            self.scene.view.paused = false
            
            self.startLabel.removeFromParent()
        }
        
        if self.scrollNode.speed > 0  {
            for touch: AnyObject in touches {
                self.hero.physicsBody.velocity = CGVectorMake(0, 0)
                self.hero.physicsBody.applyImpulse(CGVectorMake(0, 40))
                
            }
        }
    }
   
    func didBeginContact(contact: SKPhysicsContact) {
        if scrollNode.speed > 0 {
            if (contact.bodyA.categoryBitMask & scoreCat ) == scoreCat || ( contact.bodyB.categoryBitMask & scoreCat ) == scoreCat {
                // Hero has hit a score entity
                score++
                scoreLabel.text = String(score)
                
                // Add a little visual feedback for the score increment
                scoreLabel.runAction(
                    SKAction.sequence([
                        SKAction.scaleTo(2.0, duration:NSTimeInterval(0.1)),
                        SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))
                        ])
                )
            } else {
                
                // Stop the scrolling
                self.scrollNode.speed = 0
                
                // Fire off the actions that should be run to indicate the game is over
                self.runAction(SKAction.sequence([
                    self.makeSkyRed,
                    SKAction.waitForDuration(NSTimeInterval(0.05)),
                    self.makeSkyBlue,
                    self.makeGameEnd
                    ]), withKey: "gameover"
                )
            }
        }
    }
    
    func restart() {
        var s = GameScene(size: self.size)
        
        s.scaleMode = .AspectFill
        
        self.view.presentScene(s)
    }
    
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }

    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.hero.zRotation = self.clamp(-1, max: 0.5, value: self.hero.physicsBody.velocity.dy * (self.hero.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) )
        
        if self.isGameOver {
            restart()
        }
        
    }
    
    
    func setupStartLabel() {
        
        startLabel              = SKLabelNode(text: self.message)
        startLabel.fontSize     = 30
        startLabel.fontColor    = UIColor.redColor()
        startLabel.position     = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + (CGRectGetMidY(self.frame) / 3) )
        
        self.addChild(startLabel)
    }
    
    
    func setupHero() -> SKSpriteNode {
        
        let heroTexture = SKTexture(imageNamed: "bowst")
        heroTexture.filteringMode = .Nearest
        
        let hero = SKSpriteNode(texture: heroTexture)
        
        hero.setScale(0.75)
        
        hero.position                       = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        
        // Using rect since the logo is an, um...rectangle.
        hero.physicsBody                    = SKPhysicsBody(rectangleOfSize: hero.size)
        hero.physicsBody.dynamic            = true
        hero.physicsBody.allowsRotation     = false
        hero.physicsBody.categoryBitMask    = heroCat
        hero.physicsBody.collisionBitMask   = levelCat | pipeCat
        hero.physicsBody.contactTestBitMask = levelCat | pipeCat
        
        self.addChild(hero)
        return hero
    }
    
    
    func setupGround() {

        let groundTex           = SKTexture(imageNamed: "land")
        let groundTexSize       = groundTex.size()
        let groundTexWidth      = groundTexSize.width
        let groundTexHeight     = groundTexSize.height
        
        let moveGroundSprite        = SKAction.moveByX(-groundTexWidth * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTexWidth * 2.0))
        let resetGroundSprite       = SKAction.moveByX(groundTexWidth * 2.0, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
        

        groundTex.filteringMode = .Nearest
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexWidth * 2.0 ); ++i {
            let sprite = SKSpriteNode(texture: groundTex)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundSpritesForever)
            self.scrollNode.addChild(sprite)
        }
        
        
        self.groundNode.position = CGPointMake(0, groundTexHeight)
        self.groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexHeight * 2.0))
        self.groundNode.physicsBody.dynamic = false
        self.groundNode.physicsBody.categoryBitMask = levelCat
        
        self.addChild(groundNode)
        self.addChild(scrollNode)
      
    }
    
    
    func setupSkyLine() {
        // skyline
        let skyTex                  = SKTexture(imageNamed: "sky")
        let groundTex               = SKTexture(imageNamed: "land")
        let skyTexSize              = skyTex.size()
        let skyTexWidth             = skyTexSize.width
        let skyTexHeight            = skyTexSize.height
        let moveSkySprite           = SKAction.moveByX(-skyTexWidth * 2.0, y: 0, duration: NSTimeInterval(0.1 * skyTexWidth * 2.0))
        let resetSkySprite          = SKAction.moveByX(skyTexWidth * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever   = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        skyTex.filteringMode    = .Nearest
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( skyTexWidth * 2.0 ); ++i {
            let sprite = SKSpriteNode(texture: skyTex)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + groundTex.size().height * 2.0)
            sprite.runAction(moveSkySpritesForever)
            self.scrollNode.addChild(sprite)
        }
        
    }
    
    
    func spawnPipes() {
        var pipePair        = SKNode()
        pipePair.position   = CGPointMake(self.frame.size.width + self.pipeUpTex.size().width * 2, 0)
        pipePair.zPosition  = -10
        var height          = CGFloat(self.frame.size.height / 4)
        var y               = CGFloat(Double(arc4random())) % height + height

        
        var pipeDown                            = SKSpriteNode(texture: self.pipeDownTex)
        pipeDown.setScale(2.0)
        pipeDown.position                       = CGPointMake(0.0, y + pipeDown.size.height + pipeGap)
        pipeDown.physicsBody                    = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody.dynamic            = false
        pipeDown.physicsBody.categoryBitMask    = pipeCat
        pipeDown.physicsBody.contactTestBitMask = heroCat
        pipePair.addChild(pipeDown)
        
        let pipeUp                              = SKSpriteNode(texture: self.pipeUpTex)
        pipeUp.setScale(2.0)
        pipeUp.position                         = CGPointMake(0.0, y)
        pipeUp.physicsBody                      = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody.dynamic              = false
        pipeUp.physicsBody.categoryBitMask      = pipeCat
        pipeUp.physicsBody.contactTestBitMask   = heroCat
        pipePair.addChild(pipeUp)
        
        var contactNode                             = SKNode()
        contactNode.position                        = CGPointMake( pipeDown.size.width + hero.size.width / 2, CGRectGetMidY( self.frame ) )
        contactNode.physicsBody                     = SKPhysicsBody(rectangleOfSize: CGSizeMake( pipeUp.size.width, self.frame.size.height ))
        contactNode.physicsBody.dynamic             = false
        contactNode.physicsBody.categoryBitMask     = scoreCat
        contactNode.physicsBody.contactTestBitMask  = heroCat

        pipePair.addChild(contactNode)
        pipePair.runAction(movePipesAndRemove)
        self.pipesNode.addChild(pipePair)

    }
    
    
    func setupPipes() {
        // spawn the pipes
        SKAction.runBlock({})
        let spawn                   = SKAction.runBlock({
                self.spawnPipes()
            })
        let delay                   = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay          = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever   = SKAction.repeatActionForever(spawnThenDelay)
        
        // create the pipes movement actions
        let distanceToMove          = CGFloat(self.frame.size.width + 2.0 * self.pipeUpTex.size().width)
        let movePipes               = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePipes             = SKAction.removeFromParent()
        movePipesAndRemove          = SKAction.sequence([movePipes, removePipes])
        
        self.runAction(spawnThenDelayForever)
        
        
    }
    
}
