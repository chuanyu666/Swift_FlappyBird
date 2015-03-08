//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Chuan Yu on 3/6/15.
//  Copyright (c) 2015 Chuan Yu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene ,SKPhysicsContactDelegate{
    
    var timer:NSTimer!
    var score:Int!
    var scoreLabel:SKLabelNode!
    var gameOverLabel:SKLabelNode!
    
    
    var birdNode:SKSpriteNode!
    var background:SKSpriteNode!
    var ground:SKNode!
    var gap:SKNode!
    var pipe:SKSpriteNode!
    var pipe2:SKSpriteNode!
    
    var birdTexture:SKTexture!
    var birdTexture2:SKTexture!
    var pipeTexture:SKTexture!
    var pipeTexture2:SKTexture!
    var bgTexture:SKTexture!
    
    let birdGroup:UInt32 = 1<<0
    let objectGroup:UInt32 = 1<<1
    let gapGroup:UInt32 = 0
    
    var gameOver:Bool!
    
    var movingObjs = SKNode()
    var labelHolder = SKSpriteNode()
    
    var gapHeight:CGFloat!
    var pipeMovement:UInt32!
    var pipeOffset:CGFloat!

    var moveAndRemoveAction:SKAction!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        
        self.addChild(movingObjs)
        
        self.addChild(labelHolder)
        
        createBackground()
        
        //score
        score = 0
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = UIColor.purpleColor()
        scoreLabel.position = CGPointMake(self.frame.midX, self.frame.size.height-70)
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
        
        //First loading the game
        var gameStartLabel = SKLabelNode()
        gameStartLabel.fontName = "Helvetica"
        gameStartLabel.fontSize = 30
        gameStartLabel.fontColor = UIColor.purpleColor()
        gameStartLabel.position = CGPointMake(self.frame.midX, self.frame.midY)
        gameStartLabel.text = "Tap to start"
        gameStartLabel.zPosition = 10
        labelHolder.addChild(gameStartLabel)
        
        //bird
        birdTexture = SKTexture(imageNamed: "img/flappy1.png")
        birdTexture2 = SKTexture(imageNamed: "img/flappy2.png")
        
        var animation = SKAction.animateWithTextures([birdTexture,birdTexture2], timePerFrame: 0.1)
        var birdFlapAction = SKAction.repeatActionForever(animation)
        
        birdNode = SKSpriteNode(texture: birdTexture)
        birdNode.name = "bird"
        birdNode.runAction(birdFlapAction)
        
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdNode.size.height/2)
        birdNode.physicsBody?.dynamic = true
        birdNode.physicsBody?.allowsRotation = false
        //set category bit mask
        birdNode.physicsBody?.categoryBitMask = birdGroup
        //set contact object bit mask
        birdNode.physicsBody?.contactTestBitMask = objectGroup
        //set collision bit mask = 0 to avoid collision
        birdNode.physicsBody?.collisionBitMask = gapGroup
        birdNode.zPosition = 10
       
        
        //ground
        ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = objectGroup
        self.addChild(ground)
        
        //the gap height of two pipes
        gapHeight = birdNode.size.height*2
        
        var pipeAction = SKAction.moveByX(-self.frame.size.width*1.5, y: 0, duration: NSTimeInterval(0.01*self.frame.size.width))
        var removePipe = SKAction.removeFromParent()
        moveAndRemoveAction = SKAction.sequence([pipeAction,removePipe])
      
        gameOver = true
        movingObjs.speed = 0
    }
    
    func createPipe(){
        //Pipe
        if !gameOver {
            //random number between 0 - half of the screen
            pipeMovement = arc4random() % UInt32(self.frame.size.height/2)
            //pipe offset between - 1/4 of screen to 1/4 of screen
            pipeOffset = CGFloat(pipeMovement) - self.frame.size.height/4
            
            pipeTexture = SKTexture(imageNamed: "img/pipe1.png")
            pipe = SKSpriteNode(texture: pipeTexture)
            pipe.position = CGPointMake(self.frame.midX*2, self.frame.midY+pipe.size.height/2+gapHeight+pipeOffset)
            pipe.runAction(moveAndRemoveAction)
            pipe.physicsBody = SKPhysicsBody(rectangleOfSize: pipe.size)
            pipe.physicsBody?.dynamic = false
            pipe.physicsBody?.categoryBitMask = objectGroup
            movingObjs.addChild(pipe)
            
            pipeTexture2 = SKTexture(imageNamed: "img/pipe2.png")
            pipe2 = SKSpriteNode(texture: pipeTexture2)
            pipe2.position = CGPointMake(self.frame.midX*2, self.frame.midY-pipe2.size.height/2-gapHeight+pipeOffset)
            pipe2.runAction(moveAndRemoveAction)
            pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe.size)
            pipe2.physicsBody?.dynamic = false
            pipe2.physicsBody?.categoryBitMask = objectGroup
            movingObjs.addChild(pipe2)
            
            
            gap = SKNode()
            gap.position = CGPointMake(self.frame.midX*2, self.frame.midY+pipeOffset)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe.size.width, gapHeight*2))
            gap.runAction(moveAndRemoveAction)
            gap.physicsBody?.dynamic = false
          
            gap.physicsBody?.categoryBitMask = gapGroup
            gap.physicsBody?.contactTestBitMask = birdGroup
            movingObjs.addChild(gap)
        }
    }
    
    func createBackground(){
        //background
        bgTexture = SKTexture(imageNamed: "img/bg.png")
        var bgAction = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: NSTimeInterval(0.01*bgTexture.size().width))
        var replaceBgAction = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        var bgActionForever = SKAction.repeatActionForever(SKAction.sequence([bgAction,replaceBgAction]))
        
        for var i:CGFloat = 0; i<self.frame.width/bgTexture.size().width;i++ {
            background = SKSpriteNode(texture: bgTexture)
            background.position = CGPointMake(bgTexture.size().width/2+bgTexture.size().width*i, self.frame.midY)
            background.size.height = self.frame.height
            background.runAction(bgActionForever)
            movingObjs.addChild(background)
        }
    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            if !gameOver {
                score!++
                scoreLabel.text = "Score: \(score)"
            }
        }else{
            if !gameOver {
                gameOver = true
                movingObjs.speed = 0
                gameOverLabel = SKLabelNode()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.fontColor = UIColor.purpleColor()
                gameOverLabel.position = CGPointMake(self.frame.midX, self.frame.midY)
                gameOverLabel.zPosition = 10
                var highScore:Int? = NSUserDefaults.standardUserDefaults().integerForKey("score")
                if let s = highScore? {
                    if s >= score {
                        gameOverLabel.text = "Highest Score:\(s)  Tap to restart"
                    }else{
                        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "score")
                        gameOverLabel.text = "Highest Score:\(score)  Tap to restart"
                    }
                }else{
                    NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "score")
                    gameOverLabel.text = "Highest Score:\(score)  Tap to restart"
                }
               
                labelHolder .addChild(gameOverLabel)
                timer.invalidate()
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        if !gameOver {
            birdNode.physicsBody?.velocity = CGVectorMake(0, 0)
            birdNode.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        }else{
            score = 0
            scoreLabel.text = "Score: \(score)"
            movingObjs.removeAllChildren()
            createBackground()
            birdNode.position = CGPointMake(self.frame.midX, self.frame.midY)
            birdNode.physicsBody?.velocity = CGVectorMake(0, 0)
            if self.childNodeWithName("bird") as? SKSpriteNode != birdNode{
               self.addChild(birdNode)
            }
            labelHolder.removeAllChildren()
            gameOver = false
            movingObjs.speed = 1
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("createPipe"), userInfo: nil, repeats: true)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
