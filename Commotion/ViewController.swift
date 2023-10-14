//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    // MARK: Class Variables
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsSlider.setValue(newtotalSteps, animated: true)
                self.stepsLabel.text = "Steps: \(newtotalSteps)"
            }
        }
    }
    
    var stepsYesterday: Float = 0.0 {
        willSet(newStepsYesterday){
            DispatchQueue.main.async{
                self.stepsYesterdayLabel.text = "Steps Yesterday: \(newStepsYesterday)"
            }
        }
    }
    var dailyGoal: Float = 10000.0 { // Default value
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "DailyGoal")
        }
    }
    var stepsRemaining: Float {
        return dailyGoal - totalSteps
    }
    
    //MARK: =====UI Elements=====
    
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var playGameButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.playGameButton.isHidden = true
        self.stepsGoalLabel.text = String("Step Goal: " + String(Int(self.dailyGoal)))
        self.stepsSlider.value = Float(self.dailyGoal)
    }
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.startMotionUpdates()
    }
    
    
    // MARK: =====Raw Motion Functions=====
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device 
        
        // TODO: should we be doing this from the MAIN queue? You will need to fix that!!!....
        if self.motion.isDeviceMotionAvailable{
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main,
                                                 withHandler: self.handleMotion)
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            let rotation = atan2(gravity.x, gravity.y) - Double.pi
            self.isWalking.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        }
    }
    
    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
        
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                self.isWalking.text = "Walking: \(unwrappedActivity.walking)\n Still: \(unwrappedActivity.stationary)"
            }
        }
    }
    
    // MARK: Pedometer Meters
    
    func startPedometerMonitoring() {
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date(),
                                   withHandler: handlePedometer)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.totalSteps = steps.floatValue
        }
    }


}

