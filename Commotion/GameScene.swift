//
//  GameScene.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    
    
    var maxSpawns = 10
   
    var currSpawns = 0
    
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.init(), withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)" // Update the label on screen whenever the variable is changed in code with observer pattern
            }
        }
    }
    
    override func didMove(to view: SKView) { // Like View did load, setting up the game scene
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // add bounds to all 4 sides of screen
        self.addBounds()

        
        self.addScore() // add score label
        
        addScoringBins(numBins:7) // add numBins number of scoring bins to bottom and assign point values to them (higher pts in middle)
        for i in -4...4 { // Draw 4 rows of dots of differing numbers, It will figure out how to place them automatically based on screen size
            drawRowOfDots(pt: CGPoint(x: frame.midX, y: frame.midY - 50 * CGFloat(i)), width: ((size.width - size.width * 0.1)/2.0) - 10,numPoints: abs(i) + 2)
        }
        
        
        self.score = 0 // Set Score to 0 initially
    }
    //MARK: Drawing Sprites to Screen Functions
    func drawRowOfDots(pt:CGPoint,width:CGFloat,numPoints:Int = 10) {
        let minW = pt.x - width
        let maxW = pt.x + width
        
        let stepSize:CGFloat = (maxW - minW)/CGFloat(numPoints)
        
        for i in 0...numPoints{
            addDot(pt: CGPoint(x: stepSize * CGFloat(i) + minW, y: pt.y))
        }
        
    }
    func drawCrazyLarson(){
        let crazy = SKSpriteNode(imageNamed: "crazyBobble")
        let crazySize = 0.05
        crazy.size = CGSize(width:size.width*crazySize,height:size.height * crazySize * 0.65) //0.65 is to keep aspect ratio correct
        
        let randNumber = Int.random(in:30...Int(size.width))
        crazy.position = CGPoint(x: CGFloat(randNumber), y: size.height * 0.9)
        
        crazy.physicsBody = SKPhysicsBody(rectangleOf:crazy.size)
        crazy.physicsBody?.restitution = random(min: CGFloat(1), max: CGFloat(2))
        crazy.physicsBody?.isDynamic = true
        crazy.physicsBody?.contactTestBitMask = 0x00000001
        crazy.physicsBody?.collisionBitMask = 0x00000001
        crazy.physicsBody?.categoryBitMask = 0x00000001
        crazy.name="CRAZYLARSON"
        self.addChild(crazy)
    }
    
    func addDot(pt:CGPoint,rad:CGFloat=10) { // Ws supposed to be a circle but i couldnt figure it out so its a square with side length = rad
        let dot = SKSpriteNode()
        dot.size = CGSize(width: rad, height: rad)
        
        dot.position = pt
        
        
        
        dot.color = UIColor.systemPink
        dot.physicsBody = SKPhysicsBody(rectangleOf: dot.size)
        dot.physicsBody?.isDynamic = true
        dot.physicsBody?.pinned = true
        dot.physicsBody?.allowsRotation = true
        self.addChild(dot)
    }
    
    func addScoringBins(numBins:Int = 3, ht:CGFloat = 0.15,wd:CGFloat = 0.025 ) {
        
        let numBars = numBins - 1
        let binWidth = CGFloat((size.width - size.width * 0.1 ) / CGFloat(numBins))
        let midPt = Int(numBins / 2) + 1 // Find mid pt in array
        
        for i in 1...numBars {
            let _x = binWidth * CGFloat(i) + size.width * 0.05 // Curr X Location + length of left wall
            let _y = frame.minY + size.height * 0.05 // same for y ^
            addBarAtPoint(pt: CGPoint(x:_x , y: _y),ht: ht, wd: wd)
            addLabelAtPt(pt: CGPoint(x:_x - (binWidth/2.0), y: _y), txt: "\(Int(10/(abs(i - midPt) + 1)))") // Determine point value
            addScoreZoneAtPt(pt: CGPoint(x:_x - (binWidth/2.0), y: _y), num: (Int(10/(abs(i - midPt) + 1))), w: binWidth - 10) // Score Zone is the object that increments score and removes the object that collided with it
            
        }
        // Needed to add the last set of boxes on right
        addLabelAtPt(pt: CGPoint(x: binWidth * CGFloat(numBins) + size.width * 0.05 - binWidth/2.0, y: frame.minY + size.height * 0.05), txt: "\(Int(10/(abs(numBins - midPt) + 1)))")
        addScoreZoneAtPt(pt: CGPoint(x: binWidth * CGFloat(numBins) + size.width * 0.05 - binWidth/2.0, y: frame.minY + size.height * 0.05), num: Int(10/(abs(numBins - midPt) + 1)),w:binWidth - 10)
        
    }
    
    func addLabelAtPt(pt:CGPoint,txt:String) { // Adds a label at a given CGPoint location with a given text
        let binLabel = SKLabelNode(fontNamed: "Chalkduster")
        binLabel.position = pt
        binLabel.text = txt
        binLabel.fontSize = 20
        binLabel.fontColor = SKColor.blue
        addChild(binLabel)
        
        
    }
    
    func addScoreZoneAtPt(pt:CGPoint,num:Int,w:CGFloat) { //Zone that will destroy objects that it collides with and incrememnt/decrement the score
        print("Adding ScoreZone at pt: \(pt.x), \(pt.y)")
        let scoreBin = SKSpriteNode()
        scoreBin.size = CGSize(width: w, height: 20)
        scoreBin.position = pt
        

        scoreBin.physicsBody = SKPhysicsBody(rectangleOf:scoreBin.size)
        
        scoreBin.physicsBody?.isDynamic = true
        
        scoreBin.physicsBody?.pinned = true
        scoreBin.physicsBody?.allowsRotation = false
        scoreBin.physicsBody?.contactTestBitMask = 0x00000001
        scoreBin.physicsBody?.collisionBitMask = 0x00000001
        scoreBin.physicsBody?.categoryBitMask = 0x00000001
        
        scoreBin.name = "SCORE_BIN" // Used for collison filtering later
        
        let tmp = NSMutableDictionary(object: num, forKey: "pts" as NSCopying)
        scoreBin.userData = tmp
        self.addChild(scoreBin)
        
    }
    func addScore(){ // Stolen from Dr.Larson example but i made it top of the screen
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - size.height * 0.1)
        
        addChild(scoreLabel)
    }
    
    
    func spawnBobble(){ // Spawns drLarson heads if number of spawns is still allowed
    
        
    
        let bobble = SKSpriteNode(imageNamed: "bobble")
        let bobbleSize = 0.05
        bobble.size = CGSize(width:size.width*bobbleSize,height:size.height * bobbleSize * 0.65) //0.65 is to keep aspect ratio correct
        
        let randNumber = Int.random(in:30...Int(size.width))
        print(randNumber)
        bobble.position = CGPoint(x: CGFloat(randNumber), y: size.height * 0.9)
        
        bobble.physicsBody = SKPhysicsBody(rectangleOf:bobble.size)
        bobble.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        bobble.physicsBody?.isDynamic = true
        bobble.physicsBody?.contactTestBitMask = 0x00000001
        bobble.physicsBody?.collisionBitMask = 0x00000001
        bobble.physicsBody?.categoryBitMask = 0x00000001
        bobble.name="LARSON"
        self.addChild(bobble)
        
    }
    
   
    func addBarAtPoint(pt:CGPoint,ht:CGFloat=0.03, wd:CGFloat = 0.05){ // adds a vertical bar at point (Math is done such that the point is anchored to the southern top of the bar)
        let bar = SKSpriteNode()
        bar.size = CGSize(width: size.width * wd, height: size.height * ht)
        
        bar.position = CGPoint(x:pt.x,y:pt.y + (size.height * ht)/2.0)
        
        bar.color = UIColor.blue
        bar.physicsBody = SKPhysicsBody(rectangleOf:bar.size)
        bar.physicsBody?.isDynamic = true
        bar.physicsBody?.pinned = true
        bar.physicsBody?.allowsRotation = false
        self.addChild(bar)
    }
        
    
    func didBegin(_ contact: SKPhysicsContact) { //Physics collider logic
        
        //Logical statements:
            // if LARSON head variant hits score box, increment/decrement score and erase the larson head from the game
        
        
        if let nm = contact.bodyA.node?.name as? String,
           let sc = contact.bodyA.node!.userData?["pts"] as? Int,
           let b_nm = contact.bodyB.node?.name as? String {
            if nm == "SCORE_BIN" && b_nm == "LARSON" {
                score += sc
                contact.bodyB.node?.removeFromParent()
            }
            if nm == "SCORE_BIN" && b_nm == "CRAZYLARSON" {
                score -= sc
                contact.bodyB.node?.removeFromParent()
            }
        }
        if let nm = contact.bodyB.node?.name as? String,
           let sc = contact.bodyB.node!.userData?["pts"] as? Int,
           let a_nm = contact.bodyA.node?.name as? String{
            if nm == "SCORE_BIN" && a_nm == "LARSON"{
                contact.bodyA.node?.removeFromParent()
                score += sc
            }
            if nm == "SCORE_BIN" && a_nm == "CRAZYLARSON"{
                contact.bodyA.node?.removeFromParent()
                score -= sc
            }
        }
        
                    
    }
    
    func addBounds(){ // Adds the bounding boxes to the screen
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bot = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bot.size = CGSize(width: size.width, height: size.height * 0.1)
        bot.position = CGPoint(x: size.width * 0.5, y: 0)
        
        for obj in [left,right,top,bot]{
            obj.color = UIColor.red
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currSpawns < maxSpawns {
            self.spawnBobble()
            self.drawCrazyLarson()
            currSpawns += 1
        }
    }
    
    
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat { // These did not work...
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
