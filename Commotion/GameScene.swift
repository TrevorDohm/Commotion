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

    //@IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    
    let maxSpawns = 10
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
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addBounds()

        
        self.addScore()
        
        addScoringBins(numBins:7)
        for i in 0...4 {
            drawRowOfDots(pt: CGPoint(x: frame.midX, y: frame.midY - 50 * CGFloat(i)), width: ((size.width - size.width * 0.1)/2.0) - 10,numPoints: i + 3)
        }
        
        self.score = 0
    }
    func drawRowOfDots(pt:CGPoint,width:CGFloat,numPoints:Int = 10) {
        let minW = pt.x - width
        let maxW = pt.x + width
        
        let stepSize:CGFloat = (maxW - minW)/CGFloat(numPoints)
        
        for i in 0...numPoints{
            addDot(pt: CGPoint(x: stepSize * CGFloat(i) + minW, y: pt.y))
        }
        
    }
    
    func addDot(pt:CGPoint,rad:CGFloat=10) {
//        print("Added dot at \(pt.x) , \(pt.y)")
        let dot = SKSpriteNode()
//        dot.size = CGSize(width: size.width * wd, height: size.height * ht)
        dot.size = CGSize(width: rad, height: rad)
        
        dot.position = pt
        
        
        
        dot.color = UIColor.systemPink
        dot.physicsBody = SKPhysicsBody(rectangleOf: dot.size)
        dot.physicsBody?.isDynamic = true
        dot.physicsBody?.pinned = true
        dot.physicsBody?.allowsRotation = false
        self.addChild(dot)
    }
    
    func addScoringBins(numBins:Int = 3, ht:CGFloat = 0.15,wd:CGFloat = 0.025 ) {
        
        let numBars = numBins - 1
        let binWidth = CGFloat((size.width - size.width * 0.1 ) / CGFloat(numBins))
        
//        print("Num Bins \(numBins) | BinWidth: \(binWidth)")
        let midPt = Int(numBins / 2) + 1
        
        for i in 1...numBars {
            let _x = binWidth * CGFloat(i) + size.width * 0.05
            let _y = frame.minY + size.height * 0.05
            addBarAtPoint(pt: CGPoint(x:_x , y: _y),ht: ht, wd: wd)
            addLabelAtPt(pt: CGPoint(x:_x - (binWidth/2.0), y: _y), txt: "\(Int(10/(abs(i - midPt) + 1)))")
            addScoreZoneAtPt(pt: CGPoint(x:_x - (binWidth/2.0), y: _y), num: (Int(10/(abs(i - midPt) + 1))), w: binWidth - 10)
            
        }
        addLabelAtPt(pt: CGPoint(x: binWidth * CGFloat(numBins) + size.width * 0.05 - binWidth/2.0, y: frame.minY + size.height * 0.05), txt: "\(Int(10/(abs(numBins - midPt) + 1)))")
        addScoreZoneAtPt(pt: CGPoint(x: binWidth * CGFloat(numBins) + size.width * 0.05 - binWidth/2.0, y: frame.minY + size.height * 0.05), num: Int(10/(abs(numBins - midPt) + 1)),w:binWidth - 10)
        
    }
    
    func addLabelAtPt(pt:CGPoint,txt:String) {
        let binLabel = SKLabelNode(fontNamed: "Chalkduster")
        binLabel.position = pt
        binLabel.text = txt
        binLabel.fontSize = 20
        binLabel.fontColor = SKColor.blue
        addChild(binLabel)
        
        
    }
    
    func addScoreZoneAtPt(pt:CGPoint,num:Int,w:CGFloat) {
        print("Adding ScoreZone at pt: \(pt.x), \(pt.y)")
        let scoreBin = SKSpriteNode()
        scoreBin.size = CGSize(width: w, height: 20)
        scoreBin.position = pt
        
//        scoreBin.color = UIColor.black
        scoreBin.physicsBody = SKPhysicsBody(rectangleOf:scoreBin.size)
        
        scoreBin.physicsBody?.isDynamic = true
        
        scoreBin.physicsBody?.pinned = true
        scoreBin.physicsBody?.allowsRotation = false
        scoreBin.physicsBody?.contactTestBitMask = 0x00000001
        scoreBin.physicsBody?.collisionBitMask = 0x00000001
        scoreBin.physicsBody?.categoryBitMask = 0x00000001
        
        scoreBin.name = "SCORE_BIN"
//        scoreBin.userData?.setValue(num, forKey: "pts")
        
        let tmp = NSMutableDictionary(object: num, forKey: "pts" as NSCopying)
//        tmp["pts"] = num
        scoreBin.userData = tmp
        self.addChild(scoreBin)
        
    }
    // MARK: Create Sprites Functions
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - size.height * 0.1)
        
        addChild(scoreLabel)
    }
    
    
    func spawnBobble(){
        if currSpawns < maxSpawns {
            
        
            let bobble = SKSpriteNode(imageNamed: "bobble") // this is literally a sprite bottle... 😎
            let bobbleSize = 0.05
            bobble.size = CGSize(width:size.width*bobbleSize,height:size.height * bobbleSize * 0.65) //0.65 is to keep aspect ratio correct
            
            let randNumber = Int.random(in:30...Int(size.width))
            print(randNumber)
            bobble.position = CGPoint(x: CGFloat(randNumber), y: size.height * 0.75)
            
            bobble.physicsBody = SKPhysicsBody(rectangleOf:bobble.size)
            bobble.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
            bobble.physicsBody?.isDynamic = true
            bobble.physicsBody?.contactTestBitMask = 0x00000001
            bobble.physicsBody?.collisionBitMask = 0x00000001
            bobble.physicsBody?.categoryBitMask = 0x00000001
            bobble.name="LARSON"
            self.addChild(bobble)
            currSpawns += 1
        }
    }
    
   
    func addBarAtPoint(pt:CGPoint,ht:CGFloat=0.03, wd:CGFloat = 0.05){
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
        
    
    func didBegin(_ contact: SKPhysicsContact) {
        
//        print(contact.bodyA.node!.userData?["pts"], ", ", contact.bodyB.node!.userData?["pts"])
        if let nm = contact.bodyA.node?.name as? String,
           let sc = contact.bodyA.node!.userData?["pts"] as? Int,
           let b_nm = contact.bodyB.node?.name as? String {
            if nm == "SCORE_BIN" && b_nm == "LARSON" {
                score += sc
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
        }
        
                    
    }
    
    func addBounds(){
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
        self.spawnBobble()
    }
    
    
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
