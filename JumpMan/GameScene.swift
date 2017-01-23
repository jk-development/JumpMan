//
//  GameScene.swift
//  JumpMan
//
//  Created by Preston Jackson and Kyle Watkins.
//  Copyright (c) 2016 Bjorn Wild. All rights reserved.
//

import SpriteKit
import UIKit
import iAd

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Global Variables
    let screenSize: CGRect = UIScreen.main.bounds
    let jumperSpriteName = "Jumper"
    let backgroundSpriteName = "Background"
    let spikeSpriteName = "Spike"
    let groundSpriteName = "Ground"
    let bounceSpriteName = "Bounce"
    let trampolineSpriteName = "Trampoline"
    
    var Jumper: SKSpriteNode!
    var Background: SKSpriteNode!
    var Spike: SKSpriteNode!
    var Ground: SKSpriteNode!
    var Bounce: SKSpriteNode!
    var Trampoline: SKSpriteNode!
    
    var backgrounds: [SKSpriteNode] = []
    
    let backgroundTime: CFTimeInterval = 1.0
    var previousTime: CFTimeInterval = 0
    var backgroundTimeCount: CFTimeInterval = 0
    
    //Touch Movement
    //var lastTouch: CGPoint? = nil
    
    //No contact with spike
    var collision = false
    
    var sceneController: GameViewController!
    
    let myLabel = SKLabelNode(fontNamed:"Arial")
    
    override func didMove(to view: SKView) {
        /*
        let alert = UIAlertController(title: "Welcome!", message:"Press \"Start\" to begin.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start", style: .default) { _ in
            self.reset()
        })
        sceneController.present(alert, animated: true){}
        */
        
        /* Setup your scene here */
        
        /*
         //Title
         self.addChild(myLabel)
         self.myLabel.text = "Jump Man"
         self.myLabel.fontSize = 45
         self.myLabel.position = CGPoint(x:self.frame.midX , y:self.frame.maxY * 0.90)
         */
        
 
        //Connecting variables to their sprites
        guard let Jumper = self.childNode(withName: jumperSpriteName) as? SKSpriteNode,
            let Background = self.childNode(withName: backgroundSpriteName) as? SKSpriteNode,
            let Spike = self.childNode(withName: spikeSpriteName) as? SKSpriteNode,
            let Ground = self.childNode(withName: groundSpriteName) as? SKSpriteNode,
            let Bounce = self.childNode(withName: bounceSpriteName) as? SKSpriteNode,
            let Trampoline = self.childNode(withName: trampolineSpriteName) as? SKSpriteNode
            else {
                print("Sprites not found.")
                return
        }
        
        self.Jumper = Jumper
        self.Background = Background
        self.Spike = Spike
        self.Ground = Ground
        self.Bounce = Bounce
        self.Trampoline = Trampoline
        
        backgrounds.append(self.Background)
        addNextBG()
        
        setPhysicsBitMasks()
        self.physicsWorld.contactDelegate = self
        

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if let touch = touches.first {
            let position :CGPoint = touch.location(in: view)
            
            if(position.x > self.screenSize.width/2){
                self.Jumper.position = CGPoint(x: (self.Jumper.position.x+150) , y: self.Jumper.position.y)
            }
            else if(position.x < self.screenSize.width/2){
                self.Jumper.position = CGPoint(x: (self.Jumper.position.x-150) , y: self.Jumper.position.y)
            }

            
        }
        
        
    }
    
    //Physics stuff for collision detection
    func setPhysicsBitMasks() {
        /* Sets up the SKSpriteNode bit masks so they can interact in the physics engine */
        
        self.Jumper.physicsBody?.categoryBitMask = PhysicsBitMasks.player
        self.Jumper.physicsBody?.collisionBitMask = PhysicsBitMasks.enemy
        self.Jumper.physicsBody?.contactTestBitMask = PhysicsBitMasks.enemy
        
        self.Spike.physicsBody?.categoryBitMask = PhysicsBitMasks.enemy
        self.Spike.physicsBody?.collisionBitMask = PhysicsBitMasks.player
        self.Spike.physicsBody?.contactTestBitMask = PhysicsBitMasks.player
    }
    
    //Camera function
    func moveCameraWith(_ node: SKNode, offset: CGFloat) {
        /* Moves the camera along the x-axis with a specified node and offset */
        
        guard let camera = self.camera else {
            print("No camera.")
            return
        }
        camera.position = CGPoint(x: 500, y: node.position.y)
    }
    
    func addNextBG() {
        /* Adds a new background sprite to backgrounds. */
        
        //Creates a new background
        let nextBG = SKSpriteNode(imageNamed: "Background")
        nextBG.size = CGSize(width: 1080, height: 1920.0)
        nextBG.anchorPoint = CGPoint(x: 0, y: 0)
        nextBG.position.y = backgrounds.last!.position.y + backgrounds.last!.frame.height
        
        //Appends background on top of the last one
        backgrounds.append(nextBG)
        addChild(nextBG)
        if backgrounds.count > 100 {
            backgrounds.first?.removeFromParent()
            backgrounds.removeFirst()
        }
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        //Camera Follows
        moveCameraWith(self.Jumper, offset: 350)
        
        //Times background placement
        backgroundTimeCount += currentTime - previousTime
        
        if backgroundTimeCount > backgroundTime {
            self.addNextBG()
            backgroundTimeCount = 0
        }
        
        previousTime = currentTime
        
        //Jumper collides with spike
        if collision{
            gameOver()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Fires when contact is made between two physics bodies with collision bit masks */
        if contact.bodyB.categoryBitMask == PhysicsBitMasks.enemy{
            collision = true
        }
    }
    
    func gameOver() {
        self.isPaused = true
        collision = false
        presentScore()
    }
    
    func presentScore() {
        let alert = UIAlertController(title: "Game Over!", message:"You have lost", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again!", style: .default) { _ in
            self.reset()
            })
        sceneController.present(alert, animated: true){}
        
    }
    
    func reset() {
        self.removeAllChildren()
        self.addChild(Background)
        self.addChild(Jumper)
        self.addChild(Trampoline)
        self.addChild(Bounce)
        self.addChild(Spike)
        self.addChild(Ground)
        
        let spikeTexture = SKTexture(imageNamed: "Spike")
        for i in 0...10 {
            // Create box with defined texture
            let box = SKSpriteNode(texture: spikeTexture);
            // Set position of box dynamically
            box.position = CGPoint(x:(Int(arc4random_uniform(UInt32(self.frame.maxX)))), y:(Int(arc4random_uniform(UInt32(self.frame.maxY)))));
            // Name for easier use (may need to change if you have multiple rows generated)
            box.name = "Spike"+String(i);
           
            
            
            
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 45, height: 50))
            box.physicsBody?.isDynamic = false
            
            box.physicsBody?.categoryBitMask = PhysicsBitMasks.enemy
            box.physicsBody?.collisionBitMask = PhysicsBitMasks.player
            box.physicsBody?.contactTestBitMask = PhysicsBitMasks.player
            
            addChild(box);
        }

        

        self.Jumper.position = CGPoint(x: 500, y: -68)
        
        //self.Spike.position = CGPoint(x: 501, y: 302)
        self.Ground.position = CGPoint(x: 501, y: -922)
        self.Bounce.position = CGPoint(x: 501, y: -412)
        
        self.Trampoline.position = CGPoint(x: 501, y: -466)
        
        
        moveCameraWith(Jumper, offset: 350)
        
        backgrounds = []
        backgrounds.append(Background)
        addNextBG()
        
        self.isPaused = false

    }
    
}
